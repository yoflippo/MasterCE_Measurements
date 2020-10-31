function [errvalloc,errvaldis,h] = plotTagAnchorMeasurement(data,results,blvisible)

if ~exist('blvisible')
    blvisible = false;
end

if isfield(data,'TagPositions')
    if blvisible
        h=figure('Visible','on');
    else
        h=figure('Visible','on');
    end
    datTag = data.TagPositions;
    
    subplot(4,2,[1 3 5]);
    plotAnchors(data.AnchorPositions)
    hold on; grid on; grid minor;
    
    scatter3(datTag(:,1),datTag(:,2),datTag(:,3),'g','LineWidth',2);
    if exist('results','var')
        scatter3(results(:,1),results(:,2),results(:,3),'rx','LineWidth',2);
        
        scatter3(datTag(1,1),datTag(1,2),datTag(1,3),'ko','LineWidth',3);
        scatter3(results(1,1),results(1,2),results(1,3),'kx','LineWidth',3);
        axis equal
    end
    xlabel('x');ylabel('y');zlabel('z');
    errvalloc = getErrorLocations(data.TagPositions,results);
    errvaldis = getErrorDistances(data.AnchorPositions,data.TagPositions,results);
    title(['Error location: ',num2str(round(errvalloc)) '| distances: ' num2str(round(errvaldis))]);
    
    
    subplot(4,2,2);
    nicifyPlot(datTag(:,1),'X-coordinates','x','r');
    subplot(4,2,4);
    nicifyPlot(datTag(:,2),'Y-coordinates','y','g');
    subplot(4,2,6);
    nicifyPlot(datTag(:,3),'Z-coordinates','z','b');
    if exist('results','var')
        subplot(4,2,2);
        hold on;
        plot(results(:,1),'k');
        subplot(4,2,4);
        hold on;
        plot(results(:,2),'k');
        subplot(4,2,6);
        hold on;
        plot(results(:,3),'k');
    end
    
    subplot(4,2,[7 8]);
    try
    plot(data.Distances);
    xlabel('time'); ylabel('distance [mm]'); title('UWB distances');
    grid on; grid minor;
    catch
    end
end

end

function plot3DData(vector)
figure;
subplot(311);
plot(vector(:,1));
subplot(312);
plot(vector(:,2));
subplot(313);
plot(vector(:,3));
end

function plotAnchors(AnchorPositions)
hold on;
a = (AnchorPositions);
for i = 1:length(a)
    scatter3(a(i,1),a(i,2),a(i,3),'b^','LineWidth',2)
    d = 50; % displacement so the text does not overlay the data points
    text(a(i,1)+d,a(i,2)+d,a(i,3)+d,num2str(i),'FontWeight','bold','FontSmoothing','on');
end
end

function nicifyPlot(data,name,label,color)
plot(data,color);
title(name);
ylabel(label);
xlabel('Time');
grid on; grid minor;
end