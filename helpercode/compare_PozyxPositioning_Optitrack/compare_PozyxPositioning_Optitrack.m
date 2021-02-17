function compare_PozyxPositioning_Optitrack()
close all; clc;

apThisFile = fileparts(mfilename('fullpath'));
cd(apThisFile);
% ap.code_measurements = findSubFolderPath(pwd,'MEASUREMENTS','CODE');
% addpath(genpath(ap.code_measurements));
ap.measurements = findSubFolderPath(pwd,'UWB','MEASUREMENT_DATA');
ap.simulation = findSubFolderPath(pwd,'UWB','SIMULATION');
addpath(genpath(ap.simulation));


cd(ap.measurements);
files = dir(['**' filesep '*_4solver.mat']);
files(~contains({files.name},'PFST_')) = [];

%% Feed to solver
outputTablePozyxPos(1,:) = table(1,2,"test",3,4,5,5,'VariableNames',{ ...
    'pozyxpos error location','pozyxpos error distance ','file','mean velocity','duration','nsamples','f'});
for nF = 1:length(files)
    try
        pathName = [files(nF).folder filesep];
        fileName = files(nF).name;
        apRawMat = fullfile(pathName,fileName);
        load(apRawMat);
        
        %% Cut bad parts of
        perc = 0.05;
        lendat = length(data.TagPositions);
        b = round(perc*lendat);
        e = round((1-perc)*lendat);
        idx = b:e;
        data.TagPositions = data.TagPositions(idx,:);
        data.pozyx.Tag = data.pozyx.Tag(idx,:);
        data.DistancesTimes = data.pozyx.Time(idx,:);
        %% Plot, and save
%         load(replace(apRawMat,'_4solver','_optitrack'));
        
        [result.pozyxpos.errloc,result.pozyxpos.errdis,r.pozyxpos.fig] = ...
            plotTagAnchorMeasurement_midterm(data,data.pozyx.Tag);
        savefig(r.pozyxpos.fig,replace(apRawMat,'_4solver.mat','_pozyxpos_results.fig'));
        save(replace(apRawMat,'_4solver','_results'),'result');
        
        dur = data.DistancesTimes(end)-data.DistancesTimes(1);
        nsamp = length(data.DistancesTimes);
        outputTablePozyxPos(nF,:) = table(result.pozyxpos.errloc,result.pozyxpos.errdis...
            ,string(fileName),data.vel.resMean,dur,nsamp,1000/(dur/nsamp));
        clear result r apRawMat out
        close all
    catch err
        warning(err.message)
    end
end
save('results_pozyxpos.mat','outputTablePozyxPos');
rmpath(genpath(ap.simulation));
end