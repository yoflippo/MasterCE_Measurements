function writetxtfile(apFile,txt)
%WRITETXTFILE A very simple function that write a txt (cell)array to a
%file.
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
%
% 
% BY: 2017  M. Schrauwen (markschrauwen@gmail.com)
% 
% PARAMETERS:
%               apFile:  The absolute path of a file with extension.
%               txt:   a (cell)array containing text.
%
% RETURN:       
%               nothing.
% 
% EXAMPLES:
%
%

% $Revision: 0.0.0 $  $Date: 2017-10-06 $
% Creation of this function.



try
    %% Check absolute path
    [path filename ext] = fileparts(apFile);
    
    if isempty(path)
        error([mfilename ': you should specify a path.']);
    elseif isempty(filename)
        error([mfilename ': you should specify a filename.']);
    elseif isempty(ext)
        error([mfilename ': you should specify an extension.']);
    end
    
    %% Write to file
    fileID = fopen(apFile,'W');
    if iscell(txt)
        for i = 1:length(txt)
            fprintf(fileID,'%s\r\n',txt{i});
        end
    else
        for i = 1:length(txt)
            fprintf(fileID,'%s\r\n',txt(i));
        end
    end
    fclose(fileID);
    
catch err
    fclose(fileID);
    warning(err)
    error([mfilename ': Could not write to the file']);
end


end %function


