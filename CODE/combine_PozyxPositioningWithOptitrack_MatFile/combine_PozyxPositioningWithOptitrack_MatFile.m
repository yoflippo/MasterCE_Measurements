function combine_PozyxPositioningWithOptitrack_MatFile(apOptitrackMat,apPozyxMat)

[file.Opti.folder,file.Opti.name,~] = fileparts(apOptitrackMat);
file.Opti.full = fullfile(file.Opti.folder,[file.Opti.name '.mat']);
if ~exist('apPozyxMat','var') %assume it is in the same directory
    file.Pozyx.folder = file.Opti.folder;
    file.Pozyx.name = replace(file.Opti.name,'optitrack','pozyx');
    file.Pozyx.full = fullfile(file.Pozyx.folder,[file.Pozyx.name '.mat']);
else
    [file.Pozyx.folder,file.Pozyx.name,~] = fileparts(apPozyxMat);
    file.Pozyx.full = fullfile(file.Pozyx.folder,[file.Pozyx.name '.mat']);
end

if ~exist(file.Pozyx.full,'file') || ~exist(file.Opti.full,'file')
    keyboard
    error([newline mfilename ': ' newline 'Mat Files not found!' newline]);
end

load(file.Pozyx.full);
load(file.Opti.full);
if ~(exist('optitrack','var') && exist('pozyx','var'))
    error([newline mfilename ': ' newline 'The right fields are not present!' newline]);
end

%% Create the needed struct fields:

% data.AnchorPositions
data.AnchorPositions = cell2mat(optitrack.Anchors.UWB_Antenna')*10; %*10 to go from cm to mm

%% d
try
    % round to nearest 10 to find a match in optitrack time
    timesRoundNears = roundn([pozyx.Time],1);
    
    %% data.TagPositions
    % Create Optitrack time vector
    numSamplesSync = length(optitrack.Tag.Coordinates);
    data.TagPositionsTime = round((0:1/optitrack.fs:(numSamplesSync-1)/optitrack.fs)'*1000);
    
    for nT = 1:length(timesRoundNears)
        idx = find(timesRoundNears(nT)==data.TagPositionsTime);
        if isempty(idx)
%             keyboard % something is wrong
            return;
        end
        data.TagPositions(nT,1:3) = optitrack.Tag.Coordinates(idx(1),:)*10; %*10 to go from cm to mm
    end
    
    % Save original data JUST IN CASE
    data.optitrack = optitrack;
    data.pozyx = pozyx;
    
    %% Save the data in an MAT file
    save(replace(file.Opti.full,'_optitrack','_4solver'),'data');
catch err
    warning(err.message);
%   keyboard
end
end

