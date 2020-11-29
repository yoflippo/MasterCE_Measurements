function particle_filter_run()
close all; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)

ap.synced = findSubFolderPath(mfilename('fullpath'),'MEASUREMENTS','synced');
addpath(genpath(ap.thisFile));
addpath(genpath(ap.synced));

files = makeFullPathFromDirOutput(dir([ap.synced filesep '*.mat']));

m1 = load(files(1).fullpath);
samplefrequency = 10;
numberOfParticles = 700;
circleRadius = 350;
[court,hfig] = drawRectangleBasedOnAnchorsAndCoordinateSystem(m1.sOpti.Anchors);
[uwb,opti,wmpm] = makeAllSyncedOutputSameLength(m1.uwb,m1.opti,m1.wmpm,samplefrequency);

uwb = improveUWB(uwb);
plotSystems(hfig,uwb,opti,wmpm);
hold on;

[area, hdc] = drawCircle(uwb.x(1),uwb.y(1),500);

particles = drawParticlesInsideCircle(numberOfParticles,uwb.x(1),uwb.y(1),circleRadius);
for nS = 250:length(uwb.x)
    delete(hdc(1)); delete(hdc(2));
    distance = 1000*wmpm.vel(nS)/samplefrequency;
    particles = moveParticles(particles,distance);
    
    [area, hdc] = drawCircle(uwb.x(nS),uwb.y(nS),circleRadius);
    
    particles1 = removeParticlesOutsideArea(particles,area);
    
    particles = replenishParticles(particles1,numberOfParticles,area,distance);
    particlesChanged = drawParticles(particles,'green');
    particlesOld = drawParticles(particles1,'blue');
    pause(0.05);
    removeDrawnParticles(particlesChanged);
    removeDrawnParticles(particlesOld);
    removeDrawnParticles(particles);
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
        vector = smooth(vector,10);
        vector = smooth(vector,'sgolay',4);
    end
end

function [c,h] = drawCircle(x,y,radius)
p = 0:pi/50:2*pi;
c.xcor = radius * cos(p) + x;
c.ycor = radius * sin(p) + y;

h(1) = plot(c.xcor,c.ycor,'LineWidth',1,'Color','black');
hold on;
h(2) = plot(x,y,'Marker','o','MarkerSize',10,'LineWidth',5);

c.origin.x = x;
c.origin.y = y;
c.radius = radius;
end


function plotSystems(hfig, uwb,opti,wmpm)
cmapgray = 0.5*ones(1,3);
cmapuwb = [1 0 0];
cmapwmpm = [0 0 1];
cmapopti = [1 1 1];

% plotCoordinatesOfSystem(hfig,uwb,cmapgray.*cmapuwb)
plotCoordinatesOfSystem(hfig,opti,cmapgray.*cmapopti);
% plotCoordinatesOfSystem(hfig,wmpm,cmapgray.*cmapwmpm)
end