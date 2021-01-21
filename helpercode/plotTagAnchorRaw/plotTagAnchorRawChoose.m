function plotTagAnchorRawChoose()
close all;
cd(fileparts(mfilename('fullpath')));
fh = @plotTagAnchorRaw;
neededFolder = findSubFolderPath(mfilename('fullpath'),'UWB','MEASUREMENTS_20200826');
cd(neededFolder);
[file,path] = uigetfile('*.mat');
load(fullfile(path,file));
disp(file);
fh(optitrack);
end
