close all;
clear all;
clc;
cd(fileparts(mfilename('fullpath')))
addpath(genpath(fileparts(pwd)));
matfiles = dir('*.mat');
n = 2;
apfile = fullfile(matfiles(2).folder,matfiles(2).name);
load(apfile);
optitrackTag2UWBAntenna(optitrack);