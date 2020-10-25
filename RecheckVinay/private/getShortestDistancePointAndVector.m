function shortestDistance = getShortestDistancePointAndVector(point,vector)

colvector = getColumnVector(vector);
shortestDistance = Inf;
for nV = 1:length(colvector)
   shortestDistance = min(shortestDistance,getDistance(point,colvector(nV,:))); 
end
end

function distance = getDistance(point1,point2)
distance = sqrt(sum((point1-point2).^2));
end

function outputvector = getColumnVector(inputvector)
[rowvec,colvec] = size(inputvector);
if colvec > rowvec
    outputvector = inputvector';
    return;
end
outputvector = inputvector;
end

