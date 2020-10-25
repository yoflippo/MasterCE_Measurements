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


function [out] = optitrackMarkerRESTORE2(crd,crdFilled)

%% Get data from same coordinate
[r,c] = size(crd);
% limx.start = 1680; limx.end = 1720;
% limx.start = 5790; limx.end = 5830;
% limx.start = 5260; limx.end = 5270;
limx.start = 1555; limx.end = 1570;
% limx.start = 1; limx.end = 10000;

for nC = 1:size(c)
    for nS = 1:length(crd)
        curr(:,nS) = crd{nS}(:,nC);
    end
    curr(curr==0)=NaN;
    curr = fillgaps(curr,10,10);
    sDiff = getDiffandPeaks(curr);
    plotThis(curr,sDiff,limx);
    
    c1 = changeTwoSampleMixedup(curr);
    sDiff2 = getDiffandPeaks(c1);
    plotThis(c1,sDiff2,limx)
    
    c2 = changeSamplesVague(c1);
    sDiff3 = getDiffandPeaks(c2);
    plotThis(c2,sDiff3,limx)
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

function coordOut = changeSamplesVague(coordinates)
crds = coordinates;
for nS = 1:length(coordinates)-2
  
   %% check if there is a certain spike in compared to next position
   ccdiff = diff(crds(nS:nS+2,:));
   ccdiffpeak = abs(ccdiff) > 0.5;
   
   % The idea: compare the n and n+1 see which n+1
   % configuration give the least differences in 2 samples
   if sum(ccdiffpeak) > 1
       idxs = find(ccdiffpeak);
       t1 = crds(nS+1,idxs(1));
       t2 = crds(nS+1,idxs(2));
       crds(nS+1,idxs(1)) = t2;
       crds(nS+1,idxs(2)) = t1;
   end
end
coordOut = crds;
end

function coordOut = changeTwoSampleMixedup(coordinates)
crds = coordinates;
for nS = 1:length(coordinates)-1
  
   %% check if there is a certain spike in compared to next position
   ccdiff = diff(crds(nS:nS+1,:));
   ccdiffpeak = abs(ccdiff) > 1;
   
   if sum(ccdiffpeak) == 2
       idxs = find(ccdiffpeak);
       t1 = crds(nS+1,idxs(1));
       t2 = crds(nS+1,idxs(2));
       crds(nS+1,idxs(1)) = t2;
       crds(nS+1,idxs(2)) = t1;
   end
end
coordOut = crds;
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