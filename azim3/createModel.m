
close all
clear

modelFiles = [
    "model-source/azim-world.model"
    "model-source/azim-trend.model"
    "model-source/azim-core.model"
];

m = Model.fromFile( ...
    modelFiles ...
    , growth=true ...
    , defaultStd=1 ...
    , markdown=true ...
);


tuneNames = byAttributes(m, ":tunes");
m = assign(m, "std_"+tuneNames, 0);

% Get and assign baseline parameters
p = getBaselineCalibration();
m = assign(m, p);

% Steady-state and trend parameters
m = steady(m, blocks=false);
checkSteady(m);
m = solve(m);

% mm = alter(m, 2);
% mm.ss_dl_re_tw = [3.5, 2];
% mm = steady(mm);
% table(mm, "steadyLevel", round=8)

save mat/createModel.mat m

