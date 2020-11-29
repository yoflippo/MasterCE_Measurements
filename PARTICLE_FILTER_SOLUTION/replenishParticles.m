function particles = replenishParticles(particles,numberOfParticles,area,distance)
numExistingParticles = length(particles);
p_random = [];
for n = 1:(numberOfParticles-numExistingParticles)
    % Pick random existing particle
    getRandomParticle()
    while sqrt((p_random.x-area.origin.x)^2+(p_random.y-area.origin.y)^2) > area.radius
       getRandomParticle()
    end
    particles(numExistingParticles+n) = p_random;
end

    function getRandomParticle()
        idx_random = randi(numExistingParticles);
        p_random = particles(idx_random);
        % add some variation in orientation
        p_random.orientation = randWithinBounds(-120,120,1,1)+ p_random.orientation;
        p_random.x = p_random.x + distance;
        p_random.y = p_random.y + distance; 
    end
end