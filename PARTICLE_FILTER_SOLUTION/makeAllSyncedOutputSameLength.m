function [uwbsl, optisl, wmpmsl] = makeAllSyncedOutputSameLength(uwb,opti,wmpm,fs)
maxTimeRound = round(min([uwb.time(end) opti.time(end) wmpm.time(end)]));
samplefrequency = fs;
vecTime = 0:1/samplefrequency:max(maxTimeRound);

uwbsl = makeUWBsameLengthWithoutResampling(uwb,vecTime);
optisl = makeRightLength(opti.time,opti.coord,vecTime);
wmpmsl = makeRightLength(wmpm.time,wmpm.coord,vecTime);
wmpmsl.vel = interp1(wmpm.time,wmpm.velframe,vecTime)';
end


function uwbsl = makeUWBsameLengthWithoutResampling(uwb,vecTime)
cntUwb = 1;
for nT = 1:length(vecTime)
    if cntUwb < length(uwb.time) && vecTime(nT) > uwb.time(cntUwb+1)
        cntUwb = cntUwb + 1;
    end
    uwbsl.x(nT) = uwb.coord.x(cntUwb);
    uwbsl.y(nT) = uwb.coord.y(cntUwb);
end
uwbsl.time = vecTime;
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


