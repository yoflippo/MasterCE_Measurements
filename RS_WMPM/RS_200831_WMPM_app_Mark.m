% Analysis for WMPM app data (V23+) with acc and gyro data
function RS_200831_WMPM_app_Mark()

ap = initAndAddNeededPaths();
% ap.measurement = openCSVfileOfWMPM(ap);
ap.measurement = 'D:\Dropbox\TU\03_AFSTUDEREN\UWB\MATLAB\MEASUREMENTS\MEASUREMENT_DATA\MEASUREMENTS_20200826\WMPM_MEASUREMENTS\20200826T111752Z\RienkMark – 20200826T111752Z – IMU.csv';
dataArray = importWMPMcsvData(ap.measurement);
[name,~,timestamp,~,gyro] = separateDataInVariables(dataArray);
wcspec = getDefaultWheelChairsSpecs();

plotVal = 1;

% Convert to 100Hz datafile
fs = 100;
isFrame = ismember(name,'Frame');
isWheel = ismember(name,'Wheel');
frameTimeRaw = timestamp(isFrame)./1000;
frameStartIdx = find(frameTimeRaw>0,1);
frameTimeRaw(1:frameStartIdx-1) = [];

wheelTimeRaw = timestamp(isWheel)./1000;
wheelStartIdx = find(wheelTimeRaw>0,1);
wheelTimeRaw(1:wheelStartIdx-1) = [];

frameGyroRaw = gyro.z(isFrame(frameStartIdx:end));
wheelGyroRaw = gyro.x(isWheel(wheelStartIdx:end));

if plotVal
    figure
    plot(frameTimeRaw,frameGyroRaw)
    hold all
    plot(wheelTimeRaw,wheelGyroRaw)
end

doubleIdxexFrame = diff(frameTimeRaw) == 0;
doubleIdxexWheel = diff(wheelTimeRaw) == 0;
frameTimeRaw(doubleIdxexFrame) = [];
frameGyroRaw(doubleIdxexFrame) = [];
wheelTimeRaw(doubleIdxexWheel) = [];
wheelGyroRaw(doubleIdxexWheel) = [];

timeLineFull = 0:1/fs:max(frameTimeRaw)-0.5; %0.5 to avoid issues due to different signal lengths
frameRotationalSpeed = interp1(frameTimeRaw,frameGyroRaw,timeLineFull)';
wheelRotationalSpeed = -interp1(wheelTimeRaw,wheelGyroRaw,timeLineFull)'; % mind the minus sign!

if plotVal
    figure
    plot(timeLineFull,frameRotationalSpeed)
    hold all
    plot(timeLineFull,wheelRotationalSpeed)
end

% Calculate speed based on wheel rotation
whRoSpeedTotCorrected = wheelRotationalSpeed-tand(wcspec.camberAngle).*frameRotationalSpeed*cosd(wcspec.camberAngle);
whSpeedTot = whRoSpeedTotCorrected*wcspec.wheelCirDeg;
whSpeedTot(isnan(whSpeedTot)) = 0;
frameRotationalSpeed(isnan(frameRotationalSpeed)) = 0;

%%%%%% MIND THIS OPTION IS SET TO EXTRACT FOWRARD ACCELERATION FROM WHEELSPEED!
frAccTot = diff(whSpeedTot)*fs;% calculate frame acceleration based on wheel speed

% calculate frame centre speed
frSpeedTot = whSpeedTot - (tand(frameRotationalSpeed/fs)*wcspec.wheelBase/2)*fs; %%% MIND the change in sign!
frSpeedTot(isnan(frSpeedTot)) = 0;

startFrame = 1; % change if required or use in a loop for section analysis
endFrame = length(frAccTot)-1;

% crop signal for section analysis
frAcc = frAccTot(startFrame:endFrame,:);
frSpeedCropped = frSpeedTot(startFrame:endFrame,:);
frRoSpeedCropped = frameRotationalSpeed(startFrame:endFrame,:);

frDispl = cumtrapz(frSpeedCropped)/fs;
frAccWheels = diff(frSpeedCropped)*fs;
frRoAng = cumtrapz(frRoSpeedCropped)/fs;
frRoAcc = diff(frRoSpeedCropped)*fs;

if plotVal
    figure('units','normalized','outerposition',[0.1 0.1 0.8 0.8]);
    plot(cumtrapz(diff([0;frDispl]).*sind((cumtrapz(frRoSpeedCropped)/fs))),...
        cumtrapz(diff([0;frDispl]).*cosd((cumtrapz(frRoSpeedCropped)/fs))))
    axis equal
end
end



%% helper functions
function ap = initAndAddNeededPaths()
close all;
ap.helpercodeMeasurements = fullfile(fileparts(fileparts(mfilename('fullpath'))),'helpercode');
cd(ap.helpercodeMeasurements);
cd ..; cd ..;
ap.helpercode = fullfile(pwd,'helpercode');
addpath(genpath(ap.helpercodeMeasurements));
addpath(genpath(ap.helpercode));
ap.measurementData = findSubFolderPath(mfilename('fullpath'),'UWB','MEASUREMENTS_20200826');
end

function filename = openCSVfileOfWMPM(ap)
cd(ap.measurementData);
[file,path] = uigetfile(' * .csv');
filename = fullfile(path,file);
end

function dataArray = importWMPMcsvData(filename)
delimiter = ',';
startRow = 2;
formatSpec = '%C%f%f%f%f%f%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType',...
    'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError',...
    false, 'EndOfLine', '\r\n');
fclose(fileID);
end

function wcspec = getDefaultWheelChairsSpecs()
wcspec.wheelDiameter = 0.584;
wcspec.wheelBase = 0.52;
wcspec.camberAngle = 2;
wcspec.wheelCirDeg = wcspec.wheelDiameter*pi/360;
end

function [name,serial,timestamp,acc,gyro] = separateDataInVariables(dataArray)
name = dataArray{:, 1};
serial = dataArray{:, 2};
timestamp = dataArray{:, 3};
acc.x = dataArray{:, 4};
acc.y = dataArray{:, 5};
acc.z = dataArray{:, 6};
gyro.x = dataArray{:, 7};
gyro.y = dataArray{:, 8};
gyro.z = dataArray{:, 9};
end
