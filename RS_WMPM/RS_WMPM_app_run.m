close all; clearvars; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)
addpath(genpath(ap.thisFile));
ap.measurementData = findSubFolderPath(mfilename('fullpath'),'UWB',...
    'MEASUREMENTS_20200826');

files = dir([ap.measurementData filesep '**' filesep '*.csv']);
files = files(contains({files.name},'IMU','IgnoreCase',true));
files = files(not(contains({files.folder},'old','IgnoreCase',true)));
files = makeFullPathFromDirOutput(files);

for nF = 1:length(files)
    try
        RS_WMPM_app(files(nF).fullpath);
        pause
    catch err
        error([files(nF).fullpath newline err.message]);
    end
end

rmpath(genpath(ap.thisFile));