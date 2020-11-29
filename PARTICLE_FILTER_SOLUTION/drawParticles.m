function h = drawParticles(particles,color)
if not(exist('color','var'))
    color = 'red';
end
for i = 1:length(particles)
    h(i,:) = drawParticle(particles(i).x,particles(i).y,particles(i).orientation,color);
end
end

