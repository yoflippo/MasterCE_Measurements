close all; clearvars; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)
addpath(genpath(ap.thisFile));
ap.measurementData = findSubFolderPath(mfilename('fullpath'),'UWB',...
    'MEASUREMENTS_20200826');
addpath(genpath(ap.measurementData));
nm.syncPoints = 'syncPoints.mat';

files_wmpm = findWMPMFiles(ap.measurementData);
files_opti = findOptitrackFiles(ap.measurementData);

if not(exist(nm.syncPoints,'file'))
    error([newline mfilename ': ' newline '<XXX>' newline]);
else
    load(nm.syncPoints);
end

for nF = 1:length(files_wmpm)
    currWMPM = files_wmpm(nF);
    currOPTI = files_opti(nF);
    try
        currWMPM.folder
        close all;
        [RotVel_WMPM,RelCoord_WMPM] = RS_WMPM_app(currWMPM.fullpath,true);
        [optitrackCoordinates] = loadAndPlotOptitrackData(currOPTI.fullpath,true);
        pause;
        %         checkSynchronisation(optitrackCoordinates,wheelRotationalSpeed,syncPoints(nF,:));
%         saveSynchronizedMATfile(optitrackCoordinates,RotVel_WMPM.wheel,syncPoints(nF,:));
    catch err
        error([files_wmpm(nF).fullpath newline err.message]);
    end
end

rmpath(genpath(ap.thisFile));


function f = findOptitrackFiles(ap)
f = findFilesWithExtension(ap,'mat');
f = f(contains({f.name},'RS_','IgnoreCase',true));
f = f(contains({f.name},'~','IgnoreCase',true));
f = f(contains({f.name},'optitrack','IgnoreCase',true));
f = makeFullPathFromDirOutput(f);
end


function f = findWMPMFiles(ap)
f = findFilesWithExtension(ap,'csv');
f = f(contains({f.name},'IMU','IgnoreCase',true));
f = f(not(contains({f.folder},'old','IgnoreCase',true)));
f = makeFullPathFromDirOutput(f);
end


function out = loadAndPlotOptitrackData(apMatFile,blPlotVal)
if exist(apMatFile,'file')
    load(apMatFile);
else
    error([newline mfilename ': ' newline 'File does not exist' newline]);
end

if not(exist('blPlotVal','var'))
    blPlotVal = false;
end

if not(exist('optitrack','var'))
    error([newline mfilename ': ' newline 'MAT File does not contain optitrack variable' newline]);
end

out.x = optitrack.Tag.Coordinates(:,1);
out.y = optitrack.Tag.Coordinates(:,2);
out.z = optitrack.Tag.Coordinates(:,3);
if blPlotVal
    figure;
    subplot(3,1,1); plot(out.x); title('x coordinates OPTITRACK'); xlabel('frames number');
    subplot(3,1,2); plot(out.y); title('y coordinates OPTITRACK'); xlabel('frames number');
    subplot(3,1,3); plot(out.z); title('z coordinates OPTITRACK'); xlabel('frames number');
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


function  checkSynchronisation(o,w,sync_wo)
oresultant = sqrt((o.x.^2) + (o.y.^2) + (o.z.^2));

oresultant(isnan(oresultant))=0;
w(isnan(w))=0;

oresultantCut = selectPortionOfBegin(sync_wo(2),oresultant);
wCut = selectPortionOfBegin(sync_wo(1),w);

oresultantCut = normalize(oresultantCut);
wCut = -normalize(wCut);

figure('units','normalized','outerposition',[0.5 0.5 0.5 0.5]);
subplot(5,1,1); plot(oresultant); title('x coordinates OPTITRACK');
subplot(5,1,2); plot(w); title('Wheel Rotational Speed');

[Xa,Ya,D] = alignsignals(oresultantCut,wCut);
subplot(5,1,3); plot(Xa); hold on; plot(Ya);

subplot(5,1,4);
plot(oresultant(sync_wo(2):end));
hold on;
disp(['make the WMPM sync moment: ' num2str(sync_wo(1)+D)]);
plot(w(sync_wo(1)+D:end));
title('With optional adjustment');

subplot(5,1,5);
plot(oresultant(sync_wo(2):end));
hold on;
plot(w(sync_wo(1):end));
title('Manual syncing');

    function out = selectPortionOfBegin(manualSyncMoment,data)
        someHigherIndex = manualSyncMoment + 0.1 * length(data);
        out = data(manualSyncMoment-200:roundn(someHigherIndex,2));
    end
end
