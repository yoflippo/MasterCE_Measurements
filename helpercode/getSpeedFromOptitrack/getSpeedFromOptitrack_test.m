close all; clear variables; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)

nm.testData = 'DATA_TEST';
ap.testData = fullfile(ap.thisFile,nm.testData);

files = dir(ap.testData);
files = files(~[files.isdir]);
files = files(contains({files.name},'.mat'));


%% Do some testing
try
for nF = 1:length(files)
   vel = getSpeedFromOptitrack(fullfile(files(nF).folder,files(nF).name)); 
   plotPosVel(vel);
end
catch

    
end
cd(ap.thisFile);




function plotPosVel(vel)
close all;
subplot(2,1,1);
time = vel.data.DistancesTimes/1000;
plot(time,vel.data.TagPositions/1000); grid on; grid minor; ylabel('position [m]'); title('position');
subplot(2,1,2);
plot(time,vel.signal/1000); grid on; grid minor; ylabel('velocity [m/s]'); title('velocity');
hold on;
plot(time,vel.resVelocity,'Linewidth',2)
end

