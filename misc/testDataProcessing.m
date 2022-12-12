
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

xxx = Series();
xxx(mm(2015,1):mm(2022,10)) = fred.cpi + 10;

fred.cpi(mm(2015,1:9)) = NaN;
fred.cpi(mm(2020,2:10)) = NaN;

fred.cpi1 = fillMissing(fred.cpi, mm(2010,1):mm(2022,10), xxx);
fred.cpi2 = fillMissing(fred.cpi, mm(2010,1):mm(2022,10), "linear");

fred.cpi3 = [fred.cpi; xxx];





return


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

x = Explanatory.fromFile("model-source/pre-post.model");
xpre = retrieve(x, ":pre");
xpost = retrieve(x, ":post");

startHist = qq(2000,1);
endHist = qq(2022,3);

xxx = simulate(xpre, fred, startHist:endHist);
fred = preprocess(m, fred, startHist:endHist);
yyy = fred;

simDb = simulate( ...
    m, fred, endHist+1:endHist+20 ...
    , prependInput=true ...
);

fred = databank.merge("replace", fred, simDb);

fred = postprocess( ...
    m, fred, endHist+1:endHist+20 ...
    , prependInput=true ...
);

%%



