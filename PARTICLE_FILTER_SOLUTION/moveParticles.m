function particles = moveParticles(particles,fs)
dt = 1/fs;
for nP = 1:length(particles.x)
    particles.orientation(nP) = particles.orientation(nP) + particles.angularRate(nP) * dt;
    particles.x(nP) = particles.x(nP) + particles.velocity(nP)*cosd(particles.orientation(nP))*dt;
    particles.y(nP) = particles.y(nP) + particles.velocity(nP)*sind(particles.orientation(nP))*dt;
end
end

