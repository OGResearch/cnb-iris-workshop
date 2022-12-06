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

m.slope_r = 0;
m = solve(m);

m = rescaleStd(m, 0);

m.std_shk_r = 0.2;
m.std_shk_y_tnd = 0.02;
m.std_shk_y_gap = 0.4;
m.std_shk_pie = 0.4;
m.std_shk_targ = 0;


%% Create Steady-State Database with Random Shocks
%
% Call the function `sstatedb` to create a database with each model being
% variable assigned its steady-state value. The range on which these time
% series are created on a range -2:20, and not just 1:T as the second
% input argument says. This is because `sstatedb` automatically looks up
% the maximum lag in the model and adjusts the range accordingly to include
% all necessary initial conditions so that a simulation can start at time
% t=1.
%
% With the option `shockFunc=@randn`, the model shocks are randomly drawn
% on the range 1:T from a normal distribution with mean zero and std
% deviations given by the model object.

T = 10; 100;
N = 1;
display = "final";

rng(0);
d = steadydb(m, 1:T, "shockFunc", @randn, "numColumns", N);


%% First-order simulation
%
% First, simulate the random shocks using first-order approximate solution
% (linearized model). The shocks are simulated as unanticipated. Note that
% credibility plays no role in this simulation, because the level of
% credibility has no first-order effects in the model equations.

d1 = d;
[s1, info1] = simulate( ...
    m, d, 1:T ...
    , "prependInput", true ...
    , "anticipate", false ...
);


%% Nonlinear simulations
%
% Next, simulate the random shocks using a nonlinear simulation method: a
% so-called stacked-time algorithm. Because the shocks are unanticipated,
% the whole simulation range, 1:T, must be segmented into so-called
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


d2 = d;
d2.c(-2:0) = 1;
[s2, info2] = simulate( ...
    m, d2, 1:T ...
    , 'prependInput', true ...
    , 'anticipate', false ...
    , 'method', 'stacked' ...
    , 'solver', {'quickNewton', 'display', display} ...
);


% Simulate random shocks wih low credibility initially.

d3 = d;
d3.c(-2:0) = 0.1; % Low initial credibility
s3 = simulate( ...
    m, d3, 1:T ...
    , 'prependInput', true ...
    , 'anticipate', false ...
    , 'method', 'stacked' ...
    , 'solver', {'quickNewton', 'display', display} ...
);


%% Plot simulation results
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

ch = databank.Chartpack();
ch.Range = 0 : T;
ch < access(m, "transition-variables");

c = 1;
chartDb = databank.merge("horzcat", databank.retrieveColumns(s1, c), databank.retrieveColumns(s2, c), databank.retrieveColumns(s3, c)); 
draw(ch, chartDb);

visual.hlegend( ...
    "bottom" ...
    , "First-order simulation" ...
    , "Nonlin simulation with high initial credibility" ...
    , "Nonlin simulation with low initial credibility" ...
);


%% Inverted simulation
%
% Taking the results of the nonlinear simulation with low credibility,
% fix (exogenize) the three macro variables, `y`, `pi` and `r`, to their
% simulated paths and reverse engineer (endogenized) the shocks needed to
% reproduce these paths. These shocks should, of course, be identical to
% those used in the original simulation.

p = Plan.forModel(m, 1:T, "anticipate", false);
p = exogenize(p, 1:T, ["y_gap", "y_tnd", "pie", "r"]); 
p = endogenize(p, 1:T, ["shk_y_gap", "shk_y_tnd", "shk_pie", "shk_r"]); 

s4 = simulate( ...
    m, s3, 1:T, ...
    "prependInput", true, ...
    "ignoreShocks", true, ...
    "plan", p, ...
    "method", "stacked", ...
    'solver', {'quickNewton', 'display', display} ...
);

[s3.shk_y_gap, s4.shk_y_gap]

max(abs(s3.shk_y_gap - s4.shk_y_gap))
max(abs(s3.shk_pie - s4.shk_pie))
max(abs(s3.shk_r - s4.shk_r))


%% Save everything for further use
%
% Save the model object and the simulated databases to a mat (binary) file
% for further use in other files.
%

save mat/simulateStochastic.mat m s1 s2 s3 d1 d2 d3

