function makeViolinPlotOfPOZYX(apOutDir)
global apFigureOut; apFigureOut = apOutDir;
if not(exist('apFigureOut')) || isempty(apFigureOut)
    apFigureOut = pwd;
end
apThisFile = fileparts(mfilename('fullpath'));
cd(apThisFile);
ap.measurements = findSubFolderPath(pwd,'UWB','MEASUREMENT_DATA');
ap.simulation = findSubFolderPath(pwd,'UWB','SIMULATION');
addpath(genpath(ap.simulation));

cd(ap.measurements);
files = dir(['**' filesep '*_4solver.mat']);
files(~contains({files.name},'PFST_')) = [];

filesDynamic = files(contains({files.name},'(K)'));
filesStatic = files(contains({files.name},'(S)'));

errorValuesDynamic = concatenateErrorDistancePozyxOptitrack(filesDynamic);
errorValuesStatic = concatenateErrorDistancePozyxOptitrack(filesStatic);

makeViolinPlot(errorValuesStatic, errorValuesDynamic,'Pozyx localization error - LoS',apThisFile);
cd(apThisFile);
rmpath(genpath(ap.measurements));
rmpath(genpath(ap.simulation));
end


function [concatenatedError] = concatenateErrorDistancePozyxOptitrack(files)
concatenatedError = [];
for nF = 1:length(files)
    try
        pathName = [files(nF).folder filesep];
        fileName = files(nF).name;
        apRawMat = fullfile(pathName,fileName);
        load(apRawMat);
        %% Cut bad parts of
        perc = 0.05;
        lendat = length(data.TagPositions);
        b = round(perc*lendat);
        e = round((1-perc)*lendat);
        idx = b:e;
        data.TagPositions = data.TagPositions(idx,:);
        data.pozyx.Tag = data.pozyx.Tag(idx,:);
        data.DistancesTimes = data.pozyx.Time(idx,:);
        
        differenceUWBandOptitrack = data.pozyx.Tag(:,1:2) - data.TagPositions(:,1:2);
        distUWBandOptitrack = sqrt((differenceUWBandOptitrack(:,1).^2) + (differenceUWBandOptitrack(:,2).^2));
        concatenatedError = [concatenatedError; distUWBandOptitrack];
    catch
    end
end
end

function makeViolinPlot(errorsStat,errorsDyn,titlePlot,apThisFile)
figure('units','normalized','outerposition',[0 0 0.4 0.5]*1.5,'Visible','on');
errorvalues = [errorsStat errorsDyn(1:length(errorsStat))];
violinplot(errorvalues,getXLabelsWithDuration(errorvalues),'MedianColor',[1 0 0],'ShowMean',true)
grid on; grid minor; title(titlePlot);
ylabel('Error, distance from groundtruth [mm]');
axis tight
set(gca,'FontSize',20)
setFigureSpecs();
ylim([0 300]);
oldPath = pwd;
cd(apThisFile);
global apFigureOut;
saveTightFigure(gcf,fullfile(apFigureOut,['ViolinPlotPozyx_' titlePlot '.png']));
cd(oldPath);
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

function xlabels = getXLabelsWithDuration(values)
rounding = 1;
meantxt = num2str(round(mean(values(:,1)),rounding));
xlabels{1} = ['Error static (\mu = ' meantxt ')'];
meantxt = num2str(round(mean(values(:,2)),rounding));
xlabels{2} = ['Error dynamic (\mu = ' meantxt ')'];
end