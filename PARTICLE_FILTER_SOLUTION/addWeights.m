function particles = addWeights(particles)
n = length(particles.x);
uniformWeight = 1/n;
uniformWeightVector = ones(size(particles.x))*uniformWeight;

particles.weights.range = uniformWeightVector;
particles.weights.orientation = uniformWeightVector;
particles.weights.velocity = uniformWeightVector;
particles.weights.angularRate = uniformWeightVector;
end