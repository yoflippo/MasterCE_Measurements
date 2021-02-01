function [moveparticles, distance,orientationChange]=  moveParticles(particles,n,wmpm,samplefrequency)
distance = 1000*wmpm.vel(n)/samplefrequency;

orientationChange = 0;
if n>2
    orientationChange = atan((wmpm.x(n+2)-wmpm.x(n+1))/(wmpm.y(n+2)-wmpm.y(n+1)))- ...
        atan((wmpm.x(n+1)-wmpm.x(n))/(wmpm.y(n+1)-wmpm.y(n)));
end

moveparticles = particles;
for nP = 1:length(particles)
    d = addGaussianVariationToValue(distance);
    moveparticles(nP).x = particles(nP).x + ... 
        cosd(moveparticles(nP).orientation+orientationChange) * d;
    moveparticles(nP).y = particles(nP).y + ... 
        sind(moveparticles(nP).orientation+orientationChange) * d;
end
end

