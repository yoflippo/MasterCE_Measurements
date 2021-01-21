function plotTagAnchorRaw(optitrack)



%% Find Tags
idxTags = find(contains(optitrack.names,'Tag'));
Tags = optitrack.coordinatesFilled(idxTags);

figure;
for nT = 1:length(Tags)
    figure('units','normalized','outerposition',[0.1 0.1 0.9 0.9])
    datTag = Tags{nT};
    subplot(221);
    plot3DData(optitrack,datTag);
    
    subplot(222);
    nicifyPlot(datTag(:,1),'X-coordinates','x','r');
    subplot(223);
    nicifyPlot(datTag(:,2),'Y-coordinates','y','g');
    subplot(224);
    nicifyPlot(datTag(:,3),'Z-coordinates','z','b');   
end
end


function plot3DData(optitrack,datTag)
    plotAnchors(optitrack.Anchors)
    hold on; grid on; grid minor;
    scatter3(datTag(:,1),datTag(:,2),datTag(:,3),'g','LineWidth',2);
    xlabel('x');ylabel('y');zlabel('z');
    title(replace(optitrack.name,'_','-'));
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
hold on;
end