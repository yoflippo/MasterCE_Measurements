function createTrilaterationSolverMatFile_run(apFolder)

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



% Read the previously saved cut files
files = dir('**\*_optitrack.mat');
for i = 1:length(files)
    pathName = [files(i).folder filesep];
    fileName = files(i).name;
    apRawMat = fullfile(pathName,fileName);
    if not(exist(apRawMat,'file'))
        createTrilaterationSolverMatFile(apRawMat);
    end
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


