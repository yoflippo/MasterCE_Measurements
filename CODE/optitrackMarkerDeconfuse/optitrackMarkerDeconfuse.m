% OPTITRACKMARKERDECONFUSE
% Optitrack can confuse markers in a rigid body which gives 'jumpy' or
% 'glitchy' signals. Because you can see a signal jump between 'markers'
% one can 'reconstruct' them to the original signal. That is what this
% function does.
%
% ASSUMPTIONS:
% The input channels belong together (i.e. are from the same Optitrack
% rigid body).
%
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)

% $Revision: 0.0.0 $  $Date: 2020-09-27 $
% Creation of this function.


function [out] = optitrackMarkerDeconfuse(coordinates)

%% Get data from same coordinate
[r,c] = size(coordinates);
for nC = 1:size(c)
    for nS = 1:length(coordinates)
        curr(:,nS) = coordinates{nS}(:,nC);
    end
    
    currDiff = [zeros(1,c); diff(curr)];
    PoC = abs(currDiff) > 2;
    PoCsigns = sign(currDiff).*PoC;
    idxConf = find(sum(PoC,2)>=2);
    
    figure
    subplot(2,1,1)
    plot(curr);
    %     xlim([7470 7490]);
    subplot(2,1,2)
    plot(currDiff)
    
    %% Found the 'off the rail' samples
    for i = idxConf'
        prev = curr(i-1,:);
        [~, idx_prev_l2h] = sort(prev);
        [~, idx_curr_l2h] = sort(curr(i,:));
        curr(i,idx_curr_l2h)= curr(i,idx_prev_l2h);
    end
    
    figure
    subplot(2,1,1)
    plot(curr);
    %     xlim([7470 7490]);
    subplot(2,1,2)
    plot(currDiff)
    
    
    
    
    %% Put it back
    for nS = 1:length(coordinates)
        coordinates{nS}(:,nC) = curr(:,nS);
    end
end

out = coordinates;
end

