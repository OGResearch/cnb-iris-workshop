
close all
clear

load mat/createModel.mat m

m.c1_dl_cpi_tar = 0;
m = solve(m);

d = databank.forModel(m, -10:40);

m1 = m;
m1.ss_dl_cpi = m1.ss_dl_cpi - 1;
m1 = steady(m1);
checkSteady(m1);
m1 = solve(m1);

d = databank.forModel(m, -10:40);
d1 = databank.forModel(m1, -10:40);

m1 = alter(m1, 2);
m1.c1_l_ne_us = [0, 1];
m1.c1_ni = [0, 0.5];
m1 = solve(m1);

s = simulate( ...
    m1, d, 1:40 ...
    , prependInput=true ...
);

%% Plot results

ch = Chartpack();
ch.Range = -7:40;
ch.Highlight = -7:0;
ch.Round = 8;
ch.FigureSettings = {"defaultAxesColorOrder", [0, 0.4470, 0.7410; 0.85, 0.325, 0.098; 0, 0, 0]};
ch.PlotSettings = { {"lineStyle"}, {"-"; "-"; ":"} };
ch + ["dl_cpi", "ni", "ni_tar", "l_ne_us", "dl_ne_us", "l_ne_us_tar", "l_ne_us-l_ne_us_tar", "l_yn_gap", "cumsum(l_yn_gap)/4"];
ch + ["ri_gap", "l_re_tw_gap", "l_ne_us_market", "int"];
draw(ch, databank.merge("horzcat", s, d1));

