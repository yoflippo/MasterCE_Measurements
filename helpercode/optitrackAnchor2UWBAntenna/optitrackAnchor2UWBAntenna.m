% OPTITRACKANCHOR2UWBANTENNA
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)
%% Description
% Measurements were done with Optitrack (format: c3d) and Pozyx (format:
% .txt)
% These measurements are converted to .mat files with:
% 1- convert_pozyx_to_MAT.m
% 2- convertC3D_to_MAT.m

%% PURPOSE of this function
% Each Pozyx Anchor has its antenna chip on a certain location relative to
% the Optitrack markers attached to each anchor. This was not perfectly
% standarised. This function calculates the antenna position based on the
% marker position (semi-derived from photos, taken form the measurement
% setup)

%% $Revision: 0.0.0 $  $Date: 2020-09-03 $
% Creation of this function.

%% Assumptions
% 1- The anchor coordinate system is always the same
% 2- Over the couple of days in which measurements were done, the anchor
% setup stayed the same
% 3- The anchors were static, regardless of the optitrack data, which could
% show some jittering

function [optiOut] = optitrackAnchor2UWBAntenna(optitrack,dirinfo)
% update the .mat file, in case some directory reordering has took place
optiOut = optitrack;
optiOut.path = dirinfo.folder;
optiOut.name = dirinfo.name;
% load anchor specific information
AnchorSpecificInformation

%% Reduce anchor data to its average position, e.g. remove any jittering/noise
% Search in names for anchor information
anc.idx = contains(optiOut.names,'Anchor');
anc.coordinates = optiOut.coordinatesFilled(anc.idx);
for nA = 1:length(anc.coordinates)
    Anchor{nA} = mean(anc.coordinates{nA});
end
optiOut.Anchors.AveragePosition = cell2mat(Anchor');
optiOut.Anchors.idx = anc.idx;
optiOut.Anchors.names = optiOut.names(anc.idx);

%% Find the separate anchors
numOfAnchors = length(AnchorSpecificInfo.anchorids);
for nA = 1:numOfAnchors
    thisAnchor = contains(optiOut.Anchors.names,['Anchor' num2str(nA)]);
    %     eval(['optiOut.Anchors.Anchor' num2str(nA)  '= optiOut.Anchors.AveragePosition(thisAnchor,:)']);
    separate{nA} = optiOut.Anchors.AveragePosition(thisAnchor,:);
end

%% Find the two markers which have the UWB antenna in their middle
for nA = 1:numOfAnchors
    thisSep = separate{nA};
    [r,~] = size(thisSep);
    coorddirection = AnchorSpecificInfo.extraMarkerIndication{nA};
    maxmin = thisSep(:,coorddirection);
    if r > 3
        
        % find extra marker and remove it!
        extraMarker = findIndexLargestKElements(maxmin,...
            1,AnchorSpecificInfo.extraMarkerMaxOrMin{nA});
        optiOut.Anchors.idxExtraMarker(nA) = extraMarker;
        
        thisSepClean{nA} = thisSep(setdiff(1:length(thisSep),extraMarker),:);
        maxmin = maxmin(setdiff(1:length(thisSep),extraMarker),:);
    else
        thisSepClean{nA} = thisSep;
    end
    % find marker that can be removed to estimate the antenna location
    % (only 2 are needed, while 3 are available, see photos)  
    idxMarker2Rm = findIndexLargestKElements(maxmin,1,1);
    try
        thisSepCleanAntenna{nA} = thisSepClean{nA}(setdiff(1:length(thisSepClean{nA}),idxMarker2Rm),:);
    catch
        keyboard
        return
    end
    
    % estimate antenna position, please note the marker depth != antenna
    % depth (see photos)
    UWB_antenna{nA} = mean(thisSepCleanAntenna{nA});
end

%% Save the cleaned up data for later use
optiOut.Anchors.separate = separate;
optiOut.Anchors.separateNoExtraMarker = thisSepClean;
optiOut.Anchors.UWB_Antenna = UWB_antenna;
% save(fullfile(dirinfo.folder,replace(dirinfo.name,'optitrack','optitrack_ca')),'optitrack');
end











%% Helper functions
function [idx] = findIndexLargestKElements(vector,k,maxmin)
idx = [];
for i = 1:k
    if maxmin
        [~,idx(i)] = max(vector);
    else
        [~,idx(i)] = min(vector);
    end
    vector(idx(i)) = NaN;
end
end
