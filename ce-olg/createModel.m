
close all
clear

a1 = 15;
aa = 64;

m = Model.fromFile("ce-olg.model", context=struct("a1", a1, "aa", aa), saveAs="__preparsed.model");

return

beta = zeros(1, 100);
beta(A1:AA) = linspace(0.98, 0.95, A);

m = assign(m, "beta"+A1+",..,"+"beta"+AA, beta(A1:AA));
m = assign(m, "z"+A1+",..,"+"z"+AA, z(A1:AA));

m.ss_Q0 = 1/A;
m.ss_dQ0 = 1.01;

% m.chi = 0.3;
m.eta = 0.3;

% m.gamma_N = 0.60;
m.chi_H = 0.3;
m.psi = 0.005;
m.phi = 0.1;
m.mu_Y = 1;
m.delta_H = 0.20;
m.ss_P = 1;
m.ss_dZ = 1.02;
m.omega = 0.05;
m.kappa = m.omega;

%{
for i = A1 : AA
    m.(sprintf('C%g', i)) = 1;
    m.(sprintf('Lmb%g', i)) = 70;
end
%}

m.Z = 1;
m.Q0 = 1/A;

%m = alter(m, 4);
%m.omega = [0.3, 0.5, 0.7, 0.8];

m = alter(m, 2);
m.ss_dZ = [1.02, 1.01];

m = steady( ...
    m ...
    , "FixLevel=", ["Z", "Q0"] ...
    , 'Growth=', true ...
    , 'Solver=', {'IRIS-Qnsd', 'FunctionNorm=', 2.0} ...
);

checkSteady(m);
st = table( ...
    m, ["SteadyLevel", "SteadyChange", "Form"] ...
    , "WriteTable=", "steady-state.xlsx" ...
    , "SelectRows=", get(m, 'XNames') ...
);

m.("Chk" + A1)

d = get(m, 'SteadyLevel');
d = postprocess(m, d, 'SteadyLevel');

list = ["C", "N", "W", "Q", "H", "z", "D", "L", "Ho", "F", "prem", "Hx", "beta"];
c = struct( );
for name = list
    try
        c.(name) = databank.doubleDot(d, name+A1+",..,"+name+AA);
    end
end

