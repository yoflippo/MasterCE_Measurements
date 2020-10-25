close all; clear variables; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)

%% Copy data to testfolder
nm.rawData = 'testdata';
nm.testData = 'datatested';
ap.rawData = fullfile(ap.thisFile,nm.rawData);
ap.testData = fullfile(ap.thisFile,nm.testData);

files = dir(ap.rawData);
files = files(~[files.isdir]);
files = files(contains({files.name},'.m'));

% Create function handle
nm.Cur = replace(nm.CurrFile,'_test','');
fh = @plotTagAnchor;

% Load MAT file
for nF = 1:length(files)
    load(fullfile(files(nF).folder,files(nF).name))
    
    
    
    %% Do some testing
    try
        fh(optitrack);
        %     assert(~isempty(dirs));
        %     assert(length(dirs) == 4);
        %
        %     assert(~isempty(stcFilesToKeep),['Test 1 of: ' mfilename ' Failed miserably']);
        %     disp(['Test 1 of: ' mfilename ' succeeded']);
    catch err
        err.message
        %% Clean up
        cd(nm.testData);
        rmpath(nm.testData);
        ff = dir();
        fclose('all');
        for n = 3:length(ff)
            if ~ff(n).isdir
                apff = fullfile(ff(n).folder,ff(n).name);
                delete(apff);
            else
                rmdir(ff(n).folder,'s');
            end
        end
        rmdir(nm.testData,'s');
    end
    pause
end
cd(ap.thisFile);


%% helper functions
function deleteAndMakeDir(dir,blKeepDir)
if exist(dir,'dir')
    rmdir(dir,'s');
end
if isequal(nargin,1)
    blKeepDir = true;
end
if blKeepDir
    mkdir(dir);
end
end