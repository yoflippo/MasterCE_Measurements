function RANGCARK00 = readPozyx(fullfilename)

%% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 7);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["VarName1", "E02", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7"];
opts.VariableTypes = ["double", "char", "double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "E02", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "E02", "EmptyFieldRule", "auto");

% Import the data
RANGCARK00 = readtable(fullfilename, opts);


%% Clear temporary variables
clear opts

end

