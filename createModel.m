%% Read and Solve the Nonlinear Credibility Model
%
% In this m-file script, we read the endogenous credibility model file,
% `endogenousCredibility.model`, assign its parameters, find the steady
% state of the model, calculate the first-order solution matrices, and save
% everything for future use. 

%% Clear Workspace

close all
clear
%#ok<*NOPTS>
 
%% Load and Calibrate Endogenous Credibility Model
%
% Call the Model object constructor `Model( )` to read the model file
% `endogenousCredibility.model` and create a model object. Calibrate the model
% parameters. Note that the parameter `del`, which determines the convexity
% of the Phillips curve, must be greater than zero.

m = Model("endogenousCredibility.model");

m.alp1 = 0.75;
m.alp2 = 0.1;
m.sgm = 0.1;
m.bet = 0.99;
m.gam = 0.05;
m.del = 0.4;
m.the = 0.80;
m.kap = 4;
m.phi = 0;
m.tau = 3;
m.rho = 2;
m.psi = 0.97;
m.omg = 1;

get(m, "Parameters")

%% Find Steady State
%
% In nonlinear models, the steady-state needs to be found (numerically)
% first, before we calculate the first-order solution matrices. By default,
% the function `steady( )` assumes that the model does not have nonzero
% growth rates in any of its variables -- the `endogenousCredibility.model`
% complies with this assumption. It is a good idea to always verify that
% the calculated steady-state holds (the function `checkSteady( )`
% would throw an error message with the list of inaccurate equations).

m = steady(m);
checkSteady(m); 

table(m, ["SteadyLevel", "SteadyChange", "Form", "Description"])

%% Calculate First-Order Solution Matrices
%
% The first-order solution matrices are not only used in
% linearized simulations, but they are used in nonlinear (stacked-time)
% simulation algorithms in several places.k

m = solve(m);

%% Save Everything for Further Use

save mat/createModel.mat m

