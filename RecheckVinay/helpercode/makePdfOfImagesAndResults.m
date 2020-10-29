function dirPdf = makePdfOfImagesAndResults(apImagesAndMatFiles)
copyTemplateFolderToApSourceAndRename(apImagesAndMatFiles);
cd(apImagesAndMatFiles);

matresults = createImagePages(apImagesAndMatFiles);
latexTable = makeOneFinalTable(matresults);
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

function matresults = createImagePages(ap)
matfiles = dir('*.mat');
apMatFiles = makeFullPathFromDirOutput(matfiles);
for nF = 1:length(matfiles)
    if not(isempty(apMatFiles))
        apCurrentFile = apMatFiles(nF);
        nmImage = replace(apCurrentFile.name,'.mat','.png');
        load(apCurrentFile.fullPath);
        matresults(nF).results = result;
     
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


function apOutTable = makeOneFinalTable(matresults)
[input.data,input.tableRowLabels] = getMatrixFromResults(matresults);
input.tablePositioning = 'h';
input.tableColLabels = {'Decawave','Murphy','Larsson'};
input.dataFormat = {'%.3f',3}; % three digits precision for first two columns, one digit for the last
input.dataNanString = '-';
input.tableColumnAlignment = 'l';
input.booktabs = 1;
input.tableCaption = 'MyTableCaption';
input.tableLabel = 'MyTableLabel';
input.makeCompleteLatexDocument = 0;
apOutTable = saveFinalTableInTex(latexTable(input));
end


function apOutTable = saveFinalTableInTex(latexTable)
nameTemplate = 'template_empty_page.tex';
txt = readTxtFile(nameTemplate);
txt = replace(txt,'<title>','Summary');
txt = [txt{1}; latexTable];
apOutTable = fullfile(pwd,'summaryTable.tex');
writeTxtfile(apOutTable,txt);
end


function [matrix, rowlabels] = getMatrixFromResults(r)
for nL = 1:length(r)
    matrix(nL,:) = [r(nL).results.distances.rmse.decawave ...
        r(nL).results.distances.rmse.murphy ...
        r(nL).results.distances.rmse.larsson];
    rowlabels{nL} = replace(r(nL).results.file.name,'.txt','');
    rowlabels{nL} = replace(rowlabels{nL},'_','\_');
end
end
