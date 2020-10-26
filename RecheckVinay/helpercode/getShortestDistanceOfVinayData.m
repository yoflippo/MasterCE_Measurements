function [shortestdis] = getShortestDistanceOfVinayData(result,walkinglines)
shortestdis.murphy = goOverDataPoints(result.murphy.coord,walkinglines);
shortestdis.decawave = goOverDataPoints(result.decawaveStuff.decawavePositions(:,1:2),walkinglines);
shortestdis.larsson = goOverDataPoints(result.larsson.coord,walkinglines);

shortestdis.rmse.murphy = rmse(shortestdis.murphy);
shortestdis.rmse.decawave = rmse(shortestdis.decawave);
shortestdis.rmse.larsson = rmse(shortestdis.larsson);
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

