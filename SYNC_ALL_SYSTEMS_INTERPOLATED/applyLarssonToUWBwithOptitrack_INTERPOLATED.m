function [sUWB] = applyLarssonToUWBwithOptitrack_INTERPOLATED(optitrack,uwb)
%% It is assumed that the optitrack inputparameter is a struct containing
% the previously analysed ANCHOR data and positions expressed in the
% optitrack coordinate system.
%% It is assumed that the uwb inputparameter is a struct containing the mat-
% file location, that has the uwb distances

[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)

ap.larsson = findSubFolderPath(mfilename('fullpath'),'MATLAB','SIMULATION');
ap.larsson = findSubFolderPath(ap.larsson,'SIMULATION','larsson');
addpath(genpath(ap.larsson));

if not(exist(uwb.fullpath,'file'))
    error([newline mfilename mfilename ': ' newline blanks(30) ': LOOK HERE, uwb file does not exist!' newline]);
else
    [uwbdata] = load(uwb.fullpath);
    uwbdata = uwbdata.result;
end
sUWB.rawdata = uwbdata.data;
data.AnchorPositions = (cell2mat(optitrack.Anchors.UWB_Antenna')*10)';
sUWB = convertPozyxDataToWorkableForm(optitrack,uwbdata);
data.Distances = sUWB.DistancesUWB;
coordinatesUWBlarsson = executeTrilaterationsLarsson(data);
sUWB.coordinatesUWBlarsson = coordinatesUWBlarsson;
rmpath(genpath(ap.larsson));
end


function data = convertPozyxDataToWorkableForm(optitrack,pozyx)
%% This method assumes that optitrack and pozyx data are 'SYNCED'!
minimumLengthData = Inf;
num.Anchors = length(pozyx.data);

data.DistancesUWB = pozyx.data.Distances;
data.TimestampsUWB = pozyx.data.DistancesTimes;

TimeUWBRoundedToFSduration = roundn(data.TimestampsUWB,1);% round to nearest 10 to find a match in optitrack time

%% data.CoordinatesOptitrackAlignedWithUWB
numSamplesSync = length(optitrack.Tag.Coordinates);
data.TimestampsOptitrack = round((0:1/optitrack.fs:(numSamplesSync-1)/optitrack.fs)'*1000);

for nT = 1:length(TimeUWBRoundedToFSduration)
    idx = find(TimeUWBRoundedToFSduration(nT)==data.TimestampsOptitrack);
    if isempty(idx)
        error([newline mfilename ': ' newline ...
            blanks(30) ': LOOK HERE' newline ...
            blanks(30) 'mismatch between UWB and Optitrack, should not happen!' newline]);
    end
    data.CoordinatesOptitrack_TimestampsUWB(nT,1:3) = optitrack.Tag.Coordinates(idx(1),:)*10; %*10 to go from cm to mm
end
data.TimestampsUWBalignedWithOptitrack = TimeUWBRoundedToFSduration;
end


function larsson = executeTrilaterationsLarsson(data)
for nR = 1:length(data.Distances)
    try
        larsson(nR,1:3) = solver_opttrilat(data.AnchorPositions,data.Distances(nR,:))';
    catch err
        warning([err.message ', index: ' num2str(nR)])
    end
end
end