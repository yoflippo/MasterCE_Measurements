function convert_PozyxPositioning_to_MAT(apFile)
% CONVERT_POZYXPOSITIONING_TO_MAT <short description>
%
% ------------------------------------------------------------------------
%    Copyright (C) 2020  M. Schrauwen (markschrauwen@gmail.com)
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
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)
% 

% $Revision: 0.0.0 $  $Date: 2020-09-13 $
% Creation of this function.
oldPath = pwd;
tab = read_Pozy_Positioning(apFile);
idx = find(tab.err);
tab(idx,2:end-1) = {NaN};
tab.x = round(fillgaps(tab.x));
tab.y = round(fillgaps(tab.y));
tab.z = round(fillgaps(tab.z));
pozyx = table2struct(tab,'ToScalar',true);
pozyx.Tag = table2array(table(tab.x,tab.y,tab.z));
[ap,nm,ext] = fileparts(apFile);
cd(ap);
save([nm '_pozyx.mat'],'pozyx');
cd(oldPath)
end %function




function [OUT] = read_Pozy_Positioning(apFile)

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 5);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["Time", "x", "y", "z", "err"];
opts.VariableTypes = ["double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["Time", "x", "y", "z", "err"], "DecimalSeparator", ",");

% Import the data
OUT = readtable(apFile, opts);



end
