function convertC3D_to_MAT(apFolder)

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

files = dir(['**' filesep '*.c3d']);

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
    
    optitrack.name = files(i).name;
    optitrack.path = pathName;
    optitrack = fillGapsOptitrack(optitrack); %%%%%%%%%% 
    
    % Find/Cleanup UWB A/T data
    optitrack = optitrackAnchor2UWBAntenna(optitrack,dir(apRawMat));
    optitrack =  optitrackTag2UWBAntenna(optitrack);
    save(apRawMat,'optitrack');
end

end