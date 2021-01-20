function ONETORULETHEMALL()
cd(fileparts(mfilename('fullpath')));
ap.code_measurements = findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA');
addpath(genpath(ap.code_measurements));
convertOptitrackAndPozyxCarRangingData();
addpath(genpath(ap.code_measurements));
convertOptitrackAndPozyxPositioning();
convertOptitrackUWB_wheelchairData();
rmpath(genpath(ap.code_measurements));
end

