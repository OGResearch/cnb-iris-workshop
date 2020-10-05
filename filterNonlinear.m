%% Kalman Filter with Nonlinear Prediction Step
%
% Run the Kalman filter with a nonlinear prediction step
% to filter the data simulated previously in `simulateStochastic`.
% With a linear prediction step, the credibility process doesn't respond to
% inflation performance and doesn't affect the rest of the economy. When
% the nonlinearity is preserved in the prediction step, the results get
% much more accurate.

%% Clear Workspace and Load Model Object

close all
clear
load mat/simulateStochastic.mat m s3


%% Kalman Filter with Nonlinear Prediction Step
%
% Use the database `s3` with measurement variables (output, inflation, 
% interest rates) simulated in `stochastic_simulations`. These will be the
% only input into the Kalman filter.
%
% Run the Kalman filter twice. In the first run, the Kalman filter uses
% the linearised model to produce one-step-ahead predictions in each of its steps.
% In the second run, the Kalman filter calls a simulation in an exact
% nonlinear mode to produce one-step-ahead predictions. Note that the
% exact nonlinear mode requires more periods to be simulated than are
% actually needed.
%
% Initialise the Kalman filter using the actual simulated data (#init).
% The initial condition is now being treated as a fixed, deterministic
% point.

g = struct( );
g.obs_y = s3.obs_y;
g.obs_pi = s3.obs_pi;
g.obs_r = s3.obs_r;

[~, f1] = filter( ...
    m, g, 4:20 ...
    , "initCond", s3 ... 
    , "meanOnly", true ...
    , "data", ["pred", "smooth"] ...
);

[~, f2] = filter( ...
    m, g, 4:20 ...
    , "initCond", s3 ... 
    , "meanOnly", true ...
    , "data", ["pred", "smooth"] ...
    , "simulate", {"method", "stacked"} ...
);


%% Plot Kalman Smoother
%
% Plot the smoother results from the Kalman filters with linearized versus
% nonlinear prediction step, and the true simulated data.

listToPlot = [ 
    " 'Inflation' pi"
    " 'Credibility' c"
    " 'Output gap' y"
    " 'Policy rate' r" 
];

sty = struct( );
sty.Line.LineStyle = {"-", "-", ":"};
sty.Line.Marker = {"none", "none", "*"};
sty.Line.LineWidth = {3, 3, 1.5};

dbplot(  ...
    f1.smooth & f2.smooth & s3, 1:20, listToPlot ...
    , "zeroLine", true ...
    , "tight", true ...
    , "visualStyle", sty ...
    , "highlight", 1:3 ...
);

visual.hlegend( ...
    "Bottom" ...
    , "Filter with Linearized Prediction Step" ...
    , "Filter with Nonlinear Prediction Step" ...
    , "True Simulated Values" ...
);

visual.heading("Kalman Smoother");


%% Plot Kalman Predictions
%
% Plot the prediction steps performed in the Kalman filters with linearized
% versus nonlinear prediction step, and the true simulated data.

dbplot( ...
    f1.pred & f2.pred & s3, 1:20, listToPlot ...
    , "zeroLine", true ...
    , "tight", true ...
    , "visualStyle", sty ...
    , "highlight", 1:3 ...
);

visual.hlegend( ...
    "Bottom" ...
    , "Filter with Linearized Prediction Step" ...
    , "Filter with Nonlinear Prediction Step" ...
    , "True Simulated Values" ...
);

visual.heading("Kalman Predictions");

