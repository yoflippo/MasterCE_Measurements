function [c,h] = drawCircle(x,y,radius,steps)
c.origin.x = x;
c.origin.y = y;

if not(exist('steps','var'))
    steps = 360;
end

h(1) = plot(x,y,'LineWidth',1,'Color','black');
hold on;

[x,y] = getCircleCoordinates(radius,x,y,steps);
h(2) = plot(x,y,'Marker','.','MarkerSize',5,'LineWidth',1,'Color','red');
axis equal;

c.x = x;
c.y = y;
c.radius = radius;
end