function convertOptitrackAndPozyxCarRangingData()
cd(fileparts(mfilename('fullpath')));
ap.code_measurements = findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA');
addpath(genpath(ap.code_measurements));
convertC3D_to_MAT();
convert_pozyx_to_MAT();
addpath(genpath(ap.code_measurements));
createTrilaterationSolverMatFile_run();
addpath(genpath(ap.code_measurements));
getSpeedFromOptitrack_run('RANG_');
addpath(genpath(ap.code_measurements));
feedData2SolverSingle();
end

