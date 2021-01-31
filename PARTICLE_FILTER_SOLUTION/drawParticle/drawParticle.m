function h = drawParticle(x,y,direction,color)
csize = 4;
linewidth = 2;
direction = -direction;

[x, y] = createShape(x,y,csize);

hold on;
R = [cosd(direction) -sind(direction);
     sind(direction)  cosd(direction)];
xr =  [x' y'] * R;

h = plot(xr(:,1),xr(:,2));
set(h,'Color',color);
set(h,'LineWidth',linewidth);
end

function [x,y] = createShape(x,y,radius)
p = 2*pi:-pi/2:0;
x = radius * cos(p) + x;
y = radius * sin(p) + y;
x = [x x(end)+radius];
y = [y y(end)];
end