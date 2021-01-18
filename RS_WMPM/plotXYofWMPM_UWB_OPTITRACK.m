function plotXYofWMPM_UWB_OPTITRACK()
%% This function assumes it is in a folder that contains the folder 'synced'
% which contains MAT-files with coordinates of the systems mentioned in the
% title of this function.
close all; clc; clearvars;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)

nameOfdir = 'synced';
if not(exist(nameOfdir,'dir'))
   error([newline mfilename ': ' newline 'Folder "' nameOfdir '" does not exist!' newline]); 
end
addpath(genpath(nameOfdir))

cd(nameOfdir);

files = makeFullPathFromDirOutput(dir('*.mat'));

for nF = 1:length(files)
    load(files(nF).fullpath);
    plotTheSystems(opti,uwb,wmpm);
    saveTightFigure(gcf,replace(files(nF).name,'.mat','.png'))
end
end

function plotTheSystems(opti,uwb,wmpm)
figure('units','normalized','outerposition',[0.1 0.1 0.9 0.9]);

subplot(2,2,1);
plot(opti.coord.x, opti.coord.y,'g'); 
plotMarkerStartAndfinish(opti)
xlabel('x-coordinates'); ylabel('y-coordinates');
title('Optitrack coordinates');
axis equal
xlimvals = get(gca,'XLim');
ylimvals = get(gca,'YLim');
grid on; grid minor;

offsetWMPM = getOffsetToMakeWMPMStartAtUWBlocation(uwb,wmpm);

subplot(2,2,2);
plot(wmpm.coord.x,wmpm.coord.y,'b');
hold on;
% plot(wmpm.coord.x - offsetWMPM(1),wmpm.coord.y - offsetWMPM(2),'r');
plotMarkerStartAndfinish(wmpm)
xlabel('x-coordinates'); ylabel('y-coordinates');
title('WMPM Coordinates');
grid on; grid minor;
axis equal
ylim(ylimvals); xlim(xlimvals);

subplot(2,2,3);
plot(uwb.coord.x, uwb.coord.y,'r');
plotMarkerStartAndfinish(uwb)
xlabel('x-coordinates'); ylabel('y-coordinates'); 
title('UWB Coordinates');
grid on; grid minor;
axis equal
ylim(ylimvals); xlim(xlimvals);
set(findall(0,'type','line'),'linewidth',2);
end

function plotMarkerStartAndfinish(data)
hold on;
plot(data.coord.x(1),data.coord.y(1),'ok','LineWidth',2,'MarkerSize',9);
plot(data.coord.x(end),data.coord.y(end),'xk','LineWidth',2,'MarkerSize',9);
end

function offsetWMPM = getOffsetToMakeWMPMStartAtUWBlocation(uwb,wmpm)
offsetWMPM = [wmpm.coord.x(1)-uwb.coord.x(1) wmpm.coord.y(1)-uwb.coord.y(1)];
end