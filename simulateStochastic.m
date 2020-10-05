%% Stochastic Simulations in Nonlinear Models
%
% Set up and run simulations of unanticipated shocks. Non-linear
% simulations in Iris are equivalent to a perfect-foresight solution. This
% does not mean unanticipated stochastic shocks cannot be simulated: it
% only means that simulations of such shocks must be split into a number of
% overlapping sub-simulations (called frames), depending on the occurence
% of unanticipated shocks.

%% Clear Workspace

clear
close all


%% Load Model Object

load mat/createModel.mat m


%% Parameterize Std Deviations of Shocks
%
% Assign some values to the std deviations of shocks. These values are used
% when shocks are randomly drawn and simulated. There is no need to resolve
% the model after new std deviations have been changed since they do not
% affect the first-order approximate solution matrices.


m.std_er = 0.2;
m.std_ey = 0.4;
m.std_epi = 0.4;
m.std_et = 0;


%% Create Steady-State Database with Random Shocks
%
% Call the function `sstatedb` to create a database with each model being
% variable assigned its steady-state value. The range on which these time
% series are created on a range -2:20, and not just 1:20 as the second
% input argument says. This is because `sstatedb` automatically looks up
% the maximum lag in the model and adjusts the range accordingly to include
% all necessary initial conditions so that a simulation can start at time
% t=1.
%
% With the option `shockFunc=@randn`, the model shocks are randomly drawn
% on the range 1:20 from a normal distribution with mean zero and std
% deviations given by the model object.

rng(0);
d = steadydb(m, 1:20, "shockFunc", @randn);


%% Linearized Simulation
%
% First, simulate the random shocks using first-order approximate solution
% (linearized model). The shocks are simulated as unanticipated. Note that
% credibility plays no role in this simulation, because the level of
% credibility has no first-order effects in the model equations.

d1 = d;
[s1, info1] = simulate( ...
    m, d, 1:20 ...
    , "prependInput", true ...
    , "anticipate", false ...
);

%% Nonlinear Simulations
%
% Next, simulate the random shocks using a nonlinear simulation method: a
% so-called stacked-time algorithm. Because the shocks are unanticipated,
% the whole simulation range, 1:20, must be segmented into so-called
% simulation frames, defined by the occurence of unanticipated shocks. As a
% result, a total of 20 overlapping sub-simulations, one for each frame,
% will be run. 
%
% * Because there is an unanticipated shock in every period, the simulation
% range will be divided into 20 frames, each 20 periods long (i.e. some
%one period long going beyond the last simulation period specified by the user).
%
% * The simulation of the 1st frame will take initial conditions from the
% input database, `d2` or `d3`, and the shock in period t=1. All other
% shocks (t=2, t=3, etc.) will be disregarded. However, only the first
% simulated period, i.e. t=1, will be stored and included in the output
% database.
%
% * The simulation of the 2nd frame will take initial conditions from
% the the simulation of the first frame, and the shock in period t=2 from
% the input database. The 2nd frame will be simulated for
% another 20 periods, t=2 through t=21, but only the first simulated
% period, t=2, will be included in the output database.
%
% * The simulation of the third and all other frames will follow in the
% same way.
%
% * The output database will include period t=1 from the simulation of the
% 1st frame, period t=2 from the simulation of the 2nd frame, ...
% period t=20 from the simulation of the 20th frame.
%
% * Within each frame, the simulation takes several iterations. These
%

% Simulate random shocks with full credibility initially

solverOptions = { 
    'iris-newton', 'skipJacobUpdate', 2
};

d2 = d;
d2.c(0) = 1;
[s2, info2] = simulate( ...
    m, d2, 1:20 ...
    , 'prependInput', true ...
    , 'anticipate', false ...
    , 'method', 'stacked' ...
);

% Simulate random shocks wih low credibility initially.

d3 = d;
d3.c(0) = 0.1; % Low initial credibility
s3 = simulate( ...
    m, d3, 1:20 ...
    , 'PrependInput=', true ...
    , 'Anticipate=', false ...
    , 'Method=', 'stacked' ...
);


%% Plot Simulation Results
%
% Plot the simulated paths for all three simulations in one graph to
% compare the effect of nonlinearities:
%
% * The level of credibility does not move throughout the linear simulation
% (and even though it had moved it would have had no effect on the rest of
% the model anyway). This is very different in the other two simulations
% where credibility is affected by inflation outcomes.
%
% * Because of reductions in credibility in both of the nonlinear
% simulations, it costs more output to bring inflation back to the target.
% This is because the Phillips curve becomes more backward-looking with
% low levels of credibility
%
% * The other factor making inflation stabilisation costlier is the
% asymmetry of the Phillips curve in the output gap itself. Higher levels
% of inflation require a deeper slowdown in real economic activity (and the
% same positive shocks to the output gap will cause inflation to shoot up
% more).

listToPlot = [
    " 'Inflation' pi"
    " 'Credibility' c"
    " 'Output gap' y"
    " 'Policy rate' r"
];

dbplot( ...
    s1 & s2 & s3, 0:20, listToPlot ...
    , 'zeroLine', true ...
    , 'tight=', true ...
    , 'marker=', '.' ...
);

visual.hlegend( ...
    "bottom" ...
    , "Linearized Simulation" ...
    , "Nonlin Simulation with High Initial Credibility" ...
    , "Nonlin Simulation with Low Initial Credibility" ...
);


%% Inverted Simulation
%
% Taking the results of the nonlinear simulation with low credibility,
% fix (exogenize) the three macro variables, `y`, `pi` and `r`, to their
% simulated paths and reverse engineer (endogenized) the shocks needed to
% reproduce these paths. These shocks should, of course, be identical to
% those used in the original simulation.

p = Plan(m, 1:20, "anticipate", false);
p = exogenize(p, 1:20, ["y", "pi", "r"]); 
p = endogenize(p, 1:20, ["ey", "epi", "er"]); 

s4 = simulate( ...
    m, s3, 1:20, ...
    "prependInput", true, ...
    "ignoreShocks", true, ...
    "plan", p, ...
    "method", "stacked", ...
    "solver", solverOptions ...
);

[s3.ey, s4.ey]

max(abs(s3.ey - s4.ey))
max(abs(s3.epi - s4.epi))
max(abs(s3.er - s4.er))


%% Save Everything for Further Use
%
% Save the model object and the simulated databases to a mat (binary) file
% for further use in other files.
%

save mat/simulateStochastic.mat m s1 s2 s3

