%% Setup test values
close all; clearvars; clc;
[ap.thisFile, nm.CurrFile] = fileparts(mfilename('fullpath'));


nm.testData = 'SOURCE_DATA';
ap.testData = fullfile(ap.thisFile,nm.testData);

cd(ap.testData);
txtfile = dir('*.txt');

cd(ap.thisFile)
idxNeeded = find(contains({txtfile.name},'ln_expt2_p2_t1'));
testCase.testFile = fullfile(txtfile(idxNeeded).folder,txtfile(idxNeeded).name);
testCase.data = readAndFormatDataOfVinay(testCase.testFile);
runTests(testCase)


%% Place tests BELOW
function simpleCallToRecheckVinayTest(testCase)
try
    data = testCase.data; 
    if not(isfield(data,'anchornames'))
        isError(nameCaller())
    end
    if not(isfield(data,'anchorpositions'))
        isError(nameCaller())
    end
    if not(isfield(data,'distances'))
        isError(nameCaller())
    end
catch err
    isError([nameCaller() ' ' err.message])
end
end

function checkTheValueOfTestFileTest(testCase)
try
    if not(any(testCase.data.solver.distances{1,:}==7.04))
        isError(nameCaller())
    end
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