function [x,y] = drawPartialCircleInCourt(court, n, anchorNumber,rangeAnchor)
ac = court.anchorCoordinates(anchorNumber,:);
[x,y] = getCircleCoordinates(rangeAnchor(n,anchorNumber),ac(1),ac(2),4*360);
% plot(x,y,'b','LineWidth',2);
[x,y] = getCoordinatesInsideCourt(court,x,y);
plot(x,y,'g','LineWidth',2);
end