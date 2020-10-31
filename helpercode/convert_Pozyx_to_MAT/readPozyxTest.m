clearvars;
close all;
clc;

cd(fileparts(mfilename('fullpath')));
addpath(genpath(fileparts(mfilename('fullpath'))));

cd('test')
files = dir;
files([files.isdir])=[]; %only files

data = readPozyx(fullfile(files(1).folder,files(1).name));

filteredData = filterAnchors(data);

