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
    
    %     %% Find a glitch, in 2 channels
    currDiff = [zeros(1,c); diff(curr)];
    PoC = abs(currDiff) > 2;
    PoCsigns = sign(currDiff).*PoC;
    idxConf = find(sum(PoC,2)>=2);
    %     %% Found the 'off the rail' samples with 2 wrong values
    %     for i = idxConf'
    %         signalIdxErr = find(PoC(i,:));
    %         if PoCsigns(i,signalIdxErr(1)) < 0
    %             curr(i,signalIdxErr) = curr(i,fliplr(signalIdxErr));
    %         end
    %     end
    %
    figure
    subplot(2,1,1)
    plot(curr);
    %     xlim([7470 7490]);
    subplot(2,1,2)
    plot(currDiff)
    %     xlim([7470 7490]);
    %     xlim([16670 16850]);
    %
    %
    %     %% Find a glitch, in 4 channels
    %     currDiff = [zeros(1,c); diff(curr)];
    %     PoC = abs(currDiff) > 2;
    %     PoCsigns = sign(currDiff).*PoC;
    %     idxConf = find(sum(PoC,2)==4);
    %% Found the 'off the rail' samples with 2 wrong values
    
    for i = 1:length(idxConf)
        idx = idxConf(i);
        old = curr(idx,:);
        curr(idx,:) = findSmallestDifferenceVector(curr(idx,:),curr(idx-1,:));
        if not(isequal(old,curr(idx,:)))
            old
            prev = curr(idx-1,:)
            new = curr(idx,:)
            
            keyboard
        end
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

function [outVec1] = findSmallestDifferenceVector(vec1,vec2)
try
    for i = 1:length(vec1)
        idxs(i) = findSmallestDifferenceIdx(vec1(i),vec2);
    end
    outVec1 = vec1(idxs);
catch
    keyboard
end
end

function [outValIdx] = findSmallestDifferenceIdx(val,vec)
d = abs(abs(vec)-abs(val));
idx = (min(d)==d);
outValIdx = find(idx);
outValIdx = outValIdx(1);
end