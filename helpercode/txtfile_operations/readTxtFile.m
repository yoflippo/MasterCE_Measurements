function [oTxt oTxtBelowSep] = readTxtFile(varargin)
%READTXTFILE A simple function that reads every line of a text-based file.
%
% ------------------------------------------------------------------------
%    Copyright (C) 2017  M. Schrauwen (markschrauwen@gmail.com)
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
% ------------------------------------------------------------------------
%
% DESCRIPTION:
%               A function that literally reads a txt-file. Also taking in
%               to account the empty lines. Other functions as: txtscan(),
%               fgetl(), fgets() appear not to have this option. The
%               function fileread() makes one long string of a file, so
%               that is no option.
%
%
% BY: 2017  M. Schrauwen (markschrauwen@gmail.com)
%
% PARAMETERS:
%               fullpath:   the absolute path of a txt-file with filename.
%
% RETURN:
%               outvar:     a cell based variable.
%
% EXAMPLES:
%               [TXTFILE BELOW] = readTxtFile(apDataCopy,'%~>');
%

% $Revision: 0.0.0 $  $Date: 2017-09-15 $
% Creation of the function


%% Parse varargin
minargin = 1;
maxargin = minargin+1;
if nargin < minargin
    error([ mfilename ':Needs at minimum' num2str(minargin) ' argument(s) ']);
elseif nargin > maxargin
    error([ mfilename ':Needs max ' num2str(minargin) ' arguments ']);
end

%% Proces needed input
if nargin >= minargin
    apFile = varargin{1};
end

blSeparatorPresent = false;
if nargin == maxargin
    separator = varargin{2};
    blSeparatorPresent = true;
end

try
    %% Read file (as-is, with spaces and uglyness preserved)
    delimiter = {'\n'};
    formatSpec = '%s';
    fileID = fopen(apFile,'r');
    txt = textscan(fileID, formatSpec,'Whitespace','', 'Delimiter', delimiter,...
        'TextType', 'string',  'ReturnOnError', false);
    fclose(fileID);
    txt = txt{1,1};
    
    %% Assign values
    oTxtBelowSep = [];
    oTxt = txt;
    
    %% Divide txt above/below separator, ignoring the separator
    if blSeparatorPresent
        for nL = 1:length(txt)
            if contains(txt(nL),separator)
                oTxt = txt(1:nL-1);
                oTxtBelowSep = txt(nL+1:end);
                break;
            end
        end
    end 
catch err
    error([newline mfilename ': ' newline err.message newline]);
    fclose('all');
end


end %function readTxtFile
