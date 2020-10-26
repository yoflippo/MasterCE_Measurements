function dirPdf = makePdfOfImagesAndResults(apImagesAndMatFiles)
copyTemplateFolderToApSourceAndRename(apImagesAndMatFiles);
cd(apImagesAndMatFiles);

createImagePages(apImagesAndMatFiles);
fillTheTemplateWithReferencesToSeparateTexFiles(apImagesAndMatFiles);
nameTemplate = renameTemplateTex(apImagesAndMatFiles);
dos(['xelatex ' nameTemplate]);
dirPdf = makeFullPathFromDirOutput(dir(replace(nameTemplate,'.tex','.pdf')));
end

function copyTemplateFolderToApSourceAndRename(apImagesAndMatFiles)
nameTemplateFolder = 'template_tex';
apTemplateTex = fullfile(fileparts(mfilename('fullpath')),nameTemplateFolder);
copyfile(fullfile(apTemplateTex,'*'),apImagesAndMatFiles);
end

function [nameTemplate] = renameTemplateTex(apOutputDirectory)
[~,currentDirectory] = fileparts(apOutputDirectory);
nameTemplate = [currentDirectory '.tex'];
movefile('template.tex',nameTemplate);
end

function createImagePages(ap)
matfiles = dir('*.mat');
apMatFiles = makeFullPathFromDirOutput(matfiles);
for nF = 1:length(matfiles)
    if not(isempty(apMatFiles))
        apCurrentFile = apMatFiles(nF);
        nmImage = replace(apCurrentFile.name,'.mat','.png');
        load(apCurrentFile.fullPath);
        if nF < 10
            currentTexFileName = ['0' num2str(nF) '.tex'];
        else
            currentTexFileName = [num2str(nF) '.tex'];
        end
        copyfile('template_page.tex',currentTexFileName);
        txt = readTxtFile(currentTexFileName);
        txt = fillTxtForLatexFileWithRMSEValueMakeBoldSmallest(txt,result);
        prepareTitle = replace(extractBefore(apCurrentFile.name,'.mat'),'_','\_');
        txt = replace(txt,'<title>',prepareTitle);
        txt = replace(txt,'<image>',nmImage);
        writeTxtfile(fullfile(ap,currentTexFileName),txt);
    end
end
end

function txt = fillTxtForLatexFileWithRMSEValueMakeBoldSmallest(txt,result)
% Order matters and is based on the struct order
txt = replace(txt,'<rmsemurphy>',makeBoldIfLowest(1,result.distances.rmse));
txt = replace(txt,'<rmsedecawave>',makeBoldIfLowest(2,result.distances.rmse));
txt = replace(txt,'<rmselarsson>',makeBoldIfLowest(3,result.distances.rmse));

    function bf = makeBoldIfLowest(idx,rmsevalues)
        values = struct2array(rmsevalues);
        minval = min(values);
        currentValue = values(idx);
        if find(minval==values)==idx
            bf = ['\textbf{' num2str(currentValue) '}'];
        else
            bf = num2str(currentValue);
        end
    end
end

function fillTheTemplateWithReferencesToSeparateTexFiles(apImagesAndMatFiles)
nameTemplate = 'template.tex';
txt = readTxtFile(nameTemplate);
filesToAdd = collectTheFilesToPutinTheMasterTexFile(apImagesAndMatFiles);
lineToAdd = convertCellWithStringsToCharacterArray(filesToAdd);
txt = replace(txt,'<inputstexfiles>',lineToAdd);
writeTxtfile(fullfile(apImagesAndMatFiles,nameTemplate),txt);
end

function [filesToAdd] = collectTheFilesToPutinTheMasterTexFile(apImagesAndMatFiles)
filesToAdd = [];
texfiles = dir('*.tex');
[~,outputname] = fileparts(apImagesAndMatFiles);
texfiles(contains({texfiles.name},outputname))=[];
texfiles(contains({texfiles.name},'template'))=[];
texfiles = sortRowsStruct(texfiles);
for nF = 1:length(texfiles)
    filesToAdd = [filesToAdd ['\input{' texfiles(nF).name '}'] newline];
end
end

function sortedStruct = sortRowsStruct(str)
T = struct2table(str);
sortedT = sortrows(T, 'name');
sortedStruct = table2struct(sortedT);
end

function ca = convertCellWithStringsToCharacterArray(cws)
if iscell(cws)
    ca = cws{1};
    for nF = 2:length(cws)
        ca = [ca  newline cws{nF}];
    end
else
    ca = cws;
end
end

