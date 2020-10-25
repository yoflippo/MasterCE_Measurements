% MAKELATEXTABLESFROM_MEASUREMENT_RESULTS
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)

% $Revision: 0.0.0 $  $Date: 2020-09-16 $
% Creation of this function.

function makeLatexTablesFrom_MEASUREMENT_Results()
close all; clc;

ap.tmp = findSubFolderPath(pwd,'UWB','SIMULATION');
ap.tmp = findSubFolderPath(ap.tmp,'SIMULATION','helper');
addpath(genpath(ap.tmp));

ap.measurement = findSubFolderPath(pwd,'MEASUREMENTS','MEASUREMENT_DATA');
this.Path = fileparts(mfilename('fullpath'));

ap.ThesisPath = findSubFolderPath(pwd,'UWB','THESIS');
ap.output = fullfile(extractBefore(this.Path,'SIMULATION'),ap.ThesisPath,'/TUD_ENS_MSc_Thesis/chapters/results');

cd(ap.measurement); % ASSUME result_*.mat files are in the root

files = dir('*.mat');
files = files(~[files.isdir]);
files(~contains({files.name},'results_')) = [];


%% Go over result files
for nF = 1:length(files)
    ap.CurrFileName = files(nF).name;
    ap.CurrFile = files(nF).folder;
    ap.CurrFullPath = fullfile(ap.CurrFile,ap.CurrFileName);
    
    %% Create table for ranging results
    if contains(ap.CurrFileName,'ranging')
        
        [resStat,resDyn] = cleanAndFormatRangingData(ap);
        dataFormat = {'%.0f',1,'%.1f',6};
        writeTexFile(resStat.matrix,'columnlabels',resStat.colNames,'title',resStat.title, ...
            'filename',resStat.outputFile,'label', resStat.label,'dataformat',dataFormat);
        writeTexFile(resDyn.matrix,'columnlabels',resDyn.colNames,'title',resDyn.title, ...
            'filename',resDyn.outputFile,'label', resDyn.label,'dataformat',dataFormat);
    else
        %% Create table for Pozyx positioning results
        [resStat,resDyn] = cleanAndFormat_POZYXPOSTIONING_Data(ap);
        dataFormat = {'%.0f',1,'%.1f',4};
        writeTexFile(resStat.matrix,'columnlabels',resStat.colNames,'title',resStat.title, ...
            'filename',resStat.outputFile,'label', resStat.label,'dataformat',dataFormat);
        writeTexFile(resDyn.matrix,'columnlabels',resDyn.colNames,'title',resDyn.title, ...
            'filename',resDyn.outputFile,'label', resDyn.label,'dataformat',dataFormat);
    end
end





















%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



    function checkoutCleanData(curr)
        %% Check if clean works out
        if mean([curr.error.dist.clean{:}]) > 1e-12
            keyboard
            error([mfilename ' Can not happen: solver with clean data should work perfectly']);
        end
    end

    function writeTexFile(varargin)
        %% Parse varargin
        % Test for right input
        minargin = 1;
        maxargin = (minargin+5)*2;
        if nargin < minargin
            error([ mfilename ':Needs at minimum' num2str(minargin) ' argument(s) ']);
        end
        if nargin > maxargin
            error([ mfilename ':Needs max ' num2str(minargin) ' arguments ']);
        end
        
        filename = [mfilename '_tex.tex'];
        if nargin > 1
            input.data = varargin{1};
            
            % parse the others
            for narg = 2:nargin
                try
                    sc = lower(varargin{narg});
                    switch sc
                        case {'columnlabels'}
                            input.tableColLabels = varargin{narg+1};
                        case {'title'}
                            input.tableCaption = varargin{narg+1};
                        case {'label'}
                            input.tableLabel = varargin{narg+1};
                        case {'filename'}
                            filename = varargin{narg+1};
                        case {'rowlabels'}
                            input.tableRowLabels = varargin{narg+1};
                        case {'dataformat'}
                            input.dataFormat = varargin{narg+1};
                        otherwise
                            % Do nothing in the case of varargin{narg+1};
                    end
                catch
                end
            end
        end
        
        input.tablePlacement = 'tph';
        input.ms.boldRowLowest = ~contains(filename,'pozyx');
        input.ms.boldRowLowestStartCol = 2;
        input.ms.boldRowLowestStopCol = 4;
        input.ms.firstColumnWholeNumber = false;
        if ~isfield(input,'dataFormat')
            input.dataFormat = {'%.0f',1,'%.1f',length(input.tableColLabels)-1};
        end
        % input.makeCompleteLatexDocument = 1;
        latex = latexTableUWB(input);
        %         %% Restore last row first column, add midrule
        %         idx = find(contains(latex,'999999'));
        %         idxmidrule = find(contains(latex,'\midrule'));
        %         latex2 = [latex(1:idx-1); latex(idxmidrule); latex(idx:end)]
        %         latex = replace(latex2,[num2str(999999)],'Duration');
        
        %% Write to file
        fid=fopen(filename,'w');
        [nrows,~] = size(latex);
        for row = 1:nrows
            fprintf(fid,'%s\n',latex{row,:});
        end
        fclose(fid);
        fclose('all');
    end



% FINDSUBFOLDERPATH
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)

% $Revision: 0.0.0 $  $Date: 2020-09-11 $
% Creation of this function.

    function [output] = findSubFolderPath(absolutePath,rootFolder,nameFolder)
        
        if ~contains(absolutePath,rootFolder)
            error([newline mfilename ': ' newline 'Rootfolder not within absolutePath' newline]);
        end
        startDir = fullfile(extractBefore(absolutePath,rootFolder),rootFolder);
        dirs = dir([startDir filesep '**' filesep '*']);
        dirs(~[dirs.isdir])=[];
        dirs(contains({dirs.name},'.'))=[];
        dirs(~contains({dirs.name},nameFolder))=[];
        if length(dirs)>1
            warning([newline mfilename ': ' newline 'Multiple possible folders found' newline]);
            output = dirs;
        end
        output = fullfile(dirs(1).folder,dirs(1).name);
    end


    function [strStatic,strDynamic] = cleanAndFormatRangingData(apMAT)
        load(apMAT.CurrFullPath);
        % Remove unwanted field, by finding certain keywords
        outputTable = outputTable(:,[2 4 6:9 11]); %only distance error data
        
        
        idx2Remove = contains(outputTable.file,'HF3');
        idx2Remove = idx2Remove | contains(outputTable.file,'90_');
        %         idx2Remove = idx2Remove | contains(outputTable.file,'(~)');
        idx2Remove = idx2Remove | contains(outputTable.file,'_03');
        tab = outputTable(not(idx2Remove),:);
        tab.duration = tab.duration/1000;
        tab.("mean velocity")(isnan(tab.("mean velocity")))=0;
        idxStatic = tab(contains(tab.file,'(S)'),:);
        idxDynamic = tab(contains(tab.file,'(K)') | contains(tab.file,'(~)'),:);
        % Remove column file
        idxStatic.file=[];
        idxDynamic.file=[];
        strStatic.matrix = round(table2array(idxStatic),1);
        strStatic.matrix = [[1:size(strStatic.matrix)]'  strStatic.matrix];
        strDynamic.matrix = round(table2array(idxDynamic),1);
        strDynamic.matrix = [[1:size(strDynamic.matrix)]'  strDynamic.matrix];
        colNames = {'Dataset' 'Larsson','Murphy','Faber','Tag vel. [m/s]','time [s]',' upd. rate [Hz]'};
        strDynamic.colNames = colNames;
        strStatic.colNames = colNames;
        strDynamic.title = {'In this table the results from UWB measurements and the subsequent trileration calculations are presented. The results (Larsson, Murphy and Faber) are expressed in RMS errors [mm]. Also the average Tag velocity is given. In this set of measurements the Tag was moving during the measurements. '};
        strStatic.title = {'In this table the results from UWB measurements and the subsequent trileration calculations are presented. The results (Larsson, Murphy and Faber) are expressed in RMS errors [mm]. Also the average Tag velocity is given. In this set of measurements the Tag did not move. '};
        strStatic.outputFile = fullfile(ap.output,replace(apMAT.CurrFileName,'.mat','_static.tex'));
        strDynamic.outputFile = fullfile(ap.output,replace(apMAT.CurrFileName,'.mat','_dynamic.tex'));
        strDynamic.label = 'tab:meas:res:dynamic:ranging';
        strStatic.label = 'tab:meas:res:static:ranging';
    end

    function [strStatic,strDynamic] = cleanAndFormat_POZYXPOSTIONING_Data(apMAT)
        outputTablePozyxPos = table();
        load(apMAT.CurrFullPath);
        
        outputTable = outputTablePozyxPos(:,[2:5 7]); %only distance error data
        idx2Remove = contains(outputTable.file,'HF3');
        idx2Remove = idx2Remove | contains(outputTable.file,'90_');
        tab = outputTable(not(idx2Remove),:);
        tab.duration = tab.duration/1000;
        idxStatic = tab(contains(tab.file,'(S)'),:);
        idxDynamic = tab(contains(tab.file,'(K)') | contains(tab.file,'(~)'),:);
        
        % Remove column file
        idxStatic.file=[];
        idxDynamic.file=[];
        
        strStatic.matrix = round(table2array(idxStatic),1);
        strStatic.matrix = [[1:size(strStatic.matrix)]'  strStatic.matrix];
        strDynamic.matrix = round(table2array(idxDynamic),1);
        strDynamic.matrix = [[1:size(strDynamic.matrix)]'  strDynamic.matrix];
        colNames = {'Dataset' 'Pozyx','Tag vel. [m/s]','time [s]','upd. rate [Hz]'};
        strDynamic.colNames = colNames;
        strStatic.colNames = colNames;
        strDynamic.title = {'In this table the results from UWB measurements and localization via the proprietary algorithm of Pozyx are presented. The result are expressed in RMS errors [mm]. Also the average Tag velocity is given. In this set of measurements the Tag was moving during the measurements. '};
        strStatic.title = {'In this table the results from UWB measurements and localization via the proprietary algorithm of Pozyx are presented. The result are expressed in RMS errors [mm]. Also the average Tag velocity is given. In this set of measurements the Tag did not move. '};
        strStatic.outputFile = fullfile(ap.output,replace(apMAT.CurrFileName,'.mat','_static.tex'));
        strDynamic.outputFile = fullfile(ap.output,replace(apMAT.CurrFileName,'.mat','_dynamic.tex'));
        strDynamic.label = 'tab:meas:res:dynamic:pozyxpos';
        strStatic.label = 'tab:meas:res:static:pozyxpos';
    end

end




