% Analysis for WMPM app data (V23+) with acc and gyro data
close all
clear all
% Import data from text file.
plotVal=1;
cd(findSubFolderPath(mfilename('fullpath'),'UWB','MEASUREMENTS_20200826'));
[file,path] = uigetfile('*.csv');
filename = fullfile(path,file);

% filename=  'C:\Users\RS\OneDrive\Project Wheelchair Recordings\RienkMark\Recordings\20200826T112145Z\RienkMark – 20200826T112145Z – IMU.csv';
% Initialize variables.
delimiter = ',';
startRow = 2;

minRoSpeed=10; %
maxSpeed=6;
maxRoSpeed=400;
fcLpRo=2;
fcLpMo=2;
fs=100;
winStable=round(fs/4);% is one of the settings
sport=3;
excelOutput=[];

% Format for each line of text:
%   column1: categorical (%C)
%	column2: double (%f)
%   column3: double (%f)
%	column4: categorical (%C)
%   column5: categorical (%C)
%	column6: categorical (%C)
%   column7: double (%f)
%	column8: double (%f)
%   column9: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%C%f%f%f%f%f%f%f%f%[^\n\r]';

% Open the text file.
fileID = fopen(filename,'r');

% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'TextType', 'string', 'EmptyValue', NaN, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

% Close the text file.
fclose(fileID);

% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

% Allocate imported array to column variable names
name = dataArray{:, 1};
serial = dataArray{:, 2};
timestamp = dataArray{:, 3};
accx = dataArray{:, 4};
accy = dataArray{:, 5};
accz = dataArray{:, 6};
gyrox = dataArray{:, 7};
gyroy = dataArray{:, 8};
gyroz = dataArray{:, 9};

% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

% Convert to 100Hz datafile
frameInd=find(ismember(name,'Frame')==1);
wheelInd=find(ismember(name,'Wheel')==1);
frameTimeRaw=timestamp(frameInd)./1000;
frameStartInd=find(frameTimeRaw>0,1);
frameTimeRaw(1:frameStartInd-1)=[];

wheelTimeRaw=timestamp(wheelInd)./1000;
wheelStartInd=find(wheelTimeRaw>0,1);
wheelTimeRaw(1:wheelStartInd-1)=[];

frameGyroRaw=gyroz(frameInd(frameStartInd:end));
wheelGyroRaw=gyrox(wheelInd(wheelStartInd:end));

if plotVal
    figure
    plot(frameTimeRaw,frameGyroRaw)
    hold all
    plot(wheelTimeRaw,wheelGyroRaw)
end

doubleIndexFrame=find(diff(frameTimeRaw)==0);
doubleIndexWheel=find(diff(wheelTimeRaw)==0);

frameTimeRaw(doubleIndexFrame)=[];
frameGyroRaw(doubleIndexFrame)=[];
wheelTimeRaw(doubleIndexWheel)=[];
wheelGyroRaw(doubleIndexWheel)=[];

timeLineFull=0:1/fs:max(frameTimeRaw)-0.5; %0.5 to avoid issues due to different signal lengths
frameRotationalSpeed=interp1(frameTimeRaw,frameGyroRaw,timeLineFull)';
wheelRotationalSpeed=-interp1(wheelTimeRaw,wheelGyroRaw,timeLineFull)'; % mind the minus sign!

if plotVal
    figure
    plot(timeLineFull,frameRotationalSpeed)
    hold all
    plot(timeLineFull,wheelRotationalSpeed)
end
% GENERAL CODE
% INPUT SIGNALS
% frAccForward
% frameRotationalSpeed
% wheelRotationalSpeed
% timeLineFull

% Required input vars %%%%%%%%%%%%%%% Check!%%%%%%%%%%%%%%%%
wheelDiam=0.584;
wheelBase=0.52;
camberAngle=2;
wheelCirDeg=wheelDiam*pi/360;

% Analysis settings
minSpeed=0.1; % Minimal speed for analysis
minRoSpeed=10; % Minimal rotational speed
fcLpMo=2; % LowPass cut off for movement
freqZoneThreshold = 0.5; % Minimal time in speedzone for frequency

%frame rotational speed
frRoSpeedTot=frameRotationalSpeed;
%wheel rotational speed
whRoSpeedTot=wheelRotationalSpeed;
% Calculate speed based on wheel rotation
whRoSpeedTotCorrected = whRoSpeedTot-tand(camberAngle).*frRoSpeedTot*cosd(camberAngle);
whSpeedTot= whRoSpeedTotCorrected*wheelCirDeg;

% remove NaN's
try
    frAccTot(find(isnan(frAccTot)))=0;
end
try
    frRoSpeedTot(find(isnan(frRoSpeedTot)))=0;
end
try
    whSpeedTot(find(isnan(whSpeedTot)))=0;
end

% %%%%% MIND THIS OPTION IS SET TO EXTRACT FOWRARD ACCELERATION FROM WHEELSPEED!
frAccTot=diff(whSpeedTot)*fs;% calculate frame acceleration based on wheel speed

% calculate frame centre speed
frSpeedTot = whSpeedTot - (tand(frRoSpeedTot/fs)*wheelBase/2)*fs; %%% MIND the change in sign!
% remove NaN's
try
    frSpeedTot(find(isnan(frSpeedTot)))=0;
end

% START SECTION ANALYSIS
% input selection frames
startFrame = 1; % change if required or use in a loop for section analysis
endFrame = length(frAccTot)-1;

% crop signal for section analysis
frAcc=frAccTot(startFrame:endFrame,:);
frSpeed=frSpeedTot(startFrame:endFrame,:);
frRoSpeed=frRoSpeedTot(startFrame:endFrame,:);
timeLine=timeLineFull(startFrame:endFrame);

% calculate basic derived signals
frDispl=cumtrapz(frSpeed)/fs;
frAccWheels=diff(frSpeed)*fs;
frRoAng=cumtrapz(frRoSpeed)/fs;
frRoAcc=diff(frRoSpeed)*fs;

if plotVal
    figure('units','normalized','outerposition',[0.1 0.1 0.8 0.8]);
    plot(cumtrapz(diff([0;frDispl]).*sind((cumtrapz(frRoSpeed)/fs))),...
        cumtrapz(diff([0;frDispl]).*cosd((cumtrapz(frRoSpeed)/fs))))
    axis equal
    hold all
end