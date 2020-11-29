function drawParticle(x,y,direction,color)
csize = 5;
linewidth = 2;

hc = drawCircle(x,y,csize);
set(hc,'Color',color);
set(hc,'LineWidth',linewidth);

hold on;
y1 = y + 3 * csize * sind(direction);
x1 = x + 3 * csize * cosd(direction);
plot([x x1],[y y1],'Color',color,'LineWidth',linewidth);
end

function h = drawCircle(x,y,radius)
p = 0:pi/2:2*pi;
xcor = radius * cos(p) + x;
ycor = radius * sin(p) + y;
h = plot(xcor,ycor);
end