function feedData2SolverSingle(apFolderMeasurements)
close all; clc;

if ~exist('apFolderMeasurements','var')
    apThisFile = fileparts(mfilename('fullpath'));
    cd(apThisFile);
    ap.measurements = findSubFolderPath(pwd,'UWB','MEASUREMENT_DATA');
else
    if ~exist(apFolderMeasurements,'dir')
        error([newline mfilename ': ' newline 'Path does not exist' newline]);
    end
    cd(apFolderMeasurements);
    ap.measurements = apFolderMeasurements;
end

ap.simulation = findSubFolderPath(pwd,'UWB','SIMULATION');
addpath(genpath(ap.simulation));

cd(ap.measurements);
files = dir(['**' filesep '*_4solver.mat']);
files(~contains({files.name},'RANG_')) = [];

%% Feed to solver
outputTable(1,:) = table(1,2,3,4,5,6,"test",7,8,9,10,'VariableNames',{'larsson error location','larsson error distance', ...
            'murphy error location','murphy error distance', ...
            'faber error location','faber error distance','file','mean velocity','duration','nsamples','f'});
for nF = 1:length(files)
    try
        pathName = [files(nF).folder filesep];
        fileName = files(nF).name;
        apRawMat = fullfile(pathName,fileName);
        load(apRawMat);
        
        %% Cut bad parts of
        perc = 0.05;
        lendat = length(data.Distances);
        b = round(perc*lendat);
        e = round((1-perc)*lendat);
        idx = b:e;
        data.Distances = data.Distances(idx,:);
        data.DistancesTimes = data.DistancesTimes(idx);
        data.TagPositions = data.TagPositions(idx,:);
        
        %% Run Solver
        for nR = 1:length(data.Distances())
            try
                result.larsson.coord(nR,1:3) = solver_opttrilat(data.AnchorPositions',data.Distances(nR,:))';
                result.murphy.coord(nR,1:3) = solver_murphy_3d(data.Distances(nR,:),data.AnchorPositions)';
                out = solver_fabert_lin2a_3d(data.Distances(nR,:),data.AnchorPositions);
                result.faber.coord(nR,1:3) = out(1:3);
                result.data = data;
            catch err
                warning([err.message ', index: ' num2str(nR)])
            end
        end
        
        %% Plot, and save
        load(replace(apRawMat,'_4solver','_optitrack'));
            
        [result.larsson.errloc,result.larsson.errdis,r.larsson.fig] = ...
            plotTagAnchorMeasurement(data,result.larsson.coord);
        [result.murphy.errloc,result.murphy.errdis,r.murphy.fig] = ...
            plotTagAnchorMeasurement(data,result.murphy.coord);
        [result.faber.errloc,result.faber.errdis,r.faber.fig] = ...
            plotTagAnchorMeasurement(data,result.faber.coord);
        savefig(r.larsson.fig,replace(apRawMat,'_4solver.mat','_larsson_results.fig'));
        savefig(r.murphy.fig,replace(apRawMat,'_4solver.mat','_murphy_results.fig'));
        savefig(r.faber.fig,replace(apRawMat,'_4solver.mat','_faber_results.fig'));      
        save(replace(apRawMat,'_4solver','_results_solver'),'result');
        
        dur = data.DistancesTimes(end)-data.DistancesTimes(1);
        nsamp = length(data.Distances);
        outputTable(nF,:) = table(result.larsson.errloc,result.larsson.errdis,...
            result.murphy.errloc,result.murphy.errdis,...
            result.faber.errloc,result.faber.errdis,string(fileName),...
            data.vel.resMean,dur,nsamp,1000/(dur/nsamp));
        clear result r apRawMat out data
        close all
    catch
    end
end
save('results_ranging.mat','outputTable');
rmpath(genpath(ap.simulation));
end