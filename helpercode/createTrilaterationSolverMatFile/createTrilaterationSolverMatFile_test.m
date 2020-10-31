close all; clear variables; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)

%% Copy data to testfolder
nm.rawData = 'rawdata';
ap.rawData = fullfile(ap.thisFile,nm.rawData);

files = dir(ap.rawData);
files = files(~[files.isdir]);
files = files(contains({files.name},'.m'));
files = files(contains({files.name},'optitrack'));

%% Do some testing
try
    for nF = 1:length(files)
       ap = fullfile(files(nF).folder,files(nF).name);
       createTrilaterationSolverMatFile(ap);
        
    end
    
%     assert(~isempty(dirs));
%     assert(length(dirs) == 4);
% 
%     assert(~isempty(stcFilesToKeep),['Test 1 of: ' mfilename ' Failed miserably']);
%     disp(['Test 1 of: ' mfilename ' succeeded']);
catch err
    err.message

end



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