function h = drawParticle(x,y,direction,color,csize)
if not(exist('csize','var')) || isempty(csize)
    csize = 10;
end

linewidth = 2;
direction = -direction;

[xs, ys] = createShape(csize);

hold on;
R = [cosd(direction) -sind(direction);
     sind(direction)  cosd(direction)];
xr =  [xs'  ys' ] * R;

h = plot(xr(:,1) + x,xr(:,2) + y);
set(h,'Color',color);
set(h,'LineWidth',linewidth);
end

function [x,y] = createShape(radius)
p = 2*pi:-pi/2:0;
x = radius * cos(p);
y = radius * sin(p);
x = [x x(end)+radius];
y = [y y(end)];
end