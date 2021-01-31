function lefover = removeParticlesOutsideArea(particles,area)
lefover = [];
for nP = 1:length(particles)
    cp = particles(nP);
    if sqrt((cp.x - area.origin.x)^2+(cp.y - area.origin.y)^2) < area.radius
        lefover = [lefover cp];
    end
end
end