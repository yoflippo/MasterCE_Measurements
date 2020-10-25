function [result] = getShortestDistanceOfVinayData(result,walkinglines)
result.shortestdis.murphy = goOverDataPoints(result.murphy.coord,walkinglines);
result.shortestdis.decawave = goOverDataPoints(result.decawaveStuff.decawavePositions(:,1:2),walkinglines);
result.shortestdis.larsson = goOverDataPoints(result.larsson.coord,walkinglines);

result.shortestdis.sums.murphy = sum(result.shortestdis.murphy);
result.shortestdis.sums.decawave = sum(result.shortestdis.decawave);
result.shortestdis.sums.larsson = sum(result.shortestdis.larsson);
end

function distances = goOverDataPoints(vector,walkinglines)
for nV = 1:length(vector)
    distances(nV) = getShortestDistancePointAndVector(vector(nV,:),walkinglines);
end
distances = makeInfOrNaNEqualToZero(distances);
end

function out = makeInfOrNaNEqualToZero(matrix)
out = matrix;
out(out==Inf)=0;
out(isnan(out))=0;
end

