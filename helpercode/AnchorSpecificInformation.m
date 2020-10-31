%% Measurement specific information in order to evaluate the data

% Ordered IDS (first is marker 1, last is marker 4)
AnchorSpecificInfo.anchorids = {'696C','6E49','6E02','695F'};

% Every anchor has an extra marker, this indicates the relative location of
% the extra markers
% 1=x,2=y,3=z
AnchorSpecificInfo.extraMarkerIndication = {3,2,3,3};

% Every anchor has an extra marker, this indicates if that marker is a the
% largerst within a direction of the coordinate system or not in order to
% find it automatically
AnchorSpecificInfo.extraMarkerMaxOrMin = {1,1,1,0};

% Every anchor has a number of Optitrack markers:
AnchorSpecificInfo.numberOfMarkersPerAnchor = [4,4,4,4];