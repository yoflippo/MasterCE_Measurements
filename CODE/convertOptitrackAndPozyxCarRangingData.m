% CONVERTOPTITRACKANDPOZYXCARRANGINGDATA
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)

% $Revision: 0.0.0 $  $Date: 2020-09-11 $
% Creation of this function.

function convertOptitrackAndPozyxCarRangingData()
ap.code_measurements = findSubFolderPath(pwd,'MEASUREMENTS','CODE');
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

