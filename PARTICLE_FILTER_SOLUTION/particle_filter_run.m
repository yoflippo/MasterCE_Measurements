close all; clc; clearvars;

[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)
addpath(genpath(ap.thisFile));
files = makeFullPathFromDirOutput(dir(['**' filesep '*.mat']));

data = load(files(1).fullpath);
samplefrequency = 20;
numberOfParticles = 700;
circleRadius = 300;

hfig = figure('units','normalized','outerposition',[0.5 0 0.5 1]);

court = drawCourtAndAnchors(data.sOpti.Anchors);
[uwb,opti,wmpm] = makeAllSyncedOutputSameLength(data.uwb,data.opti,data.wmpm,samplefrequency);


% set(gca, 'xlimmode','manual',...
%     'ylimmode','manual',...
%     'zlimmode','manual',...
%     'climmode','manual',...
%     'alimmode','manual');

plotSystems(hfig,uwb,opti,wmpm); hold on;
drawPartialCircleInCourt(court,1,data.uwb.rawdata.DistancesUWB(1,1));
drawPartialCircleInCourt(court,3,data.uwb.rawdata.DistancesUWB(1,3));



startValue = 1;
particles = drawParticlesInsideCircle(numberOfParticles,uwb.x(startValue),uwb.y(startValue),circleRadius);
removeDrawnParticles(particles);

hd = drawDot(opti.x(startValue),opti.y(startValue),'green');
hd_wmpm = drawDot(wmpm.x(startValue),wmpm.y(startValue),'green');
ylim([-2700 1800]); xlim([-2700 1100]);

for nS = startValue:length(uwb.x)
    delete(hdc(1)); delete(hdc(2)); delete(hdc);     delete(hd_wmpm);
    
    [particles,distance,orientation] = moveParticles(particles,nS,wmpm,samplefrequency);
    [area,hdc] = drawCircle(uwb.x(nS),uwb.y(nS),circleRadius);
    drawDot(uwb.x(nS),uwb.y(nS),'blue');
    drawDot(mean([particles.x]),mean([particles.y]),'magenta');
    drawDot(opti.x(nS),opti.y(nS),'green');
    hd_wmpm = drawDot(wmpm.x(nS),wmpm.y(nS),'green');
    particles = removeParticlesOutsideArea(particles,area);
    particles = replenishAndRenewParticles(particles,numberOfParticles,area,distance);

    particlesOld = drawParticles(particles,'blue');
    drawnow;
    removeDrawnParticles(particlesOld);
end





function removeDrawnParticles(particles)
try
    for n = 1:length(particles)
        delete(particles(n).handles1);
        delete(particles(n).handles2);
    end
catch
    for n = 1:length(particles)
        delete(particles(n,1));
        delete(particles(n,2));
    end
end
end





function [h] = drawDot(x,y,color)
if not(exist('color','var'))
    color = 'black';
end
h = plot(x,y,'Marker','.','MarkerSize',10,'LineWidth',5,'Color',color);
end


function plotSystems(hfig, uwb,opti,wmpm)
grayf = 0.8;
cmapuwb = grayf*[1 0 0];
cmapwmpm = grayf*[0 0 1];
cmapopti = grayf*[1 1 1];

plotCoordinatesOfSystem(hfig,uwb,cmapuwb);
plotCoordinatesOfSystem(hfig,opti,cmapopti);
plotCoordinatesOfSystem(hfig,wmpm,cmapwmpm);
end



function axes_h = plotCoordinatesOfSystem(hfig,scoord,color)
if not(exist('color','var'))
    color = '';
end
axes_h = get(hfig,'CurrentAxes');
plot(axes_h,scoord.x,scoord.y,'Color',color);
end