function particles = drawRandomParticleOnCircle(particles,court,numberParticles,variance)
if isempty(particles)
    [nRows,nCols] = size(court.partcircle.x);
    
    particles.x = [];
    particles.y = [];
    particles.orientation  = [];
    particles.handles = [];
    
    x = court.partcircle.x;
    y = court.partcircle.y;
    
    randIdxs = randi(length(x),1,numberParticles);
    ancx = addVarianceToSignal(x(randIdxs),variance);
    ancy = addVarianceToSignal(y(randIdxs),variance);
    
    [ancx,ancy] = getCoordinatesInsideCourt(court,ancx,ancy);
    while numberParticles-length(ancx) ~= 0
        randIdxs = randi(length(x),1,numberParticles-length(ancx));
        ancx1 = addVarianceToSignal(x(randIdxs),variance);
        ancy1 = addVarianceToSignal(y(randIdxs),variance);
        [ancx1,ancy1] = getCoordinatesInsideCourt(court,ancx1,ancy1);
        ancx = [ancx ancx1];
        ancy = [ancy ancy1];
    end
    
    particles.x = [particles.x ancx];
    particles.y = [particles.y ancy];
    particles.orientation = [particles.orientation randWithinBounds(0,360,1,length(ancy))];
    particles.handles = drawParticles(particles);
else
    while numberParticles-length(particles.x) ~= 0
        randIdxs = randi(length(x),1,numberParticles-length(ancx));
        ancx1 = addVarianceToSignal(x(randIdxs),variance);
        ancy1 = addVarianceToSignal(y(randIdxs),variance);
        [ancx1,ancy1] = getCoordinatesInsideCourt(court,ancx1,ancy1);
        particles.x = [particles.x ancx1];
        particles.y = [particles.y ancy1];
    end
end
end