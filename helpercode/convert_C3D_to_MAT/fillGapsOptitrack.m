% FILLGAPSOPTITRACK
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)

% $Revision: 0.0.0 $  $Date: 2020-09-05 $
% Creation of this function.

function optitrack = fillGapsOptitrack(optitrack)
numberOfSamplesToUse = 500;
idxvector = find(contains(optitrack.names,'RigidBody','IgnoreCase',true));
for i = idxvector'
    tmp = optitrack.coordinates{i};
    tmp(tmp==0)=NaN;
    optitrack.coordinatesNotFilled{i} = tmp;
    optitrack.coordinatesFilled{i} = fillgaps(tmp,numberOfSamplesToUse,1);
end
end

