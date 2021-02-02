function [out] = drawPartialCircleInCourt(court, n, anchorNumber,rangeAnchor)


for i = 1:length(anchorNumber)
    ac = court.anchorCoordinates(anchorNumber(i),:);
    [x,y] = getCircleCoordinates(rangeAnchor(n,anchorNumber(i)),ac(1),ac(2),4*360);
    % plot(x,y,'b','LineWidth',2);
    [xo{i},yo{i}] = getCoordinatesInsideCourt(court,x,y);
end

vec = 1:min(length(xo{1}),length(xo{2}));
out.intersection = intersection([xo{1}(vec); yo{1}(vec)], ...
    [xo{2}(vec); yo{2}(vec)]);

out.x = []; out.y = [];
for i = 1:length(anchorNumber)
    out.x = [out.x xo{i}];
    out.y = [out.y yo{i}];    
end

plot(out.x ,out.y,'g*','LineWidth',1);

end