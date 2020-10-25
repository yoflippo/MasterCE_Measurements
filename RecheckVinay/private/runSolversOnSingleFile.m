function  [result] =runSolversOnSingleFile(apCSVFileDecaWave)
sUWB_data = readAndFormatDataOfVinay(apCSVFileDecaWave);
solverData = sUWB_data.solver;
result.decawaveStuff= sUWB_data;
for nR = 1:length(solverData.distances)
    warning off
    data.AnchorPositions = solverData.anchors{nR}';
    data.Distances = solverData.distances{nR}';
    try
        if length(data.Distances) >= 3
            result.larsson.coord(nR,:) = runOnLarsson(data);
            result.murphy.coord(nR,:) = runOnMurphy1(data);
        end
    catch err
        warning([err.message ', index: ' num2str(nR)])
    end
    warning on
end


    function [result] = runOnLarsson(data)
        result(1:2) = solver_opttrilat(data.AnchorPositions',data.Distances(:))';
    end

    function [result] = runOnMurphy1(data)
        result(1:2) = solver_murphy_1(data.Distances(:),data.AnchorPositions)';
    end

end