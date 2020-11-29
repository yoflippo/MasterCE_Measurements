function particle_filter_run()
close all; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)

ap.synced = findSubFolderPath(mfilename('fullpath'),'MEASUREMENTS','synced');
addpath(genpath(ap.thisFile));
addpath(genpath(ap.synced));

files = makeFullPathFromDirOutput(dir([ap.synced filesep '*.mat']));

m1 = load(files(1).fullpath);

[court,hfig] = drawRectangleBasedOnAnchorsAndCoordinateSystem(m1.sOpti.Anchors);
[uwb,opti,wmpm] = makeAllSyncedOutputSameLength(m1.uwb,m1.opti,m1.wmpm);

plotCoordinatesOfSystem(hfig,uwb)
plotCoordinatesOfSystem(hfig,opti)
plotCoordinatesOfSystem(hfig,wmpm)
end

function plotCoordinatesOfSystem(hfig,scoord)
axes_h = get(hfig,'CurrentAxes');
plot(axes_h,scoord.x,scoord.y);
end
