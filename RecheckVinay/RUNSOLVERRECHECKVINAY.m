close all; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));

cd(ap.thisFile);
nm.OUTPUT = 'OUTPUT';
ap.OUTPUT = fullfile(pwd,nm.OUTPUT);
cd ..
ap.RecheckVinay = fullfile(pwd,'RecheckVinay');
ap.CODE = fullfile(pwd,'CODE'); cd ..
ap.SIMULATION = fullfile(pwd,'SIMULATION');

addpath(genpath(ap.RecheckVinay));
addpath(genpath(ap.SIMULATION));
addpath(genpath(ap.CODE));

nm.testData = 'SOURCE_DATA';
ap.testData = fullfile(ap.thisFile,nm.testData);

cleanOutputDir(ap.OUTPUT);
txtfiles = getMeasurementFilesInTxtFormatOfVinay(ap);

for nF = 1:length(txtfiles)
    result = runSolversOnSingleFile(txtfiles(nF).fullPath);
    result.file = txtfiles(nF);
    walkingLines = getLinesOfVinay();
    plotToCompareDecawaveWithMurphy(result,walkingLines,ap)
    result.distances = getShortestDistanceOfVinayData(result,walkingLines);
    preparedOutputName = replace(txtfiles(nF).name,'.txt','.mat');
    preparedOutputName = fullfile(ap.OUTPUT,preparedOutputName);
    save(preparedOutputName,'result');
end

[dirPdf,matresults] = makePdfOfImagesAndResults(ap.OUTPUT);

plotCDFsOfDistances(matresults)















rmpath(genpath(ap.RecheckVinay));
rmpath(genpath(ap.SIMULATION));

function plotToCompareDecawaveWithMurphy(results,walkingLines,ap)
close all;
figure('units','normalized','outerposition',[0 0 0.5 0.5],'Visible','off');

scatter(walkingLines(:,1),walkingLines(:,2),'k.','Linewidth',1);
hold on;
scatter(results.decawaveStuff.decawavePositions(:,1),...
    results.decawaveStuff.decawavePositions(:,2),'bs','Linewidth',2)
scatter(results.murphy.coord(:,1),results.murphy.coord(:,2),'r*','Linewidth',2)
scatter(results.larsson.coord(:,1),results.larsson.coord(:,2),'gx','Linewidth',2)
grid on; grid minor;
xlabel('x-coordinates'); ylabel('y-coordinates');
xlim([0 20]); ylim([2 26]);
saveTightFigure(gcf,replace(fullfile(ap.OUTPUT,results.file.name),'.txt','.png'));
end

function cleanOutputDir(ap)
if exist(ap,'dir')
    try
    rmdir(ap,'s');
    catch
    end
end
mkdir(ap);
end

function txtfile = getMeasurementFilesInTxtFormatOfVinay(ap)
cd(ap.testData);
txtfile = makeFullPathFromDirOutput(dir('*.txt'));
cd(ap.thisFile)
end

