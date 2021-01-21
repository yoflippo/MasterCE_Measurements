function simple3DPlotTagAnchorOptiPozyx_midterm()
close all; clc;
apThisFile = fileparts(mfilename('fullpath'));
cd(apThisFile);
neededFolder = findSubFolderPath(mfilename('fullpath'),'UWB','MEASUREMENTS_20200826');
cd(neededFolder);
cd('OPTITRACK');

files = dir(['**' filesep '*_4solver.mat']);
files = makeFullPathFromDirOutput(files);
load(files(1).fullpath);
plotTagAnchorMeasurement_midterm(data,data.pozyx.Tag);
end

