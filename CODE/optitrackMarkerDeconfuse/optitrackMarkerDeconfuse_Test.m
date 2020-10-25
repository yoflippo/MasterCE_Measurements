close all; clear variables; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)

%% Copy data to testfolder
nm.testData = 'testdata';
ap.testData = fullfile(ap.thisFile,nm.testData);

%% Clean the files that need to be test
files = dir(ap.testData);
files = files(contains({files.name},'.mat'));

%% Do some testing
try
    for nF = 1:length(files)
        currFile = fullfile(files(nF).folder,files(nF).name);
        ap.fullfile{nF} = currFile;
        
        load(currFile)
        idxTags = findIdxUwbTags(optitrack.names);
        dcf = optitrackMarkerDeconfuse(optitrack.coordinatesFilled(idxTags));
    end
catch err
    error([newline mfilename ': ' newline err.message newline]);
end
clear currFile nF



function [idxTags] = findIdxUwbTags(names)
idxTags = find(contains(names,'Tag'));
end