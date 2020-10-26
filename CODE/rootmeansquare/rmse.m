function [rms] = rmse(differencevector)
[r,c] = size(differencevector);
if r>1 && c>1
    error([newline mfilename mfilename ': ' newline blanks(30) ...
        ': Input "vector" is not a vector' newline]);
end
rms = sqrt(sum(differencevector.^2)/length(differencevector));
end

