function test()
cd(fileparts(mfilename('fullpath')));
files = dir(['synced_measurement_data'  filesep '*.mat']);
load(makeFullPathFromDirOutput(files(1)).fullpath);
checkToImproveUWB(uwb,opti)
end

