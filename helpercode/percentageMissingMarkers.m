function averagePercentage = percentageMissingMarkers()
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));
cd(ap.thisFile)
cd ..
cd synced

files = dir(['**' filesep '*.mat']);
files = files(~[files.isdir]); % remove directories
files = makeFullPathFromDirOutput(files);

for nF = 1:length(files)
   load(files(nF).fullpath);
   data = sOpti.Tag.NotFilled.Coordinates(:,1);
   percentage(nF) = sum(isnan(data))/length(data);
end
averagePercentage = mean(percentage);
end