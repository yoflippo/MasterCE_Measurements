% CONVERTOPTITRACKANDPOZYXCARRANGINGDATA
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)

% $Revision: 0.0.0 $  $Date: 2020-09-11 $
% Creation of this function.

function convertOptitrackAndPozyxPositioning()
apCode = findSubFolderPath(pwd,'MEASUREMENTS','CODE');
addpath(genpath(apCode));
convert_PozyxPositioning_to_MAT_run();
addpath(genpath(apCode));
combine_PozyxPositioningWithOptitrack_MatFile_run();
getSpeedFromOptitrack_run('PFST_');
addpath(genpath(apCode));
compare_PozyxPositioning_Optitrack();
end

