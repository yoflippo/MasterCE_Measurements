close all;
clear all;
clc;
cd(fileparts(mfilename('fullpath')))
addpath(genpath(fileparts(pwd)));
matfiles = dir('*.mat');
apfile = fullfile(matfiles(1).folder,matfiles(1).name);
load(apfile);
optitrackAnchor2UWBAntenna(optitrack,matfiles(1));