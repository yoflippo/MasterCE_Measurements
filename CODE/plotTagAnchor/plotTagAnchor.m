function blPlotCreated = plotTagAnchor(optitrack,measurementResults)
blPlotCreated = false;
if isfield(optitrack,'Tag')
    figure;
    datTag = optitrack.Tag.Coordinates;
    subplot(221);
    plotAnchors(optitrack.Anchors)
    hold on; grid on; grid minor;
    scatter3(datTag(:,1),datTag(:,2),datTag(:,3),'g','LineWidth',2);
    if exist('measurementResults','var')
        scatter3(measurementResults(:,1),measurementResults(:,2),measurementResults(:,3),'r','LineWidth',2);
    end
    xlabel('x');ylabel('y');zlabel('z');
    
    
    subplot(222);
    nicifyPlot(datTag(:,1),'X-coordinates','x','r');
    subplot(223);
    nicifyPlot(datTag(:,2),'Y-coordinates','y','g');
    subplot(224);
    nicifyPlot(datTag(:,3),'Z-coordinates','z','b');
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

function plotAnchors(anchorstruct)
hold on;
a = anchorstruct.UWB_Antenna;
for i = 1:length(a)
    scatter3(a{i}(1),a{i}(2),a{i}(3),'b^','LineWidth',2)
end
end

function nicifyPlot(data,name,label,color)
plot(data,color);
title(name);
ylabel(label);
xlabel('Time');
grid on; grid minor;
end