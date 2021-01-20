function getSpeedFromOptitrack_run(keepPrefix,apFolder)
close all; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));

if ~exist('apFolder','var')
    cd(ap.thisFile)
    ap.measurements = findSubFolderPath(pwd,'UWB','MEASUREMENT_DATA');
    cd(ap.measurements);
    addpath(genpath(ap.measurements));
else
    if ~exist(apFolder,'dir')
        error([newline mfilename ': ' newline 'Path does not exist' newline]);
    end
    cd(apFolder)
end

files = dir(['**' filesep '*_4solver.mat']);
files = files(~[files.isdir]);
if exist('keepPrefix','var')
    files(~contains({files.name},keepPrefix)) = [];
end

try
    for nF = 1:length(files)
        currFile = fullfile(files(nF).folder,files(nF).name);
        load(currFile);
        if not(isfield(data,'vel'))
            vel = getSpeedFromOptitrack(currFile);
            data.vel = vel;
            save(currFile,'data');
            clear data currFile;
        end
    end
catch err
    warning(err.message)
end
cd(ap.thisFile);

end
