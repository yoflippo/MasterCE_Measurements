function plotTagAnchorChoose()
close all;
cd(fileparts(mfilename('fullpath')));
fh = @plotTagAnchor;
cd(findSubFolderPath(mfilename('fullpath'),'UWB','MEASUREMENTS_20200826'));
[file,path] = uigetfile('*.mat');
load(fullfile(path,file));
fh(optitrack);
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
