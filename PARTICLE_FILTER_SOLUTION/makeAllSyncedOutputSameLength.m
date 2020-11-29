function [uwbsl, optisl, wmpmsl] = makeAllSyncedOutputSameLength(uwb,opti,wmpm)
maxTimeRound = round(min([uwb.time(end) opti.time(end) wmpm.time(end)]));
samplefrequency = 10;
vecTime = 0:1/samplefrequency:max(maxTimeRound);

uwbsl = makeRightLength(uwb.time,uwb.coord,vecTime);
optisl = makeRightLength(opti.time,opti.coord,vecTime);
wmpmsl = makeRightLength(wmpm.time,wmpm.coord,vecTime);
wmpmsl.vel = interp1(wmpm.time,wmpm.velframe,vecTime)';
end

function var = makeRightLength(varTime,varCoord,time)
var.x = interp1(varTime,varCoord.x,time)';
var.y = interp1(varTime,varCoord.y,time)';
var.time = time;
var = makeNaNZeroStruct(var);
end

function str = makeNaNZeroStruct(str)
str.x = makeNaNZero(str.x);
str.y = makeNaNZero(str.y);
end

function input = makeNaNZero(input)
input(isnan(input)) = 0;
end