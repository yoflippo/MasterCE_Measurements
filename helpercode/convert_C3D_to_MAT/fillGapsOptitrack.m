% FILLGAPSOPTITRACK
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)

% $Revision: 0.0.0 $  $Date: 2020-09-05 $
% Creation of this function.

function optitrack = fillGapsOptitrack(optitrack)
numberOfSamplesToUse = 500;

%% Find RigidBodies
idxvector = find(contains(optitrack.names,'RigidBody','IgnoreCase',true));
%% Fill RigidBodies
for i = idxvector'
    tmp = optitrack.coordinates{i};
    tmp(tmp==0)=NaN;
    optitrack.coordinatesFilled{i} = fillgaps(tmp,numberOfSamplesToUse,1);
    optitrack.coordinatesNotFilled{i} = tmp;
    % =========== TEST ===========
    %     try
    %          plot(optitrack.coordinates{i}-optitrackFilled.coordinatesFilled{i});
    %         hold on;
    %     catch
    %         keyboard
    %     end
end
% pause; close all;
% =========== TEST ===========
end

