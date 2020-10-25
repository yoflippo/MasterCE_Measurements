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
    
    %% Get the first samples of each marker to use for determining which are the
    % antenna markers
    for nT = 1:length(tag.coordinates)
        tmp(nT,1:3) = tag.coordinates{nT}(1,:);
    end
    
    %% Find the highest (along the z directory) 2 markers
    height = tmp(:,3);
    idx = findIndexLargestKElements(height,2,1);
    out.Tag.AntennaMarkersIdx = idx;
    tmp = tag.coordinates(idx);
    out.Tag.AntennaMarkersCoordinates = tmp;
    
    %% Combine the data
    out.Tag.Coordinates = (tmp{1}+tmp{2})/2;
    
    %% Finally
    out.Tag.CoordinatesIdxRaw = tag.idx;
    out.Tag.RawCoordinates = tag.coordinates;
end
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
