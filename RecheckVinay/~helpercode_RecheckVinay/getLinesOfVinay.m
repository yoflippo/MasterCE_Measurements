function coordinates = getLinesOfVinay()
% Return the coordinates of the lines that Vinay supposedly marked when performing his
% measurements in the field (with ropes, see his thesis).
coordinatesPointsOfLines = fliplr([3 3 15 15 6; 3 24 24 3 3])';
coordinates = give2pointsThatFormALineALotOfSubpoints(coordinatesPointsOfLines);
end

function [point1, point2] = extractToSequentialPoints(xpoints,ypoints)
point1 = []; point2 = [];
for nP = 1:length(xpoints)-1
    point1 = [point1; xpoints(nP) ypoints(nP)];
    point2 = [point2; xpoints(nP+1) ypoints(nP+1)];
end
end

function subpoints = give2pointsThatFormALineALotOfSubpoints(coordinates)
[pointOfLineFirst, pointOfLineSecond] = ...
    extractToSequentialPoints(coordinates(:,1),coordinates(:,2));
subpoints = [];
    for nP = 1:length(pointOfLineFirst)
       subpoints = [subpoints; ...
           give2PointALotofSubpoints(pointOfLineFirst(nP,:),...
           pointOfLineSecond(nP,:))];
    end
end

function subpoints = give2PointALotofSubpoints(point1,point2)
subpoints = [linspace(point1(1),point2(1),1000); ...
    linspace(point1(2),point2(2),1000)]';
end

function  out = makeSamenLength(vector,numberOfElements)
interp1(x,v,xq,'spline')
end
