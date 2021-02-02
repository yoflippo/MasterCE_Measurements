function particles = updateWeightsBasedOnWMPM(particles,velocity,angularRate,variance)

for nP = 1:length(particles.x)
    particles.weights.velocity(nP) =  particles.weights.velocity(nP) * ...
        normpdf(particles.velocity(nP),velocity,variance.velocity);
end
sumWeights = sum(particles.weights.velocity);
particles.weights.velocity = particles.weights.velocity/sumWeights;


for nP = 1:length(particles.x)
    particles.weights.angularRate(nP) =  particles.weights.angularRate(nP) * ...
        normpdf(particles.angularRate(nP),angularRate,variance.angularRate);
end
sumWeights = sum(particles.weights.angularRate);
particles.weights.angularRate = particles.weights.angularRate/sumWeights;
end