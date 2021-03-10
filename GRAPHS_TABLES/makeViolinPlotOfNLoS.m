function makeViolinPlotOfNLoS(apFigureOut)
global apFigureOut;
if not(exist('apFigureOut')) || isempty(apFigureOut)
    apFigureOut = pwd;
end
close all; clc;
set(0,'defaultTextInterpreter','none');

if ~exist('apFolderMeasurements','var')
    apThisFile = fileparts(mfilename('fullpath'));
    cd(apThisFile);
    ap.measurements = findSubFolderPath(pwd,'UWB','MEASUREMENT_DATA');
else
    if ~exist(apFolderMeasurements,'dir')
        error([newline mfilename ': ' newline 'Path does not exist' newline]);
    end
    cd(apFolderMeasurements);
    ap.measurements = apFolderMeasurements;
end

ap.simulation = findSubFolderPath(pwd,'UWB','SIMULATION');
addpath(genpath(ap.simulation));
cd(ap.measurements);
files = dir(['**' filesep '*_results_solver.mat']);
files = makeFullPathFromDirOutput(files);
files = removeUselessFilesFromDirOutput(files);

sErrorStatic = combineErrors(files);
makeViolinPlotsOfDistances(sErrorStatic,'Violin plots the distance error - dynamic NLoS',apThisFile);
makeBoxPlotsOfDistances(sErrorStatic,'DYNAMIC NLoS',apThisFile);

cd(apThisFile);
end


function makeViolinPlotsOfDistances(structErrors,titlePlot,apThisFile)
figure('units','normalized','outerposition',[0 0 0.4 0.5]*1.5,'Visible','on');
violinplot([structErrors.murphy' structErrors.larsson' structErrors.faber'], ...
    getXLabelsWithDuration(structErrors),'MedianColor',[1 0 0],'ShowMean',true)
grid on; grid minor; title(titlePlot);
ylabel('Error [mm]');
set(gca,'FontSize',20)
axis tight
setFigureSpecs();
ylim([0 300]);
oldPath = pwd;
cd(apThisFile);
global apFigureOut;
saveTightFigure(gcf,fullfile(apFigureOut,['ViolinPlotTrilat_' replace(extractAfter(titlePlot,' - '),' ','_') '.png']));
cd(oldPath);
end


function xlabels = getXLabelsWithDuration(values)
rounding = 1;
meantxt = num2str(round(mean(values.larsson),rounding));
xlabels{2} = ['Larsson (\mu = ' meantxt ')'];
meantxt = num2str(round(mean(values.murphy),rounding));
xlabels{1} = ['Murphy (\mu = ' meantxt ')'];
meantxt = num2str(round(mean(values.faber),rounding));
xlabels{3} = ['Faber (\mu = ' meantxt ')'];
end


function makeBoxPlotsOfDistances(structErrors,titlePlot,apThisFile)
figure('units','normalized','outerposition',[0 0 0.4 0.5]*1.5,'Visible','on');
bh = boxplot([structErrors.murphy' structErrors.larsson' structErrors.faber'], ...
    {'Murphy' 'Larsson' 'Faber'},'Notch','on');

grid on; grid minor; title(titlePlot);
ylabel('Error [mm]');

hAx=gca; hAx.XAxis.TickLabelInterpreter='tex';
hAx.XAxis.Label.Interpreter = 'tex';

set(bh,'LineWidth', 1);
grid on; grid minor;

Fh = gcf;
Kids = Fh.Children;
setFont(findobj(Kids,'Type','Axes'),12)

ylim([0 600]);

oldPath = pwd;
cd(apThisFile);
global apFigureOut;
saveTightFigure(gcf,fullfile(apFigureOut,['BoxPlotTrilat_' replace(extractAfter(titlePlot,' - '),' ','_') '.png']));
cd(oldPath);
end


function e = combineErrors(files)
elarsson = []; emurphy = []; efaber = [];
for nF = 1:length(files)
    try
        load(files(nF).fullpath);
        [larsson,murphy,faber] = calculateDifferencesBetweenOptitrackAndOthers(result);
        elarsson = [elarsson larsson];
        emurphy = [emurphy murphy];
        efaber = [efaber faber];
    catch err
    end
end
idxs = emurphy>1000 | elarsson>1000 | efaber > 1000;
emurphy(idxs) = [];
elarsson(idxs) = [];
efaber(idxs) = [];

e.larsson = elarsson;
e.murphy = emurphy;
e.faber = efaber;
end


function files = removeUselessFilesFromDirOutput(files)
files(~contains({files.name},'W_RANG')) = [];
files(~contains({files.name},'RS_')) = [];
end


function [static, known] = differentiateBetweenStaticAndKnown(files)
static = files(contains({files.name},'(S)'));
known = files(contains({files.name},'(K)'));
end


function [larsson,murphy,faber] = calculateDifferencesBetweenOptitrackAndOthers(result)
optitrack = result.data.TagPositions(:,1:2);
larsson = dis(optitrack',result.larsson.coord(:,1:2)');
murphy = dis(optitrack',result.murphy.coord(:,1:2)');
faber = dis(optitrack',result.faber.coord(:,1:2)');
end


function setFigureSpecs(fontsize)
if not(exist('fontsize','var'))
    fontsize = 12;
end
Fh = gcf;
Kids = Fh.Children;
AxAll = findobj(Kids,'Type','Axes');
Ax1 = AxAll(1);
set(Ax1,'LineWidth',0.5)
setFont(Ax1,fontsize)
end


function setFont(ax,fontsize)
ax.FontSize = fontsize;
ax.XAxis.FontSize = fontsize;
ax.YAxis.FontSize = fontsize;
ax.XAxis.Label.FontSize = fontsize;
ax.YAxis.Label.FontSize = fontsize;
ax.YAxis.Label.FontWeight = 'bold';
ax.XAxis.Label.FontWeight = 'bold';
end