% OPTITRACKTAG2UWBANTENNA
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)

% $Revision: 0.0.0 $  $Date: 2020-09-05 $
% Creation of this function.

%% Reduce the tag markers to only 2 markers which are directly at the side of
% the UWB antenna. Then combine the two 3D vector to 1 which represents the
% 'true' UWB position
function [out] = optitrackTag2UWBAntennaWheelchairTests(optitrack,nameOptitrackTag)

if ~exist('nameOptitrackTag','var')
    nameOptitrackTag = 'Car_Marker';
end

% load tag specific information
TagSpecificInformation
out = optitrack;

% Search in names for tag information
tag.idx = contains(optitrack.names,nameOptitrackTag);
if any(tag.idx)
    tag.coordinates = optitrack.coordinatesFilled(tag.idx);
    [tagCoordinates,AntennaMarkersIdx,AntennaMarkersCoordinates] = getUWBTagOptitrackMarkers(tag.coordinates);
    
    %% Finally
    out.Tag.AntennaMarkersIdx = AntennaMarkersIdx;
    out.Tag.CoordinatesIdxRaw = tag.idx;
    out.Tag.Coordinates = tagCoordinates;
%     % =========== TEST: the effect of filters on TAG detection ===========
%     [t_tagCoordinates] = getUWBTagOptitrackMarkers(optitrack.coordinatesRaw(tag.idx));
%     t_tagCoordinates = t_tagCoordinates(optitrack.SyncIdx.Start:optitrack.SyncIdx.Stop,:);
%     test = out.Tag.Coordinates-t_tagCoordinates;
%     test = sum(test,'all');
%     if any(abs(test) > 200)
%         figure('WindowState','maximized');
%         plot(out.Tag.Coordinates,'LineWidth',3);
%         hold on;
%         plot(t_tagCoordinates,'k');
%         pause
%         close all;
%     end
%     % =========== TEST: the effect of filters on TAG detection ===========
    out.Tag.RawCoordinates = tag.coordinates;
    out.Tag.AntennaMarkersCoordinates = AntennaMarkersCoordinates;
else
    error([newline mfilename ': ' newline 'No Tags found' newline]);
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

function [tagCoordinates,AntennaMarkersIdx,AntennaMarkersCoordinates] = getUWBTagOptitrackMarkers(coordinates)
for nS = 1:length(coordinates{1}(:,1))
    %% Get the first samples of each marker to use for determining which are the
    % antenna markers
    for nT = 1:length(coordinates)
        tmp(nT,1:3) = coordinates{nT}(nS,:);
        
        %         % =========== TEST ===========
        %         subplot(2,2,nT)
        %         plot(tag.coordinates{nT}); grid on; grid minor;
        %         % =========== TEST ===========
    end
    
    %% Find the highest (along the z directory) 2 markers
    height = tmp(:,3);
    idx = findIndexLargestKElements(height,2,1);
    AntennaMarkersIdx(nS,1:2) = idx;
    tmp2 = tmp(idx,:);
    AntennaMarkersCoordinates{nS,1} = tmp2;
    
    %% Combine the data
    tagCoordinates(nS,1:3) = (tmp2(1,:)+tmp2(2,:))/2;
end
end