function moveparticles =  moveParticles(particles,distance)
moveparticles = particles;
for nP = 1:length(particles)
    cp = particles(nP);
    moveparticles(nP).x = cp.x + cosd(cp.orientation) * distance;
    moveparticles(nP).y = cp.y + sind(cp.orientation) * distance;
end
end