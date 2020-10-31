% CUTDATATOSYNCMOMENT
% BY: 2020  M. Schrauwen (markschrauwen@gmail.com)

% $Revision: 0.0.0 $  $Date: 2020-09-06 $
% Creation of this function.

function [optiSync] = cutDataToSyncMoment(optitrack)
optiSync = optitrack;

%% Find sync RigidBody
idxSyncMarkers = contains(optiSync.names,'Sync','IgnoreCase',true);

if ~any(idxSyncMarkers) % Do some manual stuff
    % Most likely due to the presence of an IR led for syncing purposes the
    % first unlabeled marker is the sync marker. Here YOU should find the
    % start and stop moment
    
    % Find first unlabeld marker, ask user if this is a sync marker, if so,
    % let the user select the first moment in time when it starts and stops
    idxUnlabMarker = find(contains(optiSync.names,'Unlabeled','IgnoreCase',true));
    tmp_idx = idxUnlabMarker(1);
    plot(optiSync.coordinates{tmp_idx});
    if input('Is this a Sync Marker set? Yes=1, No=0: ')
        disp('Please zoom in to start sync and press enter');
        pause
        [s.Start,~] = ginput(1);
        disp('Please zoom to END of the sync signal and press enter and selected it');
        pause
        [s.Stop,~] = ginput(1);
    else
        disp('Please manually find the sync marker and create the needed vars');
        keyboard
    end
else % Determine start en stop of syncing rigid body
    idxSM = find(idxSyncMarkers);
    tmpData = optiSync.coordinates{idxSM(1)};
    tmpData(tmpData~=0)=1;
    tmpDataSum = sum(tmpData,2);
    idxs = find(tmpDataSum==3);
    s.Start = idxs(1);
    s.Stop = idxs(end);
end

%% Cut the coordinates
s.Start = round(s.Start);
s.Stop = round(s.Stop);
optiSync.coordinatesRaw = optiSync.coordinates;
optiSync = rmfield(optiSync,'coordinates');
for nC = 1:length(optiSync.coordinatesRaw)
    optiSync.coordinates{nC} = optiSync.coordinatesRaw{nC}(s.Start:s.Stop,:);
end

optiSync.SyncIdx = s;
end

