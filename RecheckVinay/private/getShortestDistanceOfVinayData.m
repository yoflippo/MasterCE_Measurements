function [resultWithDistances] = getShortestDistanceOfVinayData(result,walkinglines)

resultWithDistances = goOverDataPoints(result.murphy.coord,walkinglines);
end

function distances = goOverDataPoints(vector,walkinglines)
for nV = 1:length(vector)
    selection = getSelectionWalkingLines(nV,vector,walkinglines);
    distances(nV) = getShortestDistancePointAndVector(vector(nV,:),selection);
end
end

function selection = getSelectionWalkingLines(i,vector,walkinglines)
% To prevent that the start UWB datapoints get confused with the ending UWB
% datapoints which are close together.
progression = i/length(vector);
lowerbound = 0.33;
upperbound = 0.66;
idxLowerbound = round(length(walkinglines)*lowerbound);
idxUpperbound = round(length(walkinglines)*upperbound);

if progression > lowerbound && progression < upperbound
    selection = walkinglines(idxLowerbound:idxUpperbound,:);
elseif progression <= lowerbound
    selection = walkinglines(1:idxLowerbound,:);
else
    selection = walkinglines(idxUpperbound:end,:);
end
end

