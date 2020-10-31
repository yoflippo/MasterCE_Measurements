clc; clearvars;
cd(fileparts(mfilename('fullpath')))
load('results_ranging_20200916.mat');

idxs2Remove = contains(outputTable.file,'HF3') | contains(outputTable.file,'03');
outputTable = outputTable(not(idxs2Remove),:);
errorMurphyDistance = outputTable.("murphy error distance");
errorLarssonDistance = outputTable.("larsson error distance");
errorFaberDistance = outputTable.("faber error distance");
alpha = 0.001;
[R,P]= corrcoef([errorMurphyDistance errorLarssonDistance],'alpha', alpha);

correlation = min(min(R));
pvalue = min(min(P));
input.tableColLabels = {'Correlation','p-value'};
input.data = [correlation pvalue];
input.dataNanString = '-';
input.tableColumnAlignment = 'l';
input.booktabs = 1;
input.dataFormat = {'%.6f',2};
input.tableCaption = ['Correlation between Murphy and Larsson and the corresponding p-value with alpha = ' num2str(alpha) '.'];
input.tableLabel = 'table:measurements:murphyvslarsson';
input.makeCompleteLatexDocument = 1;
input.package = '\usepackage{siunitx}';
similarity = latexTable(input);
outputFilename = 'measurementSimilarityMurphyLarsson.tex';
writeTxtfile(fullfile(pwd,outputFilename),similarity);
dos(['xelatex ' outputFilename]);