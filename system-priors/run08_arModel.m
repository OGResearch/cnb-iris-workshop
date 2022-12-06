
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

save mat/arModel.mat m


