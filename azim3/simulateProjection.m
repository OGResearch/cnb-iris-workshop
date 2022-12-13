
close all
clear

load mat/createModel.mat m
hist = databank.fromCSV("csv/complete-hist.csv");

m.c1_l_ne_us_market = 0.15;
m.c1_ni = 0.5;
m.c1_dl_cpi_nonc = 0.5;
m.c2_dl_cpi_nonc = 0.5;
m = solve(m);

startHist = qq(2003,1);
endHist = qq(2022,2);
startProj = endHist + 1;
endProj = endHist + 10*4;
startReport = endHist - 3*4;


judg = databank.forModel(m, []);
pp = access(m, "postprocessor");
for n = collectLhsNames(pp)
    judg.(n) = Series.empty();
end

hist0 = hist;

s0 = simulate( ...
    m, hist0, startProj:endProj ...
    , prependInput=true ...
);

s0 = databank.merge("replace", hist0, s0);

s0.xxx = Series(startProj:endProj,0);
s0.xxx(startProj+(0:10)) = -100;
s0 = postprocess(m, s0, startProj:endProj, prependInput=true);

judg2 = judg;
judg2.dl_cpi([qq(2022,3),qq(2022,4)]) = [7.8; 8.6];

judg2.d4l_cpi_tw(qq(2022,4)) = 21.3;
judg2.d4l_cpi_tw(qq(2023,4)) = 11.2;
judg2.auct(startProj) = hist.auct(endHist);

hist2 = databank.merge("vertcat", hist, judg2);

p2 = Plan.forModel(m, startProj:endProj, method="condition");

p2 = exogenize(p2, startProj+(0:1), "dl_cpi");
p2 = endogenize(p2, startProj+(0:1), ["tune_dl_cpi_core", "tune_dl_cpi_nonc"]);
p2 = assignSigma(p2, startProj+(0:1), "tune_dl_cpi_core", 1);
p2 = assignSigma(p2, startProj+(0:1), "tune_dl_cpi_nonc", 2);

p2 = exogenize(p2, startProj, "auct");
p2 = endogenize(p2, startProj, "shk_prem_gap");

p2 = exogenize(p2, [qq(2022,4),qq(2023,4)], "d4l_cpi_tw");
p2 = endogenize(p2, startProj:qq(2023,4), "tune_dl_cpi_tw");
p2 = assignSigma(p2, startProj+(0:1), "tune_dl_cpi_tw", 1);


s2 = simulate( ...
    m, hist2, startProj:endProj ...
    , prependInput=true ...
    , plan=p2 ...
);

s2 = databank.merge("replace", hist2, s2);
%
% Adding residuals to a postprocessing equation
% res_lhs_name where lhs_name is the name of the variable on the LHS
%
% s2.res_dl_pyn = Series.empty();
% s2.res_dl_pyn(startProj+(0:3)) = 20;
%

s2 = postprocess(m, s2, startProj:endProj, prependInput=true);

in = s2;
in = rmfield(in, access(m, "measurement-variables"));
f2 = kalmanFilter(m, in, startProj:endProj, anticipate=true, initials={in, 0});


figure();
std_dl_cpi_core = f2.Std.dl_cpi_core;
std_dl_cpi_core(startProj-1) = 0;
plot(startProj-2*4:endProj, [s2.dl_cpi_core, s2.dl_cpi_core-std_dl_cpi_core, s2.dl_cpi_core+std_dl_cpi_core]);




hist3 = s2;
judg3 = judg;
judg3.ni(startProj+(0:3)) = 15;

p3 = Plan.forModel(m, startProj:endProj);
p3 = swap(p3, startProj+(0:3), ["ni", "shk_ni_tar"]);

hist3 = databank.merge("vertcat", hist3, judg3);

s3 = simulate( ...
    m, hist3, startProj:endProj ...
    , prependInput=true ...
    , plan=p3 ...
);

s3 = databank.merge("replace", hist3, s3);
s3 = postprocess(m, s3, startProj:endProj);

chartRange = startProj : startProj + 3*4 - 1;

x2 = [ ...
    s2.dl_cpi_core{-1}-6 ...
    s2.cont_dl_cpi_core__l_yn_gap ...
    s2.cont_dl_cpi_core__l_re_tw_gap ...
    s2.cont_dl_cpi_core__tune ...
    s2.cont_dl_cpi_core__shk ...
];
x3 = [ ...
    s3.dl_cpi_core{-1}-6 ...
    s3.cont_dl_cpi_core__l_yn_gap ...
    s3.cont_dl_cpi_core__l_re_tw_gap ...
    s3.cont_dl_cpi_core__tune ...
    s3.cont_dl_cpi_core__shk ...
];

figure();
hold on
bar(chartRange, x2, "stacked");
plot(chartRange, s2.dl_cpi_core-6, lineWidth=4, color="white");
plot(chartRange, s2.dl_cpi_core-6, color="black");
grid on;
legend("Persistence", "Domestic cost push factors", "Import cost push factors", "Tunes", "Shocks")

figure();
hold on
bar(chartRange, x3, "stacked");
plot(chartRange, s3.dl_cpi_core-6, lineWidth=4, color="white");
plot(chartRange, s3.dl_cpi_core-6, color="black");
grid on;
legend("Persistence", "Domestic cost push factors", "Import cost push factors", "Tunes", "Shocks")

s2.Label__ = "Baseline";
s3.Label__ = "Policy rate hike";

reportProjections( ...
    "html/baseline" ...
    , s2, s3 ...
    , judg2, judg3 ...
    , startProj, endProj ...
);

