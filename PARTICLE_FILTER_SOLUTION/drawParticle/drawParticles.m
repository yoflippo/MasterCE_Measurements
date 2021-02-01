function h = drawParticles(particles,color,size)
if not(exist('color','var')) || isempty(color)
    color = 'red';
end
if not(exist('size','var')) || isempty(size)
    size = 50;
end
for i = 1:length(particles.x)
    h(i,:) = drawParticle(particles.x(i),particles.y(i),particles.orientation(i),color,size);
end
end

