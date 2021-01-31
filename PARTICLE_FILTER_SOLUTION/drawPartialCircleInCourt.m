function [x,y] = drawPartialCircleInCourt(court,anchorNumber,rangeAnchor)
ac = court.anchorCoordinates(anchorNumber,:);
[x,y] = getCircleCoordinates(rangeAnchor,ac(1),ac(2),4*360);
[x,y] = getCoordinatesInsideCourt(court,x,y);
plot(x,y,'g','LineWidth',2);
end

