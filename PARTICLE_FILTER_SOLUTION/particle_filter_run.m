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
[uwb,opti,wmpm] = makeAllSyncedOutputSameLength(m1.uwb,m1.opti,m1.wmpm);

uwb = improveUWB(uwb);
plotSystems(hfig,uwb,opti,wmpm);

area = drawCircle(uwb.x(1),uwb.y(1),400)
particles = drawParticlesInsideCircle(500,uwb.x(1),uwb.y(1),400);
 
WORK ON MOVEMENT MODEL WIP
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

function c = drawCircle(x,y,radius)
p = 0:pi/50:2*pi;
c.xcor = radius * cos(p) + x;
c.ycor = radius * sin(p) + y;
plot(c.xcor,c.ycor,'LineWidth',1,'Color','black');
hold on;
plot(x,y,'Marker','o','MarkerSize',10,'LineWidth',5);
end


function plotSystems(hfig, uwb,opti,wmpm)
cmapgray = 0.5*ones(1,3);
cmapuwb = [1 0 0];
cmapwmpm = [0 0 1];
cmapopti = [1 1 1];

plotCoordinatesOfSystem(hfig,uwb,cmapgray.*cmapuwb)
plotCoordinatesOfSystem(hfig,opti,cmapgray.*cmapopti)
plotCoordinatesOfSystem(hfig,wmpm,cmapgray.*cmapwmpm)
end