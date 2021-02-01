function particles = addOtherStateVariables(particles,variance,wmpm)
for np = 1:length(particles.x)
    particles.velocity(np) = addGaussianVariationToValue(wmpm.velframe(1),variance.velocity);
    particles.angularRate(np) = addGaussianVariationToValue(wmpm.angularRate(1),variance.angularRate);
end
end