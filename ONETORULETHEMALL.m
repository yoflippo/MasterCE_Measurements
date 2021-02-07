function ONETORULETHEMALL()
cd(fileparts(mfilename('fullpath')));
ap.code_measurements = findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA');
addpath(genpath(ap.code_measurements));

convertOptitrackAndPozyxCarRangingData();
convertPozyxPositioning();
convertOptitrackUWB_wheelchairData();
SynchronizeAllSystems();

rmpath(genpath(ap.code_measurements));
disp([mfilename ' FINISHED']);
end

