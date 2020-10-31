function  [result] =runSolversOnSingleFile(apCSVFileDecaWave)

sUWB_data = readAndFormatDataOfVinay(apCSVFileDecaWave);
solverData = sUWB_data.solver;
result.decawaveStuff= sUWB_data;
for nR = 1:length(solverData.distances)
    warning off
    data.AnchorPositions = solverData.anchors{nR}';
    data.Distances = solverData.distances{nR}';
    try
        result.larsson.coord(nR,:) = ...
            SpecificCleanupForVinayMeasurement(data,@runOnLarsson);
        result.murphy.coord(nR,:) = ...
            SpecificCleanupForVinayMeasurement(data,@runOnMurphy1);
        result.faber.coord(nR,:) = ...
            SpecificCleanupForVinayMeasurement(data,@runOnFaber);
    catch err
        warning([err.message ', index: ' num2str(nR)])
    end
    warning on
end

    function out = SpecificCleanupForVinayMeasurement(data,func)
        try
            tmp = NaNifAllAreZero(func(data));
            tmp = NaNifAllAnyAreBelowZero(tmp);
            out = NaNifAllAreOutsidePerimeter(tmp,26);
        catch
            out = NaN(1:2);
        end
    end

    function [result] = runOnLarsson(data)
        result(1:2) = solver_opttrilat(data.AnchorPositions',data.Distances(:))';
    end

    function [result] = runOnMurphy1(data)
        result(1:2) = solver_murphy_1(data.Distances(:),data.AnchorPositions)';
    end

    function [result] = runOnFaber(data)
        tmp = solver_fabert_lin2a(data.Distances(:)',data.AnchorPositions)';
        result = tmp(1:2);
    end

    function out = NaNifAllAreZero(coordinates)
        if all(coordinates==0)
            out = NaN(size(coordinates));
        else
            out = coordinates;
        end
    end

    function out = NaNifAllAreOutsidePerimeter(coordinates,maxValue)
        if any(abs(coordinates)>maxValue)
            out = NaN(size(coordinates));
        else
            out = coordinates;
        end
    end

    function out = NaNifAllAnyAreBelowZero(coordinates)
        if any(coordinates<0)
            out = NaN(size(coordinates));
        else
            out = coordinates;
        end
    end


end