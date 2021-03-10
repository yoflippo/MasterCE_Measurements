function runViolinPlots()
clc;
ap.measurement = findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA');
this.Path = fileparts(mfilename('fullpath'));
ap.ThesisPath = findSubFolderPath(pwd,'UWB','THESIS');
ap.output = fullfile(extractBefore(this.Path,'SIMULATION'),ap.ThesisPath,'/TUD_ENS_MSc_Thesis/Figures/UWB');
cd(this.Path);

makeViolinPlotOfNLoS(ap.output);
makeViolinPlotOfPOZYX(ap.output);
makeViolinPlotOfStaticDynamicLoS(ap.output);
close all;
end

