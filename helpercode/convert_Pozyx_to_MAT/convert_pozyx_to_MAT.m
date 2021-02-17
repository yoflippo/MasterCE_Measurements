function convert_pozyx_to_MAT()

apThisFile = fileparts(mfilename('fullpath'));
cd(apThisFile);
cd(findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA'));
files = dir(['**' filesep '*.txt']);
files(~contains({files.name},'(')) = [];
files(~contains({files.name},')')) = [];

for i = 1:length(files)
    pathName = [files(i).folder filesep];
    fileName = files(i).name;
    pozyx.name = files(i).name;
    pozyx.path = pathName;
    data = readPozyx(fullfile(pathName,fileName));
    pozyx.data = filterAnchors(data);
    
    save(fullfile(pathName,replace(fileName,'.txt','_pozyx.mat')),'pozyx');
    clear optitrack
end
end