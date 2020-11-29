function [court,hfig] = drawRectangleBasedOnAnchorsAndCoordinateSystem(OptiAnchorInfo)
hfig = figure;
anchorCoordinates = cell2mat(OptiAnchorInfo.UWB_Antenna');
court.minx = min(anchorCoordinates(:,1));
court.maxx = max(anchorCoordinates(:,1));
court.miny = min(anchorCoordinates(:,2));
court.maxy = max(anchorCoordinates(:,2));
court.lines(1) = courtLine([court.minx court.minx],[court.miny, court.maxy]);
court.lines(2) = courtLine([court.minx court.maxx],[court.maxy, court.maxy]);
court.lines(3) = courtLine([court.maxx court.maxx],[court.maxy, court.miny]);
court.lines(4) = courtLine([court.maxx court.minx],[court.miny, court.miny]);
grid on; grid minor; title('Court');
drawAnchors(anchorCoordinates)
end

function linehandle = courtLine(x,y)
linehandle = line(x, y,'Color','black','LineWidth',1);
end

function drawAnchors(ac)
hold on;
for nA = 1:length(ac)
    plot(ac(nA,1),ac(nA,2),'Marker','^','Color','blue','MarkerSize',10,...
        'LineWidth',2);
end
end