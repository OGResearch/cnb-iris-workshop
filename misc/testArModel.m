
close all
clear

m = Model.fromFile("model-source/ar.model", savePreparsedAs="model-source/ar.preparsed.model");

access(m, "transition-variables")
access(m, "transition-equations")
access(m, "parameters")

access(m, "preprocessor")
access(m, "postprocessor")

m.ss_dl_cpi = 2;
m.rho_dl_cpi = 0.85;

m.ss_dl_gdp = 2;
m.rho_dl_gdp = 0.85;

m = steady(m);
m = solve(m);

d = databank.forModel(m, 1:40);
p = Plan.forModel(m, 1:40, "anticipate", false);
p = exogenize(p, 1:4, "dl_cpi");
p = endogenize(p, 1:4, "shk_dl_gdp");
d.dl_cpi(1:4) = -10;
s = simulate(m, d, 1:40, plan=p);

save mat/arModel.mat m


