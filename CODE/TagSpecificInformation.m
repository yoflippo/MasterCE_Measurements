%% Measurement specific information in order to evaluate the data

% Every tag has an extra marker, this indicates the relative location of
% the extra markers
% 1=x,2=y,3=z
TagSpecificInfo.extraMarkerIndication = {3};

% Every tag has an extra marker, this indicates if that marker is a the
% largerst within a direction of the coordinate system or not in order to
% find it automatically
TagSpecificInfo.extraMarkerMaxOrMin = {0};

% Every tag has a number of Optitrack markers:
TagSpecificInfo.numberOfMarkersPertag = [5];