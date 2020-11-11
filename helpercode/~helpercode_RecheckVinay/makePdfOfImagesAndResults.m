function [dirPdf,matresults] = makePdfOfImagesAndResults(apImagesAndMatFiles)
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
        load(apCurrentFile.fullpath);
        matresults(nF) = result;
     
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
[data,input.tableRowLabels] = getMatrixFromResults(matresults);
trilaterationTypes = {'Decawave','Murphy','Larsson'};
input.data = data;
input.tablePositioning = 'H';
input.tableColLabels = trilaterationTypes;
input.dataFormat = {'%.3f',3}; % three digits precision for first two columns, one digit for the last
input.dataNanString = '-';
input.tableColumnAlignment = 'l';
input.booktabs = 1;
input.tableCaption = 'MyTableCaption';
input.tableLabel = 'MyTableLabel';
input.makeCompleteLatexDocument = 0;
summary = latexTable(input);

% [R,P]= corrcoef(input.data(:,2), input.data(:,3), 'alpha', 0.001);
% correlation = min(min(R));
% pvalue = min(min(P));
% input = rmfield(input,'tableRowLabels');
% input.tableColLabels = {'Correlation','p-value'};
% input.data = [correlation pvalue];
% input.dataFormat = {'%.6f',2};
% input.tableCaption = 'Pearson correlation Murphy/Larsson, alpha = 0.001';
% input.tableLabel = 'table:stats';
% similarity = latexTable(input);

[Corr,Pval]= corrcoef(data, 'alpha', 0.001);
input = rmfield(input,'tableRowLabels');
input.tableColLabels = trilaterationTypes;
input.data = Corr;
input.dataFormat = {'%.6f'};
input.tableCaption = ['Correlation between ' trilaterationTypes{1} ... 
    ', ' trilaterationTypes{2} ...
    ', ' trilaterationTypes{3} ...
    ', alpha = 0.001'];
input.tableLabel = 'table:stats';
correlationLatex = latexTable(input);

input.data = Pval;
input.tableCaption = ['pvalues of correlation between ' trilaterationTypes{1} ... 
    ', ' trilaterationTypes{2} ...
    ', ' trilaterationTypes{3} ...
    ', alpha = 0.001'];
pvaluesLatex = latexTable(input);

means = mean(data);
stds = std(data);
input.data = [means; stds;];
input.tableRowLabels = {'Mean' 'STD'};
input.tableColLabels = {'Decawave','Murphy','Larsson'};
input.dataFormat = {'%.3f',3}; % three digits precision for first two columns, one digit for the last
input.dataNanString = '-';
input.tableColumnAlignment = 'l';
input.booktabs = 1;
input.tableCaption = 'Descriptive statistics';
input.tableLabel = 'MyTableLabel';
input.makeCompleteLatexDocument = 0;
stats = latexTable(input);

combined = [summary; newline; '\vspace{2em}'; newline; ...
    stats; newline; '\vspace{2em}'; newline; ...
       correlationLatex; newline; '\vspace{2em}'; newline; ...
    pvaluesLatex];

apOutTable = saveFinalTableInTex(combined);
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
    matrix(nL,:) = [r(nL).distances.rmse.decawave ...
        r(nL).distances.rmse.murphy ...
        r(nL).distances.rmse.larsson];
    rowlabels{nL} = replace(r(nL).file.name,'.txt','');
    rowlabels{nL} = replace(rowlabels{nL},'_','\_');
end
end
