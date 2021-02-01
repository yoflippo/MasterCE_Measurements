close all; clc; clearvars;

[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)
addpath(genpath(ap.thisFile));
files = makeFullPathFromDirOutput(dir(['**' filesep '*.mat']));

data = load(files(1).fullpath);
hfig = figure('units','normalized','outerposition',[0.5 0 0.5 1]);
court = drawCourtAndAnchors(data.sOpti.Anchors);
[uwb,opti,wmpm] = cleanUpData(data,court);

samplefrequency = 20;
numberOfParticles = 400;
circleRadius = 300;
variance.uwb = 1e5; % mm

plotSystems(hfig,uwb,opti,wmpm); 

startValue = 1;
[pos.anc(1).x,pos.anc(1).y] = drawPartialCircleInCourt(court,startValue,1,data.uwb.rawdata.DistancesUWB);
[pos.anc(2).x,pos.anc(2).y] = drawPartialCircleInCourt(court,startValue,2,data.uwb.rawdata.DistancesUWB);
particles = drawRandomParticleOnCircle(court, pos,numberOfParticles,variance.uwb);

% particles = drawParticlesInsideCircle(numberOfParticles,uwb.x(startValue),uwb.y(startValue),circleRadius);
removeDrawnParticles(particles);

hd = drawDot(opti.x(startValue),opti.y(startValue),'green');
hd_wmpm = drawDot(wmpm.x(startValue),wmpm.y(startValue),'green');
ylim([-2700 1800]); xlim([-2700 1100]);

for nS = startValue:length(uwb.x)
    
    
    %     delete(hdc(1)); delete(hdc(2)); delete(hdc);     delete(hd_wmpm);
    %
    %     [particles,distance,orientation] = moveParticles(particles,nS,wmpm,samplefrequency);
    %     [area,hdc] = drawCircle(uwb.x(nS),uwb.y(nS),circleRadius);
    %     drawDot(uwb.x(nS),uwb.y(nS),'blue');
    %     drawDot(mean([particles.x]),mean([particles.y]),'magenta');
    %     drawDot(opti.x(nS),opti.y(nS),'green');
    %     hd_wmpm = drawDot(wmpm.x(nS),wmpm.y(nS),'green');
    %     particles = removeParticlesOutsideArea(particles,area);
    %     particles = replenishAndRenewParticles(particles,numberOfParticles,area,distance);
    %
    %     particlesOld = drawParticles(particles,'blue');
    %     drawnow;
    %     removeDrawnParticles(particlesOld);
end


function [opti,uwb,wmpm] = cleanUpData(data,court)
uwb = addOnlyRelevantSignal(data.uwb,court);
opti = addOnlyRelevantSignal(data.opti,court);
wmpm = addOnlyRelevantSignal(data.wmpm,court);

    function sStruct = addOnlyRelevantSignal(sStruct,court)
        idxs = sStruct.cleanSignalTimeIdx(1):sStruct.cleanSignalTimeIdx(2);
        sStruct.xclean = sStruct.coord.x(idxs) + court.offsetx;
        sStruct.yclean = sStruct.coord.y(idxs) + court.offsety;
        sStruct.tclean = sStruct.time(idxs)';
    end
end



function removeDrawnParticles(particles)
try
    for n = 1:length(particles)
        delete(particles(n).handles1);
        delete(particles(n).handles2);
    end
catch
    for n = 1:length(particles)
        delete(particles.handles);
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
hold on;
plotCoordinatesOfSystem(hfig,uwb,cmapuwb);
plotCoordinatesOfSystem(hfig,opti,cmapopti);
% plotCoordinatesOfSystem(hfig,wmpm,cmapwmpm);
end


function axes_h = plotCoordinatesOfSystem(hfig,d,color)
if not(exist('color','var'))
    color = '';
end
axes_h = get(hfig,'CurrentAxes');
plot(axes_h,d.xclean,d.yclean,'Color',color);
end