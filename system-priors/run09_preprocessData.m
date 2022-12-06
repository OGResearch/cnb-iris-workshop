
%% Read US macro data from St Louis Fed FRED database 


%% Clear workspace 

close all
clear


%% Read raw time series form FRED 

list = [
    "GDPC1"
    "CPILEGSL"
    "TB3MS"
    "GS10"
    "DEXUSEU"
    "DJCA"
];


raw = databank.fromFred.data(list);

% databank.toSheet(raw, "csv/raw-fred.csv");

databank.list(raw)

%% Rename series

% raw = databank.fromSheet("csv/raw-fred.csv");

fred = struct();
fred.gdp = raw.GDPC1;
fred.cpi = raw.CPILEGSL;
fred.rs = raw.TB3MS;
fred.r10y = raw.GS10;
fred.eur = raw.DEXUSEU;
fred.psx = raw.DJCA;
fred.const = 1;

%% Convert all series to quarterly
%
% Non-quarterly series will be converted to quarterly by averaging (the
% default method), all quarterly series will stay
%

listDaily = databank.filterFields(fred, value=@(x) isa(x, "Series") && getFrequency(x)==Frequency.DAILY); 
listNondaily = databank.filterFields(fred, value=@(x) isa(x, "Series") && getFrequency(x)~=Frequency.DAILY); 

fred = databank.apply( ...
    fred ...
    , @(x) convert(x, Frequency.Quarterly, "ignoreNaN", false, "method", "mean") ...
    , sourceNames=listNondaily ...
);

fred = databank.apply( ...
    fred ...
    , @(x) convert(x, Frequency.Quarterly, "ignoreNaN", true, "method", "mean") ...
    , sourceNames=listDaily ...
);

load mat/arModel.mat m

startHist = qq(2000,1);
endHist = qq(2022,3);

fred = preprocess(m, fred, startHist:endHist);

simDb = simulate( ...
    m, fred, endHist+1:endHist+20 ...
    , prependInput=true ...
);

fred = databank.merge("replace", fred, simDb);

fred = postprocess( ...
    m, fred, endHist+1:endHist+20 ...
    , prependInput=true ...
);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%{
listLog = ["gdp", "cpi", "eur", "psx"];

fred = databank.apply( ...
    fred ...
    , @(x) 100*log(x) ...
    , sourceNames=listLog ...
    , targetNames="l_"+listLog ...
);

listDiff = databank.filterFields(fred, name=@(n) startsWith(n, "l_"));

% Q/Q rates of change PA
fred = databank.apply( ...
    fred ...
    , @(x) 4*diff(x) ...
    , sourceNames=listDiff ...
    , targetNames="d"+listDiff ...
);

% Y/Y rates of change
fred = databank.apply( ...
    fred ...
    , @(x) diff(x, "yoy") ...        "boy", "eopy"
    , sourceNames=listDiff ...
    , targetNames="d4"+listDiff ...
);


%{
%% Define dates 
%
% These dates will be used also in the estimation exercises
%

startHist = qq(1995,1);
endHist = qq(2021,1);
lastObs = getEnd(fred.gdp);


%% Create databank of observables 
%
% Create a databank with model consistent names and transform the time
% series accordingly
%

h = struct( );
h.obs_l_gdp = 100*log(fred.gdp);
h.obs_dl_cpi = 400*diff(log(fred.cpi));
h.obs_rs = fred.rs;
h.obs_dl_cpi_targ = Series(startHist:lastObs, 2.25);
h.obs_rrs_ex = h.obs_rs - h.obs_dl_cpi;
h.obs_rrs_ex = h.obs_rs{-1} - h.obs_dl_cpi;


%% Save databank and dates to mat and CSV files 

save mat/readDataFromFred.mat h startHist endHist lastObs
databank.toCSV(h, "fred.csv");

%}

