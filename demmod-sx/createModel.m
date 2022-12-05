%% Simply demography model


%% Clear workspace

clear
close all


%% Load model files

% Number of age cohorts
A = 99;

m = Model.fromFile( ...
    "demmod-sx.model" ...
    , growth=true ...
    , assign=struct("A", A) ...
    , allowExogenous=true ...
    , savePreparsed="__preparsed.model" ...
);


%% Calibrate and solve model

xr = 1;
sr = 0.965;
br = 1.01 ./( sum(sr.^(0:A)) );
fr = br * (1 + xr);
er = 0.95;
pr = 0.70;
nmr = 0;
lpr = 0.50;

m = assign(m, compose("sr%g", 0:A-1), sr);
m = assign(m, compose("sr%g", 0:A), 0);
m = assign(m, compose("br%g", 0:A), br);
m = assign(m, compose("fr%g", 0:A), fr);
m = assign(m, compose("xr%g", 0:A), xr);
m = assign(m, compose("nmr%g", 0:A), nmr);
m.nmr = nmr;

access(m, "parameters")

m1 = m;
m.Q = 1;


%% Calculate steady state

m = steady(m, fixLevel=["Q"]);

checkSteady(m, equationSwitch="steady");
checkSteady(m, equationSwitch="dynamic");

table(m, ["steadyLevel", "steadyChange", "description"], round=7)


