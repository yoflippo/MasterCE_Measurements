function particles = drawRandomParticleOnCircle(court,pos,numberParticle,variance)

[nRows,nCols] = size(pos.anc);

particles.x = [];
particles.y = [];
particles.orientation  = [];
particles.handles = [];

for nR = 1:nCols
    x = pos.anc(nR).x;
    y = pos.anc(nR).y;
    ancx = interp1(1:length(x),x,1:1/1:length(x));
    ancy = interp1(1:length(y),x,1:1/1:length(y));
    
    ancx = generate_signal(pos.anc(nR).x,variance);
    ancy = generate_signal(pos.anc(nR).y,variance);
    
    [ancx,ancy] = getCoordinatesInsideCourt(court,ancx,ancy);
    
    particles.x = [particles.x ancx];
    particles.y = [particles.y ancy];
    particles.orientation = [particles.orientation randWithinBounds(0,360,1,length(ancy))];
end
particles.handles = drawParticles(particles);
end

function [outsignal, outvar] = generate_signal(signal, var)
noise = randn(size(signal))*sqrt(var);
outsignal = signal + noise;
outvar = var;
end