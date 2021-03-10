function plotCDFsOfDistances(r)
distancesMurphy = [];
distancesDecawave = [];
distancesLarsson = [];
distancesFaber = [];
for nF = 1:length(r)
    distancesDecawave = [distancesDecawave r(nF).distances.decawave];
    distancesMurphy = [distancesMurphy r(nF).distances.murphy];
    distancesLarsson = [distancesLarsson r(nF).distances.larsson];
    distancesFaber = [distancesFaber r(nF).distances.faber];
end
% makeSubplot()
allinone()
close all;


function allinone()
figure('WindowState','maximized','Visible','off'); hold on; 

h1 = cdfplot(distancesDecawave);
h2 = cdfplot(distancesMurphy); 
h3 = cdfplot(distancesLarsson); 
h4 = cdfplot(distancesFaber); 

set(h1,'LineWidth',2)
set(h2,'LineWidth',2)
set(h3,'LineWidth',2)
set(h4,'LineWidth',2)

grid on; grid minor; 
legend('Decawave','Murphy','Larsson','Faber');
xlabel('distance error [m]'); title('CDF positioning error');

saveTightFigure(gcf,'CDF_VinayMeasurements.png');
end


function makeSubplot()
figure;
subplot(2,2,1);
[h1,stats1] = cdfplot(distancesDecawave,'Displayname','test' ); grid on; grid minor; 
xlabel('distance [m]'); title('Decawave positioning');

subplot(2,2,2);
[h2,stats2] = cdfplot(distancesMurphy); grid on; grid minor;
xlabel('distance [m]'); title('Murphy positioning');

subplot(2,2,3);
[h3,stats3] = cdfplot(distancesLarsson); grid on; grid minor;
xlabel('distance [m]'); title('Larsson positioning');

subplot(2,2,4);
[h4,stats4] = cdfplot(distancesFaber); grid on; grid minor;
xlabel('distance [m]'); title('Faber positioning');
end

end

