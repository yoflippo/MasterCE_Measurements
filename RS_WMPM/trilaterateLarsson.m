function [locations] = trilaterateLarsson(optitrack,uwb)
%% It is assumed that the optitrack inputparameter is a struct containing
% the previously analysed ANCHOR data and positions expressed in the
% optitrack coordinate system. 
%% It is assumed that the uwb inputparameter is a struct containing the mat-
% file location, that has the uwb distances

[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)

ap.larsson = findSubFolderPath(mfilename('fullpath'),'MATLAB','SIMULATION');
ap.larsson = findSubFolderPath(ap.larsson,'SIMULATION','larsson');
addpath(genpath(ap.larsson));

if not(exist(uwb.fullpath,'file'))
    error([newline mfilename mfilename ': ' newline blanks(30) ': LOOK HERE, uwb file does not exist!' newline]);
else
    [uwbdata] = load(uwb.fullpath);
    uwbdata = uwbdata.pozyx;
end

rmpath(genpath(ap.larsson));
end

