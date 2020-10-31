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


function [out] = optitrackMarkerRESTORE(crd,crdFilled)

%% Get data from same coordinate
[r,c] = size(crd);
limx.start = 5790; limx.end = 5830;

for nC = 1:size(c)
    for nS = 1:length(crd)
        curr(:,nS) = crd{nS}(:,nC);
    end
    curr(curr==0)=NaN;
    curr = fillgaps(curr,10,10);
    sDiff = getDiffandPeaks(curr);
    plotThis(curr,sDiff,limx);
    
    c1 = changeTwoSampleMixedup(curr,sDiff);
    plotThis(c1,sDiff,limx)
    distFig
end

out = crd;
end

function [sDiff] = getDiffandPeaks(coordinates)
[~,col] = size(coordinates);
Differences = [zeros(1,col); diff(coordinates)];
PoC2 = abs(Differences) > 0.5; % heuristic value
sDiff.PoCsigns = sign(Differences).*PoC2;

sDiff.PoC2 = PoC2;
sDiff.Differences = Differences;
end

function coordinatesImproved = changeTwoSampleMixedup(coordinates,sDiff)
idxConf = find(sum(sDiff.PoC2,2)==2);
coordinatesImproved = coordinates;
for idx = idxConf'
    currIdx2Swap = find(sDiff.PoC2(idx,:));
    t2 = coordinatesImproved(idx,currIdx2Swap(1));
    t1 = coordinatesImproved(idx,currIdx2Swap(2));
    coordinatesImproved(idx,currIdx2Swap(2)) = t2;
    coordinatesImproved(idx,currIdx2Swap(1)) = t1;
end
end

function plotThis(curr,sDiff,limx)
    figure
    subplot(2,1,1)
    %     plot(curr,'LineWidth',1);
    hold on;
    t=curr; t(t==0)=NaN;
    plot(t,'LineWidth',1);
    xlim([limx.start  limx.end]);
    
    subplot(2,1,2)
    plot(sDiff.Differences)
    xlim([limx.start  limx.end]);
end