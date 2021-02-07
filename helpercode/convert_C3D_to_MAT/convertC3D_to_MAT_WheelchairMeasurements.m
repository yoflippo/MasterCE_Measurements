function convertC3D_to_MAT_WheelchairMeasurements(apFolder)

if ~exist('apFolder','var')
    apThisFile = fileparts(mfilename('fullpath'));
    cd(apThisFile);
    cd(findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA'));
else
    if ~exist(apFolder,'dir')
        error([newline mfilename ': ' newline 'Path does not exist' newline]);
    end
    cd(apFolder);
end

files = dir('**\*.c3d');
for i = 1:length(files)
    pathName = [files(i).folder filesep];
    fileName = files(i).name;
    apRawMat = fullfile(pathName,replace(fileName,'.c3d','_optitrack.mat'));
    if not(exist(apRawMat,'file'))
        optitrack.name = files(i).name;
        optitrack.path = pathName;
        [optitrack.coordinates, optitrack.names, ~, optitrack.fs, ...
            optitrack.nSamples, optitrack.unit, ~] = ReadC3DOptitrackFunction(pathName, fileName);
        
        % Cut to sync start/stop
        optitrack = cutDataToSyncMoment(optitrack);
        
        % Save processed data
        save(apRawMat,'optitrack');
    end
end
clear apRawMat i
close all;

%% Do more computational stuff
% Read the previously saved cut files
files = dir(['**' filesep '*_optitrack.mat']);
for i = 1:length(files)
    clear optitrack
    pathName = [files(i).folder filesep];
    fileName = files(i).name;
    apRawMat = fullfile(pathName,fileName);
    load(apRawMat);
    
%     if not(isfield(optitrack,'Tag'))
        optitrack.name = files(i).name;
        optitrack.path = pathName;
        optitrack = fillGapsOptitrack(optitrack); %%%%%% FILLED NOT FILLED
        
        % Find/Cleanup UWB A/T data
        optitrack = optitrackAnchor2UWBAntenna(optitrack,dir(apRawMat));
        optitrack =  optitrackTag2UWBAntennaWheelchairTests(optitrack,'RigidBodyTag');
        save(apRawMat,'optitrack');
%     end
end

end

% FINDSUBFOLDERPATH
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)

% $Revision: 0.0.0 $  $Date: 2020-09-11 $
% Creation of this function.

function [output] = findSubFolderPath(absolutePath,rootFolder,nameFolder)

if ~contains(absolutePath,rootFolder)
    error([newline mfilename ': ' newline 'Rootfolder not within absolutePath' newline]);
end
startDir = fullfile(extractBefore(absolutePath,rootFolder),rootFolder);
dirs = dir([startDir filesep '**' filesep '*']);
dirs(~[dirs.isdir])=[];
dirs(contains({dirs.name},'.'))=[];
dirs(~contains({dirs.name},nameFolder))=[];
if length(dirs)>1
    warning([newline mfilename ': ' newline 'Multiple possible folders found' newline]);
    output = dirs;
end
output = fullfile(dirs(1).folder,dirs(1).name);
end
