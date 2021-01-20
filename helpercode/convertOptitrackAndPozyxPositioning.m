function convertOptitrackAndPozyxPositioning()
apCode = findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA');
addpath(genpath(apCode));
convert_PozyxPositioning_to_MAT_run();
addpath(genpath(apCode));
combine_PozyxPositioningWithOptitrack_MatFile_run();
getSpeedFromOptitrack_run('PFST_');
addpath(genpath(apCode));
compare_PozyxPositioning_Optitrack();
end

