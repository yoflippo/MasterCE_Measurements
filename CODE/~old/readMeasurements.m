function [outputArg1,outputArg2] = readMeasurements(inputArg1,inputArg2)



cd(fileparts(mfilename('fullpath')));
addpath(genpath('../'));
[fileName pathName] = uigetfile('.c3d');

[coordinaten, namen, ~, fs, nSamples, unit, ~] = ReadC3DOptitrackFunction(pathName, fileName);


end

