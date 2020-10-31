function sOut = readAndFormatDataOfVinay(apTxtFileDecawaveUWB)
try
    txt = readFileDecawave(apTxtFileDecawaveUWB);
    if not(isempty(txt))
        [anchorNames, anchorPositions] = getAnchors(txt);
        distancesPerAnchor = getDistanceToTag(txt,anchorNames);
        decawavePositions = getDecawavePositions(txt);
        [distancesForSolver,anchorPositionsForSolver] = ...
            combineAnchorAndDistances(anchorPositions,distancesPerAnchor);
        
        sOut.anchornames = anchorNames;
        sOut.anchorpositions = anchorPositions;
        sOut.decawavePositions = decawavePositions;
        sOut.distances = distancesPerAnchor;
        sOut.solver.distances = distancesForSolver;
        sOut.solver.anchors = anchorPositionsForSolver;
    else
        error([newline mfilename mfilename ': ' newline blanks(30) 'Not a Decawave UWB file: LOOK HERE' newline]);
    end
catch err
    error([newline mfilename mfilename ': ' newline blanks(30) err.message ': LOOK HERE' newline]);
end
end

function out = readFileDecawave(apTxtFileDecawaveUWB)
txt = readTxtFile(apTxtFileDecawaveUWB);
txt = removeIMUlines(txt);
if iscell(txt) || iscellstr(txt)
    out = {txt{:}};
else
    out = txt;
end
end


function out = removeIMUlines(txt)
out = txt(not(contains(txt,'yaw=')) & not(contains(txt,'mx=')));
end

function [anchorNames, anchorPositions] = getAnchors(txt)
anchorNames = getAnchorIDs(txt);
anchorPositions = getAnchorPositions(txt,anchorNames);
end

function ids = getAnchorIDs(txt)
ids = [];
for nA = 0:getMaxAnchorId(txt)
    lines = txt;
    for nL = 1:length(txt)
        line = lines(nL);
        ids = [ids {extractIdAfterAnchorNumber(line,nA)}];
    end
end
ids = unique(ids); ids = ids(2:end);
end

function number = getMaxAnchorId(txt)
numbers = [];
for nA = 0:1000
    if(any(contains(txt,['AN' num2str(nA) ','])))
        numbers = [numbers nA];
    end
end
number = max(numbers);
end

function id = extractIdAfterAnchorNumber(line,nA)
line = line{:};
strToFind = ['AN' num2str(nA) ','];
result = strfind(string(line),strToFind);
if not(isempty(result))
    commasIdx = find(line==',');
    indicesThatContainId = find(result<commasIdx);
    firstIdxOfId = commasIdx(indicesThatContainId(1));
    secondIdxOfId= commasIdx(indicesThatContainId(2));
    id = line(firstIdxOfId+1:secondIdxOfId-1);
else
    id = '';
end
end

function anchorPositions = getAnchorPositions(txt,anchorNames)
for nA = 1:length(anchorNames)
    idxLineWithAnchorName = find(contains(txt,anchorNames{nA}));
    line = char(txt(idxLineWithAnchorName(1)));
    pieceOfLine = extractAfter(line,anchorNames{nA});
    idxPieceOfLineCommas = findCommasIndicesInChar(pieceOfLine);
    anchorPositions(:,nA) = extractNumbersBetweenCommasInAString(pieceOfLine,idxPieceOfLineCommas(1:4));
end
end

function idx = findCommasIndicesInChar(txt)
idx = find(char(txt)==',');
end
function  vector = extractNumbersBetweenCommasInAString(line,idxs)
for nI = 1:length(idxs)-1
    vector(nI) = extractNumericValueBetweenCommasInAString(line,idxs(nI),idxs(nI+1));
end
end

function  value = extractNumericValueBetweenCommasInAString(line,idxComma1,idxComma2)
try
    charline = char(line);
    value = str2double(charline(idxComma1+1:idxComma2-1));
catch
    value = NaN;
end
end

function distance = getDistanceToTag(txt,anchorNames)
for nL = 1:length(txt)
    for nA = 1:length(anchorNames)
        line = txt{nL};
        pieceOfLine = extractAfter(line,anchorNames{nA});
        idxPieceOfLineCommas = findCommasIndicesInChar(pieceOfLine);
        if length(idxPieceOfLineCommas) >= 5
            distance(nL,nA) = extractNumericValueBetweenCommasInAString(pieceOfLine,...
                idxPieceOfLineCommas(4),idxPieceOfLineCommas(5));
        else
            distance(nL,nA) = NaN;
        end
    end
end
end

function [dis,anc] = combineAnchorAndDistances(anchorPositions,distancePerAnchor)
idxNotNaN = not(isnan(distancePerAnchor));
for nR = 1:length(distancePerAnchor)
    idx = find(idxNotNaN(nR,:));
    dis{nR,1} = distancePerAnchor(nR,idx);
    anc{nR,1} = anchorPositions(1:2,idx);
end
end
% function [dis,anc] = combineAnchorAndDistances(anchorPositions,distancePerAnchor)
% idxNotNaN = not(isnan(distancePerAnchor));
% rowsWithAtleast3Values = find(sum(idxNotNaN,2)>=3);
% for nR = 1:length(rowsWithAtleast3Values)
%     idx = idxNotNaN(rowsWithAtleast3Values(nR),:);
%     dis{nR,1} = distancePerAnchor(nR,idx);
%     anc{nR,1} = anchorPositions(1:2,find(idx));
% end
% end

function decawavePositions = getDecawavePositions(txt)
keywordDecawavePosition = 'POS';
for nL = 1:length(txt)
    line = txt(nL);
    if contains(line,keywordDecawavePosition)
        pieceOfLine = extractAfter(line,keywordDecawavePosition);
        idxPieceOfLineCommas = findCommasIndicesInChar(pieceOfLine);
        decawavePositions(nL,:) = extractNumbersBetweenCommasInAString(pieceOfLine,idxPieceOfLineCommas(1:4));
    else
        decawavePositions(nL,:)  = [NaN NaN NaN];
    end
end
end