close all; clc; clearvars;

[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)
addpath(genpath(ap.thisFile));
cd ..
cd synced
files = makeFullPathFromDirOutput(dir(['**' filesep '*.mat']));
cd(ap.thisFile)

data = load(files(1).fullpath);
hfig = figure('units','normalized','outerposition',[0.5 0 0.5 1]);
court = drawCourtAndAnchors(data.sOpti.Anchors);
[uwb,opti,wmpm] = cleanUpData(data,court);

fs = 1/mean(diff(wmpm.t));
numberOfParticles = 500;
circleRadius = 300;
variance.uwb = 1e5; % mm
variance.velocity = 50; %% mm/s
variance.angularRate = 10; %% deg/s

plotSystems(hfig,uwb,opti,wmpm);

startValue = 2;
chosenAnchors = [1 2];
court.partcircle = drawPartialCircleInCourt(court,startValue,chosenAnchors,uwb.a);
particles = drawRandomParticleOnCircle([],court,numberOfParticles,variance.uwb);

particles = addOtherStateVariables(particles,variance,wmpm);
particles = addWeights(particles);
removeDrawnParticles(particles);

% hd = drawDot(opti.x(startValue),opti.y(startValue),'green');
% hd_wmpm = drawDot(wmpm.x(startValue),wmpm.y(startValue),'green');
% ylim([-2700 1800]); xlim([-2700 1100]);

cnt = 1;
for nS = startValue:length(wmpm.x)
    wmpmTime = wmpm.t(nS);
    
    court.partcircle = drawPartialCircleInCourt(court,nS,chosenAnchors,uwb.a);
    particles = drawRandomParticleOnCircle(particles,court,numberOfParticles,variance.uwb);
    
    particles = moveParticles(particles,fs);
    drawParticles(particles,'blue');
    if wmpmTime > uwb.t(cnt)
        particles = updateWeightsBasedOnUWB(particles,court,uwb,chosenAnchors,cnt,variance);
        cnt = cnt + 1;
    else % Do angular rate AND velocity update
        particles = updateWeightsBasedOnWMPM(particles,wmpm.velframe(nS),wmpm.angularRate(nS),variance);
    end
    
    particles = resampleParticles(particles);
    %         drawParticles(particles,'blue');
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



function [uwb,opti,wmpm] = cleanUpData(data,court)
uwb = addOnlyRelevantSignal(data.uwb,court);
opti = addOnlyRelevantSignal(data.opti,court);
wmpm = addOnlyRelevantSignal(data.wmpm,court);
uwb = addAnchorTagDistances(uwb);

    function sStruct = addOnlyRelevantSignal(sStruct,court)
        idxs = sStruct.cleanSignalTimeIdx(1):sStruct.cleanSignalTimeIdx(2);
        sStruct.x = sStruct.coord.x(idxs) + court.offsetx;
        sStruct.y = sStruct.coord.y(idxs) + court.offsety;
        sStruct.t = sStruct.time(idxs)';
        try
            sStruct.velframe = sStruct.velframe(idxs)*1000; %%mm/s
            sStruct.angularRate = sStruct.angularRate(idxs);
        catch
        end
    end

    function uwb = addAnchorTagDistances(uwb)
        idxs = uwb.cleanSignalTimeIdx(1):uwb.cleanSignalTimeIdx(2);
        
        uwb.dis.t = uwb.rawdata.TimestampsUWB(uwb.rawdata.cutIdx:end);
        uwb.dis.t = uwb.dis.t(idxs)';
        
        for n = 1:4
            tmp = uwb.rawdata.DistancesUWB(uwb.rawdata.cutIdx:end,n);
            uwb.a(:,n) = tmp(idxs);
        end
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
plot(axes_h,d.x,d.y,'Color',color);
end