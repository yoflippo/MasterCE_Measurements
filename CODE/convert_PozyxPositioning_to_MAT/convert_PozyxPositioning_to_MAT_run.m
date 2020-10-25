function convert_PozyxPositioning_to_MAT_run()
close all; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));

%% 1-2 TEST
cd(ap.thisFile)
nm.testData = 'DATA_TEST';
ap.testData = fullfile(ap.thisFile,nm.testData);

%% 2-2 REAL
cd(findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA'));

files = dir('**');
files = files(~[files.isdir]);
files = files(contains({files.name},'.txt'));
files(~contains({files.name},'PFST_')) = [];

%% Convert
try
    for nF = 1:length(files)
        curr.file = fullfile(files(nF).folder,files(nF).name);
        convert_PozyxPositioning_to_MAT(curr.file)
    end
catch err
    warning(err.message);
end

cd(ap.thisFile);
end