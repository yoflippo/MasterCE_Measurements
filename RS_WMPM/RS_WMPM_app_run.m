close all; clearvars; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)
addpath(genpath(ap.thisFile));
ap.measurementData = findSubFolderPath(mfilename('fullpath'),'UWB',...
    'MEASUREMENTS_20200826');
addpath(genpath(ap.measurementData));

files_wmpm = findWMPMFiles(ap.measurementData);
files_opti = findCorrespondingOptitrackFiles(ap.measurementData);

for nF = 1:length(files_wmpm)
    currWMPM = files_wmpm(nF);
    currOPTI = files_opti(nF);
    try
        currWMPM.folder
        RS_WMPM_app(currWMPM.fullpath);
        distFig
        syncPoints(nF).WMPM = getGinputsStartEnd();
         
        loadAndPlotOptitrackData(currOPTI.fullpath)
        distFig
        syncPoints(nF).OPTI.end = getGinputsStartEnd();
    catch err
        error([files_wmpm(nF).fullpath newline err.message]);
    end
end

rmpath(genpath(ap.thisFile));


function f = findCorrespondingOptitrackFiles(ap)
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

function loadAndPlotOptitrackData(apMatFile)
if exist(apMatFile,'file')
    load(apMatFile);
else
    error([newline mfilename ': ' newline 'File does not exist' newline]);
end

if not(exist('optitrack','var'))
    error([newline mfilename ': ' newline 'MAT File does not contain optitrack variable' newline]);
end

x = optitrack.Tag.Coordinates(:,1);
y = optitrack.Tag.Coordinates(:,2);
z = optitrack.Tag.Coordinates(:,3);

figure;
subplot(3,1,1);
plot(x); title('x coordinates OPTITRACK'); xlabel('frames number');
subplot(3,1,2);
plot(y); title('y coordinates OPTITRACK'); xlabel('frames number');
subplot(3,1,3);
plot(z); title('z coordinates OPTITRACK'); xlabel('frames number');
end

function out = getGinputsStartEnd(number)
if not(exist('number','var'))
    number = 2;
end

if not(isnumeric(number))
    number = 2;
end

out.start = ginput(number);
out.end = ginput(number);
end
