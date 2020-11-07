% Analysis for WMPM app data (V23+) with acc and gyro data
function [RotVelocity,relativeCoordinates] = ...
    RS_WMPM_app(apCsvFileRS, blPlotVal)

if not(exist(apCsvFileRS,'file'))
    error([newline mfilename ': ' newline 'CSV file does not exist!' newline]);
end
if not(exist('blPlotVal','var'))
    blPlotVal = false;
end

initAndAddNeededPaths();
[name,~,timestamp,~,gyro] = readCSVdata(apCsvFileRS);
wcspec = getDefaultWheelChairsSpecs();

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

doubleIdxFrame = diff(frameTimeRaw) == 0;
doubleIdxWheel = diff(wheelTimeRaw) == 0;
frameTimeRaw(doubleIdxFrame) = [];
frameGyroRaw(doubleIdxFrame) = [];
wheelTimeRaw(doubleIdxWheel) = [];
wheelGyroRaw(doubleIdxWheel) = [];

vecTime = 0:1/fs:max(frameTimeRaw)-0.5; %0.5 to avoid issues due to different signal lengths
RotVelocity.frame = interp1(frameTimeRaw,frameGyroRaw,vecTime)';
RotVelocity.wheel = -interp1(wheelTimeRaw,wheelGyroRaw,vecTime)'; % mind the minus sign!

% Calculate speed based on wheel rotation
whRoSpeedTotCorrected = RotVelocity.wheel-tand(wcspec.camberAngle).*RotVelocity.frame*cosd(wcspec.camberAngle);
whSpeedTot = whRoSpeedTotCorrected*wcspec.wheelCirDeg;
whSpeedTot = makeNaNZero(whSpeedTot);
RotVelocity.frame = makeNaNZero(RotVelocity.frame);

%%%%%% MIND THIS OPTION IS SET TO EXTRACT FOWRARD ACCELERATION FROM WHEELSPEED!
frAccTot = diff(whSpeedTot)*fs;% calculate frame acceleration based on wheel speed

% calculate frame centre speed
frSpeedTot = whSpeedTot - (tand(RotVelocity.frame/fs)*wcspec.wheelBase/2)*fs; %%% MIND the change in sign!
frSpeedTot = makeNaNZero(frSpeedTot);

startFrame = 1; % change if required or use in a loop for section analysis
endFrame = length(frAccTot)-1;

% crop signal for section analysis
frAcc = frAccTot(startFrame:endFrame,:);
frSpeedCropped = frSpeedTot(startFrame:endFrame,:);
frRoSpeedCropped = RotVelocity.frame(startFrame:endFrame,:);

frDispl = cumtrapz(frSpeedCropped)/fs;
frAccWheels = diff(frSpeedCropped)*fs;
frRoAng = cumtrapz(frRoSpeedCropped)/fs;
frRoAcc = diff(frRoSpeedCropped)*fs;

relativeCoordinates.x = cumtrapz(diff([0;frDispl]).*sind((cumtrapz(frRoSpeedCropped)/fs)));
relativeCoordinates.y = cumtrapz(diff([0;frDispl]).*cosd((cumtrapz(frRoSpeedCropped)/fs)));

if blPlotVal
    plotWheelFrameROTATIONALspeeds(RotVelocity.frame,RotVelocity.wheel);
    figure('units','normalized','outerposition',[0.1 0.1 0.8 0.8]);
    plot(relativeCoordinates.x,relativeCoordinates.y)
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
end

function [name,serial,timestamp,acc,gyro] = readCSVdata(apCsvFileRS)
ap.measurement = checkNameOfCSVFile(apCsvFileRS);
dataArray = importWMPMcsvData(ap.measurement);
[name,serial,timestamp,acc,gyro] = separateDataInVariables(dataArray);
end

function filename = checkNameOfCSVFile(apCsvFile)
[path,file] = fileparts(apCsvFile);
postfix = ' – IMU.csv';
dashSymbol = ' – ';
filenameRight = [extractBefore(file,dashSymbol) dashSymbol ...
    extractBefore(extractAfter(file,dashSymbol),dashSymbol) ...
    postfix];
filename = fullfile(path,filenameRight);
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

function plotWheelFrameROTATIONALspeeds(frameRotVel,wheelRotVel)
figure
subplot(2,1,1)
plot(frameRotVel)
title('Frame rotational speed'); xlabel('time [s]');
subplot(2,1,2)
plot(wheelRotVel)
title('Wheel rotational speed'); xlabel('time [s]');
end

function input = makeNaNZero(input)
input(isnan(input)) = 0;
end
