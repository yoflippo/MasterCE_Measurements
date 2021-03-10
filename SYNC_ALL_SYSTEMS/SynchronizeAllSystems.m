close all; clc;
[ap,nm,files,syncPoints] = init();
iterateOverFiles(files,syncPoints,ap)


function [ap,nm,files,syncPoints] = init()
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)

ap.synced = fullfile(ap.thisFile,'synced');
ap.measurementData = findSubFolderPath(mfilename('fullpath'),'UWB','MEASUREMENTS_20200826');
addpath(genpath(ap.thisFile));
addpath(genpath(ap.measurementData));

nm.syncPoints = 'syncPoints.mat';
nm.cutPoints = 'cutPoints.mat';
ap.syncPoints = fullfile(ap.thisFile,nm.syncPoints);
ap.cutPoints = fullfile(ap.thisFile,nm.cutPoints);

files.wmpm = findWMPMFiles(ap.measurementData);
files.opti = findOptitrackFiles(ap.measurementData);
files.uwb = findUWBFiles(ap.measurementData);

if not(exist(nm.syncPoints,'file'))
    error([newline mfilename ': ' newline 'syncPoints.mat not found or does not exist' newline]);
else
    syncPoints = load(nm.syncPoints);
    syncPoints = syncPoints.syncPoints;
end
end


function iterateOverFiles(files,syncPoints,ap)
for nF = 1:length(files.wmpm)
    currWMPM = files.wmpm(nF);
    currOPTI = files.opti(nF);
    try
        currWMPM.folder
        close all;
        [WMPM.rotationvelocity,WMPM.coordinates,WMPM.framevel, WMPM.acc] = RS_WMPM_app(currWMPM.fullpath);
        [coordOpti, sOptitrack] = loadAndPlotOptitrackData(currOPTI.fullpath);
        sUWB = applyLarssonToUWBwithOptitrack(sOptitrack,files.uwb(nF));
        [opti,wmpm,uwb] = syncOptiUwbWmpm(coordOpti,WMPM,sUWB,syncPoints(nF,:));
        opti.syncPoints = syncPoints(nF,:);
        
        %         checkSynchronisationCoarse(opti,wmpm,uwb);
        %         checkSynchronisationFineGrained(opti,wmpm,syncPoints(nF,:))
        [opti,wmpm,uwb] = addCutIndices(opti,wmpm,uwb,ap,nF);
        saveSyncedDataToMATfile(opti,wmpm,uwb,replace(currOPTI.name,'_optitrack',''),sOptitrack);
    catch err
        error([files.wmpm(nF).fullpath newline err.message]);
    end
end
end


function f = findOptitrackFiles(ap)
f = findFilesWithExtension(ap,'mat');
f = f(contains({f.name},'RS_','IgnoreCase',true));
f = f(contains({f.name},'~','IgnoreCase',true));
f = f(contains({f.name},'optitrack','IgnoreCase',true));
f = makeFullPathFromDirOutput(f);
end


function f = findUWBFiles(ap)
f = findFilesWithExtension(ap,'mat');
f = f(contains({f.name},'RS_','IgnoreCase',true));
f = f(contains({f.name},'~','IgnoreCase',true));
f = f(contains({f.name},'pozyx','IgnoreCase',true));
f = makeFullPathFromDirOutput(f);
end


function f = findWMPMFiles(ap)
f = findFilesWithExtension(ap,'csv');
f = f(contains({f.name},'IMU','IgnoreCase',true));
f = f(not(contains({f.folder},'old','IgnoreCase',true)));
f = makeFullPathFromDirOutput(f);
end


function [coordinates, optitrack] = loadAndPlotOptitrackData(apMatFile,blPlotVal)
if exist(apMatFile,'file')
    optitrack = load(apMatFile);
    optitrack = optitrack.optitrack;
else
    error([newline mfilename ': ' newline 'File does not exist' newline]);
end

if not(exist('blPlotVal','var'))
    blPlotVal = false;
end

if not(exist('optitrack','var'))
    error([newline mfilename ': ' newline 'MAT File does not contain optitrack variable' newline]);
end

coordinates.x = optitrack.Tag.Coordinates(:,1)*10;
coordinates.y = optitrack.Tag.Coordinates(:,2)*10;
coordinates.z = optitrack.Tag.Coordinates(:,3)*10;

coordinates.notfilled.x = optitrack.Tag.NotFilled.Coordinates(:,1)*10;
coordinates.notfilled.y = optitrack.Tag.NotFilled.Coordinates(:,2)*10;
coordinates.notfilled.z = optitrack.Tag.NotFilled.Coordinates(:,3)*10;

if blPlotVal
    figure;
    scatter(coordinates.x,coordinates.y,'r'); hold on;
    scatter(coordinates.notfilled.x,coordinates.notfilled.y,'g')
%     subplot(3,1,1); plot(coordinates.x); title('x coordinates OPTITRACK'); xlabel('frames number');
%     subplot(3,1,2); plot(coordinates.y); title('y coordinates OPTITRACK'); xlabel('frames number');
%     subplot(3,1,3); plot(coordinates.z); title('z coordinates OPTITRACK'); xlabel('frames number');
end
end


function out = getGinputsStartEnd(number)
if not(exist('number','var'))
    number = 2;
elseif not(isnumeric(number))
    number = 2;
end
out.start = ginput(number);
out.end = ginput(number);
end


function  checkSynchronisationFineGrained(opti,wpm,sync_wo)
oresultant = sqrt((opti.x.^2) + (opti.y.^2));
oresultantCut = selectPortionOfBegin(sync_wo(2),oresultant);
oresultantCut = normalize(oresultantCut);

wresultant = sqrt((wpm.coordinates.x.^2) + (wpm.coordinates.y.^2));
wCut = selectPortionOfBegin(sync_wo(1),wresultant);
wCut = normalize(wCut);

figure('units','normalized','outerposition',[0.5 0.5 0.5 0.5]);
subplot(5,1,1); plot(oresultant); title('resultant coordinates OPTITRACK');
subplot(5,1,2); plot(wresultant); title('resultant coordinates WMPM');

[Xa,Ya,D] = alignsignals(oresultantCut,wCut);
subplot(5,1,3); plot(Xa); hold on; plot(Ya); title('With alignsignal()');

subplot(5,1,4);
plot(normalize(oresultant(sync_wo(2):end)));
hold on;
disp(['make the WMPM sync moment: ' num2str(sync_wo(1)+D)]);
plot(normalize(wresultant(sync_wo(1)+D:end))); title('With optional adjustment');

subplot(5,1,5);
plot(normalize(oresultant(sync_wo(2):end)));
hold on;
plot(normalize(wresultant(sync_wo(1):end)));
title('Manual syncing');

    function out = selectPortionOfBegin(manualSyncMoment,data)
        someHigherIndex = manualSyncMoment + 0.15 * length(data);
        out = data(manualSyncMoment-100:roundn(someHigherIndex,2));
    end
end


function checkSynchronisationCoarse(opti,wmpm,uwb)
figure('units','normalized','outerposition',[0.1 0.1 0.7 0.7]);

subplot(3,1,1);
plot(opti.time,opti.coord.x); hold on;
plot(opti.time,opti.coord.y);
plot(opti.time,opti.coord.z); title('Coordinates form Optitrack');
grid on; grid minor;

subplot(3,1,2);
plot(wmpm.time,wmpm.coord.x); hold on;
plot(wmpm.time,wmpm.coord.y); title('Coordinates of gyroscope in wheel & base');
grid on; grid minor;

subplot(3,1,3);
plot(uwb.time, uwb.coord.x); hold on;
plot(uwb.time, uwb.coord.y);
plot(uwb.time, uwb.coord.z); title('Coordinates form UWB');
ylim(get(gca,'YLim'))
grid on; grid minor;
end


function [opti,wmpm,uwb2] = syncOptiUwbWmpm(opti,wmpm,uwb,sync)
opti.coord = cutFromBeginOfStruct(opti,sync(2));
opti.notfilled.coord = cutFromBeginOfStruct(opti.notfilled,sync(2));
opti.time = getTimeVector(100,opti.coord.x);

[uwb2.coord, cutIdx] = cutUWBbasedOnOptitrackTiming(100,sync(2), ...
    uwb.TimestampsUWBalignedWithOptitrack,uwb.coordinatesUWBlarsson);

wmpm.coord = cutFromBeginOfStruct(wmpm.coordinates,sync(1));
wmpm.velframe = wmpm.framevel(sync(1):end);
wmpm.angularRate = wmpm.rotationvelocity.frame(sync(1):end);
wmpm.time  = getTimeVector(100,wmpm.coord.x);

timeVectorUWB = uwb.TimestampsUWBalignedWithOptitrack(cutIdx:end)-uwb.TimestampsUWBalignedWithOptitrack(cutIdx);
uwb2.time = timeVectorUWB/1000;
uwb2.rawdata = uwb;
uwb2.rawdata.cutIdx = cutIdx;
end


function out = cutFromBeginOfStruct(sSignal,beginCutPoint)
if isfield(sSignal,'x')
    out.x = sSignal.x(beginCutPoint:end);
end
if isfield(sSignal,'y')
    out.y = sSignal.y(beginCutPoint:end);
end
if isfield(sSignal,'z')
    out.z = sSignal.z(beginCutPoint:end);
end
end


function [cutData,cutIdx] = cutUWBbasedOnOptitrackTiming(fsOpti,syncOpti,uwbTime,uwbCoordinates)
timeOpti = 1000/fsOpti * syncOpti;
findSmallestTimeDifference = abs(uwbTime-timeOpti);
[~,minIndex] = min(findSmallestTimeDifference);
cutData = cutFromBeginOfStruct(makeXYZstruct(uwbCoordinates),minIndex);
cutIdx = minIndex;
end

function sxyz = makeXYZstruct(matrix)
[r,c] = size(matrix);
if not(r==3 || c==3)
    error([newline mfilename ': ' newline ...
        blanks(30) ': LOOK HERE' newline ...
        blanks(30) 'Not a matrix with dimension of 3' newline]);
end
if c > r
    mat = matrix';
else
    mat = matrix;
end
sxyz.x = mat(:,1);
sxyz.y = mat(:,2);
sxyz.z = mat(:,3);
end


function saveSyncedDataToMATfile(opti,wmpm,uwb,matfile,sOpti)
cd ..
mkdirIf('synced');
cd('synced');
save(matfile);
end


function [opti,wmpm,uwb] = addCutIndices(opti,wmpm,uwb,ap,nF)
cp = load(ap.cutPoints);
time_cuts = cp.cutPoints(nF,:);

opti.cleanSignalTimeIdx = GetBothIndices(opti,time_cuts);
wmpm.cleanSignalTimeIdx = GetBothIndices(wmpm,time_cuts);
uwb.cleanSignalTimeIdx = GetBothIndices(uwb,time_cuts);

    function idxs = GetBothIndices(sStruct,time_cuts)
        idxBeginSignal = findClosestIdx(sStruct.time,time_cuts(1));
        idxEndSignal = findClosestIdx(sStruct.time,time_cuts(2));
        idxs = [idxBeginSignal idxEndSignal];
    end

    function idx = findClosestIdx(timeVector,timestamp)
        if not(isnan(timestamp))
            timeDiff = abs(timeVector-timestamp);
            smallestTimeDiff = min(timeDiff);
            idx = find(timeDiff==smallestTimeDiff);
        else
            idx = length(timeVector);
        end
        idx = idx(1); % In case multiples are found
    end
end