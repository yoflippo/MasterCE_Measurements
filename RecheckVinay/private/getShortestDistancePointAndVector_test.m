%% Setup test values
testCase.empty = '';
runTests(testCase)


%% Place tests BELOW
function checkValueSmallVector(testCase)
try
    assert(0==getShortestDistancePointAndVector([0 0],[-1 -1; 0 0; 1 1]))
catch err
    isError([nameCaller() ' ' err.message])
end
end

function checkDistanceOne(testCase)
try
    assertSomeValues([0 0],-1)
    assertSomeValues([0 0],101)
    assertSomeValues([0 0],1)
    assertSomeValues([0 0],101)
catch err
    isError([nameCaller() ' ' err.message])
end

    function assertSomeValues(p,value)
        assert(abs(value)==getShortestDistancePointAndVector(p,[-Inf -Inf; 0 value; Inf Inf]))
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
