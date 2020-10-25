function [] = ancDistanceData()
% ANCDISTANCEDATA simple function to find the max distances between the
% anchors in the principal directions.
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
%

% $Revision: 0.0.0 $  $Date: 2020-09-22 $
% Creation of this function.

cd(fileparts(mfilename('fullpath')));
addpath(genpath(fileparts(mfilename('fullpath'))));

files = dir([pwd filesep '**' filesep '*.mat']);
files([files.isdir])=[]; %only files

load(fullfile(files(1).folder,files(1).name));

ancs = cell2mat(optitrack.Anchors.UWB_Antenna');

minAncs = min(ancs,[],1);
maxAncs = max(ancs,[],1);

disp('Max difference between principal coordinate directions in METERS');
abs(maxAncs-minAncs)/100
end %function
