function [x,y] = getCoordinatesInsideCourt(courtDimensions,x,y)
idxToRemove = x <= courtDimensions.minx; 
idxToRemove = idxToRemove | x >= courtDimensions.maxx; 
idxToRemove = idxToRemove | y >= courtDimensions.maxy; 
idxToRemove = idxToRemove | y <= courtDimensions.miny; 
x(idxToRemove) = []; y(idxToRemove) = []; 
end

