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
end

