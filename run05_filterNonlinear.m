%% Kalman Filter with Nonlinear Prediction Step
%
% Run the Kalman filter with a nonlinear prediction step
% to filter the data simulated previously in `simulateStochastic`.
% With a linear prediction step, the credibility process doesn't respond to
% inflation performance and doesn't affect the rest of the economy. When
% the nonlinearity is preserved in the prediction step, the results get
% much more accurate.

%% Clear Workspace and Load Model Object
% 
% close all
% clear
% load mat/createModel.mat c m
% load mat/simulateStochastic.mat m s3 d3


%% Kalman Filter with Nonlinear Prediction Step
%
% Use the database `s3` with measurement variables (output, inflation, 
% interest rates) simulated in `stochastic_simulations`. These will be the
% only input into the Kalman filter.
%
% Run the Kalman filter twice. In the first run, the Kalman filter uses
% the linearised model to produce one-step-ahead predictions in each of its steps.
% In the second run, the Kalman filter calls a nonlinear (stacked-time) simulation
% to make the prediction step. By default, the prediction step is
% simulated for 1 period only; here, to capture nonlinearities in
% expectations as well, we run the simulation for the prediction step for 5
% periods; this is set by `window=5`.
%
% Initialize the Kalman filter using the actual simulated data using
% `initCond=s3`.  The initial condition is now being treated as a fixed,
% deterministic point.
%

g = struct( );
g.obs_y = s3.obs_y;
g.obs_pi = s3.obs_pi;
g.obs_r = s3.obs_r;

f1 = kalmanFilter( ...
    m, g, 1:20 ...
    , "initCond", s3 ...
    , "meanOnly", true ...
    , "outputData", ["pred", "smooth"] ...
);

f2 = kalmanFilter( ...
    m, g, 1:20 ...
    , "initCond", s3 ...
    , "meanOnly", true ...
    , "outputData", ["pred", "smooth"] ...
    , "simulate", {"method", "stacked", "window", 5} ...
);


%% Plot Kalman Smoother
%
% Plot the smoother results from the Kalman filters with linearized versus
% nonlinear prediction step, and the true simulated data.


ch = databank.Chartpack();
ch.Range = 1:20;
ch.Round = 8;

ch < access(m, "measurement-variables");
ch < "//";
ch < access(m, "transition-variables");

draw(ch, databank.merge("horzcat", f1.Smooth, f2.Smooth));

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
    f1.pred & f2.pred & s3, 0:20, listToPlot ...
    , "zeroLine", true ...
    , "tight", true ...
    , "visualStyle", sty ...
    , "highlight", 0 ...
);

visual.hlegend( ...
    "Bottom" ...
    , "Filter with Linearized Prediction Step" ...
    , "Filter with Nonlinear Prediction Step" ...
    , "True Simulated Values" ...
);

visual.heading("Kalman Predictions");

