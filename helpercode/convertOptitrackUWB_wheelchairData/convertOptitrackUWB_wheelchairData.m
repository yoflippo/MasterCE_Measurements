function convertOptitrackUWB_wheelchairData()
ap.code_measurements = findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA');
addpath(genpath(ap.code_measurements));
ap.files = findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENTS_20200826');
convertC3D_to_MAT_WheelchairMeasurements(ap.files);

convert_pozyx_to_MAT();
addpath(genpath(ap.code_measurements));
createTrilaterationSolverMatFile_run(ap.files);
addpath(genpath(ap.code_measurements));
getSpeedFromOptitrack_run('W_RANG_',ap.files);
addpath(genpath(ap.code_measurements));
feedData2SolverSingle(ap.files);
end

