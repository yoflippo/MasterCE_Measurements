function plotViolinPlots(r)
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
figure('WindowState','maximized','Visible','off');
violinplot([distancesDecawave' distancesMurphy' distancesLarsson' distancesFaber'], ...
    {'Decawave' 'Murphy' 'Larsson' 'Faber'},'MedianColor',[1 0 0],'ShowMean',true )
            %     'ShowNotches'  Whether to show notch indicators.
            %                    Defaults to false
            %     'ShowMean'     Whether to show mean indicator.
            %                    Defaults to false
grid on; grid minor; title('Violin plots of distances from "reference"');
ylim([0 2])
% set(gca, 'YScale', 'log')
% ylim([0 10])
pause(2);
saveTightFigure(gcf,'ViolinPlot_VinayMeasurements.png');
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

