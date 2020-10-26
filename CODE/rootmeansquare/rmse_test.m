%% Setup test values
testCase.var = [0 0 0 0 0 0];
runTests(testCase)


%% Place tests BELOW
function simpleCallToRecheckVinayTest(testCase)
try
    assert(rmse(testCase.var)==0);
    assert(rmse([2 2 2 2 2 2 2 2 2])==2);
    assert(rmse([2 2 2 2 2 2 2 2 2]')==2);
    assert(round(rmse([3 1 1 2 6 4 4 3 2 0 1 0 1 1 3 4 2 1 2 3]),4)==2.6646);
catch err
   isError([nameCaller() ' ' err.message])
end
end


%% Place tests ABOVE






















function runTests(testCase)
localfunctionsVar = localfunctions;
if not(isempty(localfunctionsVar))
    for nT = 1:length(localfunctionsVar)-3
        currentFunction = localfunctionsVar{nT};
        currentFunction(testCase);
    end
    disp([mfilename ' Tests runned succesfull']);
else
    disp([mfilename ' Tests NOT runned!!']);
end
end

function isError(infoTxt)
error([newline mfilename ': ' newline blanks(30) infoTxt ': LOOK HERE' newline]);
end

function name = nameCaller()
    stack = dbstack;
    name = stack(2).name;
end
