function createTrilaterationSolverMatFile_run(apFolder)

if ~exist('apFolder','var')
    apThisFile = fileparts(mfilename('fullpath'));
    cd(apThisFile);
    cd(findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA'));
else
    if ~exist(apFolder,'dir')
        error([newline mfilename ': ' newline 'Path does not exist' newline]);
    end
    cd(apFolder);
end

% Read the previously saved cut files
files = dir(['**' filesep '*_optitrack.mat']);
for i = 1:length(files)
    pathName = [files(i).folder filesep];
    fileName = files(i).name;
    apRawMat = fullfile(pathName,fileName);
    if exist(apRawMat,'file')
        createTrilaterationSolverMatFile(apRawMat);
    end
end

end