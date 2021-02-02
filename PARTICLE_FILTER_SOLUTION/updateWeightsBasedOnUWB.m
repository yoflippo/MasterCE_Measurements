function particles = updateWeightsBasedOnUWB(particles,court,uwb,chosenAnchors,nS,variance)



for nCA = 1:length(chosenAnchors)
    
    currentDistanceTagAnchor = sqrt((particles.x-court.partcircle.intersection(1)).^2 + ...
        (particles.y-court.partcircle.intersection(2)).^2);
    
    for nP = 1:length(particles.x)
        particles.weights.range(nP) = particles.weights.range(nP) * ...
            normpdf(currentDistanceTagAnchor(nP),ranges(nCA),variance.uwb);
    end
    sumWeights = sum(particles.weights.range);
    particles.weights.range = particles.weights.range/sumWeights;
end


end