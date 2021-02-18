% CREATETRILATERATIONSOLVERMATFILE <short description>
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
% DESCRIPTION:
%               Convert the converted measurement data (to .MAT) in an .MAT
%               format that can be given to the solvers
%
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)
%
% PARAMETERS:
%               apOptitrackMat:  absolute path of Optitrack MAT file
%               apPozyxMat:   absolute path of Pozyx MAT file
%
% RETURN:
%               nothing, create a new file with the following
%               struct with the at least the following field :
%                   data.AnchorPositions (numAnc x Dim)
%                   data.TagPositions (row data x Dim)
%                   data.Distances (rows x numAnc)

% $Revisi0n: 0.0.0 $  $Date: 2020-09-09 $
%<Description>

function createTrilaterationSolverMatFile(apOptitrackMat,apPozyxMat)
[file.Opti.folder,file.Opti.name,~] = fileparts(apOptitrackMat);
file.Opti.full = fullfile(file.Opti.folder,[file.Opti.name '.mat']);
if ~exist('apPozyxMat','var') %assume it is in the same directory
    file.Pozyx.folder = file.Opti.folder;
    file.Pozyx.name = replace(file.Opti.name,'optitrack','pozyx');
    file.Pozyx.full = fullfile(file.Pozyx.folder,[file.Pozyx.name '.mat']);
else
    [file.Pozyx.folder,file.Pozyx.name,~] = fileparts(apPozyxMat);
    file.Pozyx.full = fullfile(file.Pozyx.folder,[file.Pozyx.name '.mat']);
end

if ~exist(file.Pozyx.full,'file') || ~exist(file.Opti.full,'file')
    keyboard
    error([newline mfilename ': ' newline 'Mat Files not found!' newline]);
end

load(file.Pozyx.full);
load(file.Opti.full);
if ~(exist('optitrack','var') && exist('pozyx','var'))
    error([newline mfilename ': ' newline 'The right fields are not present!' newline]);
end

%% Create the needed struct fields:

% data.AnchorPositions
data.AnchorPositions = cell2mat(optitrack.Anchors.UWB_Antenna')*10; %*10 to go from cm to mm

%% data.Distances
% This is harder: the Pozyx system has a very limited update rate... so now
% we need to assume that all measurements are done at the same moment...
try
    minLengthData = Inf;
    
    num.Anchors = length(pozyx.data);
    diffTimes = [];
    for nF = 1:num.Anchors
        minLengthData = min(minLengthData,length(table2array(pozyx.data(nF).range)));
        startTimes(nF) = pozyx.data(nF).time{1,1};
        endTimes(nF) = pozyx.data(nF).time{end,1};
        diffTimes = [diffTimes; diff(pozyx.data(nF).time{:,1})];
    end
    
    % Check which one sample is first IN TIME
    [~,idx] = sort(startTimes);
    
    % Assign the values to the timestamps
    for nF = 1:minLengthData
        for nA = idx
            data.Distances(nF,nA) = table2array(pozyx.data(nA).range(nF,1));
            % Get the timestamp of the first tag and
            data.DistancesTimes(nF) = table2array(pozyx.data(idx(1)).time(nF,1));
        end
    end
    
    %% INTERPOLATE THE VALUES
    newTimeVector = min(startTimes):mean(diffTimes)/4:min(endTimes)';
    for nA = 1:num.Anchors
        data.Distances2(:,nA) = interp1(pozyx.data(nA).time{:,1},pozyx.data(nA).range{:,1},newTimeVector)';
    end
    data.DistancesTimes0 = data.DistancesTimes;
    data.DistancesTimes = newTimeVector';
    data.Distances0 = data.Distances;
    data.Distances = data.Distances2;
    % END OF INTERPOLATION
    
    %% Filter the distance data by 'repairing' it with fillgaps()
    data.Distances(data.Distances==Inf)=NaN;
    for nA = 1: num.Anchors
        data.Distances(:,nA) = round(fillgaps(data.Distances(:,nA)));
    end
    
    % round to nearest 10 to find a match in optitrack time
    timesRoundNears = roundn(data.DistancesTimes,1);
    
    %% data.TagPositions
    % Create Optitrack time vector
    numSamplesSync = length(optitrack.Tag.Coordinates);
    data.TagPositionsTime = round((0:1/optitrack.fs:(numSamplesSync-1)/optitrack.fs)'*1000);
    
    for nT = 1:length(timesRoundNears)
        idx = find(timesRoundNears(nT)==data.TagPositionsTime);
        if isempty(idx)
            %             keyboard % something is wrong
            return;
        end
        data.TagPositions(nT,1:3) = optitrack.Tag.Coordinates(idx(1),:)*10; %*10 to go from cm to mm
    end
    
    % Save original data JUST IN CASE
    data.optitrack = optitrack;
    data.pozyx = pozyx;
    
    %% Save the data in an MAT file
    save(replace(file.Opti.full,'_optitrack','_4solver'),'data');
catch err
    warning(err.message);
    %     keyboard
end
end

