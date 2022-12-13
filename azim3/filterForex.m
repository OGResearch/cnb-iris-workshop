
close all
clear

startHist = qq(2003,1);
endHist = qq(2022,2);
startProj = endHist + 1;
endProj = endHist + 10*4;

%{
fred = databank.fromFred.data("CCUSMA02RUM618N->ne_ru_us");
fred.ne_ru_us = convert(fred.ne_ru_us, Frequency.QUARTERLY);
databank.toSheet(fred, "csv/fred.csv");
%}

fred = databank.fromSheet("csv/fred.csv");
fred.l_ne_ru_us = 100*log(fred.ne_ru_us);

fred.dl_ne_ru_us = diff(fred.l_ne_ru_us);
fred.pos_dl_ne_ru_us = max([fred.dl_ne_ru_us, 0], 2);

hist = databank.fromCSV("csv/hist-data.csv");
world = databank.fromSheet("csv/world-assumptions-filter.csv");

f = Model.fromFile("model-source/forex.model", defaultStd=1);
p = getBaselineCalibration();
f = assign(f, p);

f.c1_l_ne_us_market = 0.60;
f.c1_auct_gap = 0.15; 4;

f.std_shk_l_ne_us_market = 10;
f.std_shk_ni = 1;
f.std_shk_l_ne_us = 1; f.std_shk_ni_us = 1;
f.std_shk_E_l_ne_us = 1;
f.std_shk_l_poil_us_gap = 1;
f.std_shk_prem_tnd = 0.5;
f.std_shk_prem_gap = 0;
f.std_shk_int = 5;
f.std_shk_auct_tnd = 1;
f.std_shk_auct_gap = 10;




f = steady(f);
f = solve(f);

in = struct();

in.obs_ni = hist.ni;
in.obs_ni_us = hist.ni_us;
in.obs_l_ne_us = hist.l_ne_us;
in.obs_E_l_ne_us = hist.l_ne_us + 1.25*hist.dl_ne_us{+1}/4;
in.obs_E_l_ne_us(qq(2015,1)) = in.obs_E_l_ne_us(qq(2015,1)) - 0*25;
in.obs_E_l_ne_us(qq(2020,1)) = in.obs_E_l_ne_us(qq(2020,1)) - 7;
in.obs_l_poil_us_gap = world.l_poil_us_gap;

xxx = -diff(hist.ofr) + 1.6;
xxx(qq(2011,4)) = NaN;
xxx = fillMissing([xxx; hist.auct], Inf, "linear");

in.obs_auct = xxx;
in.obs_auct_tnd = Series(endHist, 1.6);

in.obs_zero = Series(startHist:endHist, 0);

out = kalmanFilter(f, in, startHist:endHist, meanOnly=true, relative=true);
out.ofr = hist.ofr;

return

%% Plot results

ch = Chartpack();
ch.Range = startHist:endHist;
ch.PlotSettings = {"marker", "s"};
ch.Highlight = qq(2017,1):qq(2022,2);

%ch + ["int", "auct_gap", "exp([auct, auct_tnd, auct_x]/100)"];
ch + ["int", "auct_gap", "[auct, auct_tnd, auct_x]"];
ch + ["[l_ne_us, E_l_ne_us{-1}, E_l_ne_us_x{-1}]"];
ch + ["prem_tnd"];
draw(ch, out);


% figure();
% plot([hist.dl_ne_us, 4*(out.E_l_ne_us{-1}-out.l_ne_us{-1}), -fred.pos_dl_ne_ru_us]);
% 
% 
% figure();
% plot(out.int);
% yyaxis right
% plot(hist.auct);
% 
% 
% 
