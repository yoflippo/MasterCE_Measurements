function RUNSOLVERRECHECKVINAY()
close all; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));

cd(ap.thisFile); cd ..
ap.RecheckVinay = fullfile(pwd,'RecheckVinay'); cd ..
ap.SIMULATION = fullfile(pwd,'SIMULATION');
addpath(genpath(ap.RecheckVinay));
addpath(genpath(ap.SIMULATION));

nm.testData = 'SOURCE_DATA';
ap.testData = fullfile(ap.thisFile,nm.testData);

walkingLines = getLinesOfVinay();

try
    cd(ap.testData);
    %     txtfile = makeFullPathFromDirOutput(dir('*.txt'));
    
    txtfile = makeFullPathFromDirOutput(dir('ln_expt2_p2_t3.txt'));
    cd(ap.thisFile)
    
    for nF = 1:length(txtfile)
        result = runSolversOnSingleFile(txtfile(nF).fullPath);
    end
    plotToCompareDecawaveWithMurphy(result)
catch
end
rmpath(genpath(ap.RecheckVinay));
rmpath(genpath(ap.SIMULATION));

    function plotToCompareDecawaveWithMurphy(results)
        scatter(walkingLines(:,1),walkingLines(:,2),'k.','Linewidth',1);
        hold on;
        scatter(results.decawaveStuff.decawavePositions(:,1),...
            results.decawaveStuff.decawavePositions(:,2),'bs','Linewidth',2)
        scatter(results.murphy.coord(:,1),results.murphy.coord(:,2),'r*','Linewidth',2)
        scatter(results.larsson.coord(:,1),results.larsson.coord(:,2),'gx','Linewidth',2)
        grid on; grid minor;
        xlabel('x-coordinates'); ylabel('y-coordinates');
    end
end