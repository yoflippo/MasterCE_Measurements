function ONETORULETHEMALL()
cd(fileparts(mfilename('fullpath')));
ap.code_measurements = findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA');
addpath(genpath(ap.code_measurements));
ap.RS_WMPM = findSubFolderPath(pwd,'MEASUREMENTS','RS_WMPM');
addpath(genpath(ap.RS_WMPM));
ap.SYNC_ALL_SYSTEMS = findSubFolderPath(pwd,'MEASUREMENTS','SYNC_ALL_SYSTEMS');
addpath(genpath(ap.SYNC_ALL_SYSTEMS));

convertOptitrackAndPozyxCarRangingData();
convertPozyxPositioning();
convertOptitrackUWB_wheelchairData();
SynchronizeAllSystems();

rmpath(fileparts(mfilename('fullpath')));
disp([mfilename ' FINISHED']);
end

