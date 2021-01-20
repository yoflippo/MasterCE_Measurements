function combine_PozyxPositioningWithOptitrack_MatFile_run()

apThisFile = fileparts(mfilename('fullpath'));
cd(apThisFile);
cd(findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA'));

% Read the previously saved cut files
files = dir(['**' filesep '*_optitrack.mat']);
files = files(~[files.isdir]);
files(~contains({files.name},'PFST_')) = [];
for i = 1:length(files)
    pathName = [files(i).folder filesep];
    fileName = files(i).name;
    apRawMat = fullfile(pathName,fileName);
    combine_PozyxPositioningWithOptitrack_MatFile(apRawMat)
end

end


