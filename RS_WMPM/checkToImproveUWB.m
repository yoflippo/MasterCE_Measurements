function checkToImproveUWB(uwb,opti)
%% test to improve UWB data based on optitrack data
close all;

[uwb2, opti2] = makeSameLength(uwb,opti);
sumCorrelation(uwb2,opti2);

uwb3 = improveUWB(uwb2);
sumCorrelation(uwb3,opti2);

matOpti = makeMatrixFromStruct(opti2);
matUwb = makeMatrixFromStruct(uwb3);
plot3duwbopti(matUwb)
plot3duwbopti(matOpti)
distFig
end

function sumCorrelation(uwb,opti)
[Corrx,Pvalx]= corrcoef([uwb.x opti.x]);
[Corry,Pvaly]= corrcoef([uwb.y opti.y]);
[Corrz,Pvalz]= corrcoef([uwb.y opti.y]);
Correlation = Corrx(2,1) + Corry(2,1)+ Corrz(2,1);
pavlue = Pvalx(2,1) + Pvaly(2,1) + Pvalz(2,1);
[Correlation pavlue]
end


function [uwbsl, optisl] = makeSameLength(uwb,opti)
maxTimeUwb = uwb.time(end);
maxTimeOpti = opti.time(end);
maxTimeRound = round(min(maxTimeUwb,maxTimeOpti));
vecTime = 0:1/5:max(maxTimeRound);

uwbsl.x = interp1(uwb.time,uwb.coord.x,vecTime)';
uwbsl.y = interp1(uwb.time,uwb.coord.y,vecTime)';
uwbsl.z = interp1(uwb.time,uwb.coord.z,vecTime)';
uwbsl.time = vecTime;
uwbsl = makeNaNZeroStruct(uwbsl);
optisl.x = interp1(opti.time,opti.coord.x,vecTime)';
optisl.y = interp1(opti.time,opti.coord.y,vecTime)';
optisl.z = interp1(opti.time,opti.coord.z,vecTime)';
optisl.time = vecTime;
optisl = makeNaNZeroStruct(optisl);

end

function str = makeNaNZeroStruct(str)
str.x = makeNaNZero(str.x);
str.y = makeNaNZero(str.y);
str.z = makeNaNZero(str.z);
end

function input = makeNaNZero(input)
input(isnan(input)) = 0;
end


function matrix = makeMatrixFromStruct(str)
matrix = [str.x str.y str.z];
end

function uwb = improveUWB(uwb)
uwb.x = filteruwb(uwb.x);
uwb.y = filteruwb(uwb.y);
uwb.z = filteruwb(uwb.z);

    function vector = filteruwb(vector)
        vector = smooth(smooth(vector,10),'sgolay',3);
    end
end

function plot3duwbopti(datTag)
figure;
subplot(221);

hold on; grid on; grid minor;
plot3(datTag(:,1),datTag(:,2),datTag(:,3),'g','LineWidth',2);
xlabel('x');ylabel('y');zlabel('z');

subplot(222);
nicifyPlot(datTag(:,1),'X-coordinates','x','r');
subplot(223);
nicifyPlot(datTag(:,2),'Y-coordinates','y','g');
subplot(224);
nicifyPlot(datTag(:,3),'Z-coordinates','z','b');
end

function nicifyPlot(data,name,label,color)
plot(data,color);
title(name);
ylabel(label);
xlabel('Time');
grid on; grid minor;
hold on;
end