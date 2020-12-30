function h = drawParticle(x,y,direction,color)
csize = 5;
linewidth = 2;

% h(1) = drawCircle(x,y,csize);
% set(h(1),'Color',color);
% set(h(1),'LineWidth',linewidth);

hold on;
y1 = y + 3 * csize * sind(direction);
x1 = x + 3 * csize * cosd(direction);
h(2) = plot([x x1],[y y1],'Color',color,'LineWidth',linewidth);
end

function h = drawCircle(x,y,radius)
p = 0:pi/2:2*pi;
xcor = radius * cos(p) + x;
ycor = radius * sin(p) + y;
h = plot(xcor,ycor);
end