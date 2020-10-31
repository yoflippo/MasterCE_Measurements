function [vel] = getSpeedFromOptitrack(apMatFile)
load(apMatFile);
fs = data.optitrack.fs;
velocity(:,1) = gradient(data.TagPositions(:,1),1/fs);
velocity(:,2) = gradient(data.TagPositions(:,2),1/fs);
velocity(:,3) = gradient(data.TagPositions(:,3),1/fs);
vel.signal = velocity;
vel.mean = mean(velocity);
vel.max = max(velocity);
vel.data = data;
% vel.time = linspace(0,1/fs,length(vel.signal))';
vel.resVelocity = sqrt(sum(vel.signal.^2,2))/1000;
vel.resMax = max(vel.resVelocity);
vel.resMean = mean(vel.resVelocity(vel.resVelocity>0.01));
% if isnan(vel.resMean)
%     keyboard
% end
end

