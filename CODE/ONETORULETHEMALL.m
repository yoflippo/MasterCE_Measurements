function ONETORULETHEMALL()
ap.code_measurements = findSubFolderPath(pwd,'MEASUREMENTS','CODE');
addpath(genpath(ap.code_measurements));
convertOptitrackAndPozyxCarRangingData();
addpath(genpath(ap.code_measurements));
convertOptitrackAndPozyxPositioning();
rmpath(genpath(ap.code_measurements));
end

