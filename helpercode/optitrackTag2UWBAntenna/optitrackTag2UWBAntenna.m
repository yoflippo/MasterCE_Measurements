% OPTITRACKTAG2UWBANTENNA
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)

% $Revision: 0.0.0 $  $Date: 2020-09-05 $
% Creation of this function.

%% Reduce the tag markers to only 2 markers which are directly at the side of
% the UWB antenna. Then combine the two 3D vector to 1 which represents the
% 'true' UWB position
function [out] = optitrackTag2UWBAntenna(optitrack)
% load tag specific information
TagSpecificInformation
out = optitrack;

% Search in names for tag information
tag.idx = contains(optitrack.names,'Car_Marker');
if any(tag.idx)
    tag.coordinates = optitrack.coordinatesFilled(tag.idx);
    tag.coordinatesNotFilled = optitrack.coordinatesNotFilled(tag.idx);
    
    tagAntennaFilled = getExactTagAntennaCoordinates(tag.coordinates);
    tagAntennaNOTfilled = getExactTagAntennaCoordinates(tag.coordinatesNotFilled);
    
    out.Tag.CoordinatesIdxRaw = tag.idx;
    out.Tag.RawCoordinates = tag.coordinates;
    out.Tag.RawCoordinatesNotFilled = tag.coordinatesNotFilled;
    
    out.Tag.AntennaMarkersCoordinates = tagAntennaFilled.AntennaMarkersCoordinates;
    out.Tag.Coordinates = tagAntennaFilled.Coordinates;
    out.Tag.AntennaMarkersIdx = tagAntennaFilled.AntennaMarkersIdx;
    
    out.Tag.NotFilled.AntennaMarkersCoordinates = tagAntennaNOTfilled.AntennaMarkersCoordinates;
    out.Tag.NotFilled.Coordinates  = tagAntennaNOTfilled.Coordinates;
    out.Tag.NotFilled.AntennaMarkersIdx  = tagAntennaNOTfilled.AntennaMarkersIdx;
end
end


%% Helper functions
function tag = getExactTagAntennaCoordinates(tagCoordinates)
%% Get the first samples of each marker to use for determining which are the
for nT = 1:length(tagCoordinates)
    tmp(nT,1:3) = tagCoordinates{nT}(1,:);
end
%% Find the highest (along the z directory) 2 markers
height = tmp(:,3);
tag.AntennaMarkersIdx = findIndexLargestKElements(height,2,1);
tag.AntennaMarkersCoordinates = tagCoordinates(tag.AntennaMarkersIdx);
tag.Coordinates = (tag.AntennaMarkersCoordinates{1}+tag.AntennaMarkersCoordinates{2})/2;
end


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