function kf_run()
close all; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)

ap.synced = findSubFolderPath(mfilename('fullpath'),'MEASUREMENTS','synced');
[~, ap.helper] = findSubFolderPath(mfilename('fullpath'),'MEASUREMENTS','helpercode');
ap.helper = makeFullPathFromDirOutput(ap.helper);
addpath(genpath(ap.helper(1).fullPath));
addpath(genpath(ap.helper(2).fullPath));
addpath(genpath(ap.thisFile));
addpath(genpath(ap.synced));

files = makeFullPathFromDirOutput(dir([ap.synced filesep '*.mat']));

m1 = load(files(1).fullPath);
samplefrequency = 100;
numberOfParticles = 700;
circleRadius = 300;

hfig = figure('units','normalized','outerposition',[0.5 0 0.5 1]);
set(hfig,'doublebuffer','off');

court = drawRectangleBasedOnAnchorsAndCoordinateSystem(m1.sOpti.Anchors);
[uwb,opti,wmpm] = makeAllSyncedOutputSameLength(m1.uwb,m1.opti,m1.wmpm,samplefrequency);

set(gca, 'xlimmode','manual',...
    'ylimmode','manual',...
    'zlimmode','manual',...
    'climmode','manual',...
    'alimmode','manual');

uwb = improveUWB(uwb);
plotSystems(hfig,uwb,opti,wmpm);
hold on;

startValue = 5600;
[area, hdc] = drawCircle(uwb.x(startValue),uwb.y(startValue),circleRadius);
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

function axes_h = plotCoordinatesOfSystem(hfig,scoord,color)
if not(exist('color','var'))
    color = '';
end
axes_h = get(hfig,'CurrentAxes');
plot(axes_h,scoord.x,scoord.y,'Color',color);
end


function uwb = improveUWB(uwb)
uwb.x = filteruwb(uwb.x);
uwb.y = filteruwb(uwb.y);
    function vector = filteruwb(vector)
        vector = smooth(vector,80);
        %         vector = smooth(vector,'sgolay',2);
    end
end

function [c,h] = drawCircle(x,y,radius)
p = 0:pi/50:2*pi;
c.xcor = radius * cos(p) + x;
c.ycor = radius * sin(p) + y;

h(1) = plot(c.xcor,c.ycor,'LineWidth',1,'Color','black');
hold on;
h(2) = plot(x,y,'Marker','.','MarkerSize',15,'LineWidth',5,'Color','red');

c.origin.x = x;
c.origin.y = y;
c.radius = radius;
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

plotCoordinatesOfSystem(hfig,uwb,cmapuwb)
plotCoordinatesOfSystem(hfig,opti,cmapopti);
plotCoordinatesOfSystem(hfig,wmpm,cmapwmpm)
end