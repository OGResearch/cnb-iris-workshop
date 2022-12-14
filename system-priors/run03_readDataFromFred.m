
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
];

raw = databank.fromFred.data(list);

databank.toSheet(raw, "csv/raw-fred.csv");


%% Rename series

raw = databank.fromSheet("csv/raw-fred.csv");

fred = struct();
fred.gdp = raw.GDPC1;
fred.cpi = raw.CPILEGSL;
fred.rs = raw.TB3MS;
fred.r10y = raw.GS10;


%% Convert all series to quarterly
%
% Non-quarterly series will be converted to quarterly by averaging (the
% default method), all quarterly series will stay
%

fred = databank.apply( ...
    fred ...
    , @(x) convert(x, Frequency.Quarterly, "ignoreNaN", false) ...
);


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


