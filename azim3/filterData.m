
close all
clear 

hist = databank.fromCSV("csv/hist-data.csv");

startHist = qq(2003,1);
endHist = qq(2022,2);
endFilt = endHist + 19;

% Nonoil output

[hist.l_yn_tnd0, hist.l_yn_gap0] = hpf(hist.l_yn, startHist:endFilt);
[hist.l_yn_tnd1, hist.l_yn_gap1, cutoff1] = hpf(hist.l_yn, startHist:endFilt, change=Series(endFilt,4/4));
[hist.l_yn_tnd2, hist.l_yn_gap2, cutoff2] = hpf(hist.l_yn, startHist:endFilt, lambda=100, change=Series(endFilt,4/4));

%{
hist.l_yn_tnd = [hist.l_yn_tnd0, hist.l_yn_tnd1, hist.l_yn_tnd2];
hist.l_yn_gap = [hist.l_yn_gap0, hist.l_yn_gap1, hist.l_yn_gap2];

figure();
subplot(2,2,1);
plot(startHist:endFilt, [hist.l_yn, hist.l_yn_tnd]);
visual.highlight(startHist:endHist);

subplot(2,2,2);
plot(startHist:endFilt, 4*diff([hist.l_yn, hist.l_yn_tnd]));
visual.highlight(startHist:endHist);

subplot(2,2,3);
hold on;
plot(startHist:endFilt, [NaN,hist.l_yn_gap]);
plot(startHist:endFilt, Series(startHist:endFilt,0), "color", "black");
visual.highlight(startHist:endHist);
visual.hlegend("bottom", "Data", "Plain vanilla HP", "4% in the future", "lambda=100 & 4% in the future");

subplot(2,2,4);
hold on;
plot(startHist:endFilt, [hist.dl_cpi_core, hist.d4l_cpi_core]);
%}


hist.l_yn_tnd = hist.l_yn_tnd2;
hist.l_yn_gap = hist.l_yn_gap2;


% Real exchange rate


[hist.l_re_tw_tnd0, hist.l_re_tw_gap0] = hpf(hist.l_re_tw, startHist:endFilt);
[hist.l_re_tw_tnd1, hist.l_re_tw_gap1] = hpf(hist.l_re_tw, startHist:endFilt, change=Series(endFilt,3.5/4));
[hist.l_re_tw_tnd2, hist.l_re_tw_gap2] = hpf(hist.l_re_tw, startHist:endFilt, lambda=500, change=Series(endFilt,3.5/4));

%{
hist.l_re_tw_tnd = [hist.l_re_tw_tnd0, hist.l_re_tw_tnd1, hist.l_re_tw_tnd2];
hist.l_re_tw_gap = [hist.l_re_tw_gap0, hist.l_re_tw_gap1, hist.l_re_tw_gap2];

figure();
subplot(2,2,1);
plot(startHist:endFilt, [hist.l_re_tw, hist.l_re_tw_tnd]);
visual.highlight(startHist:endHist);
subplot(2,2,2);
plot(startHist:endFilt, 4*diff([hist.l_re_tw, hist.l_re_tw_tnd]));
visual.highlight(startHist:endHist);
subplot(2,2,3);
hold on;
plot(startHist:endFilt, [NaN,hist.l_re_tw_gap]);
plot(startHist:endFilt, Series(startHist:endFilt,0), "color", "black");
visual.highlight(startHist:endHist);
visual.hlegend("bottom", "Data", "Plain vanilla HP", "3.5% in the future", "lambda=500 & 3.5% in the future");
visual.heading("Real exchange rate, TWI");
%}


hist.l_re_tw_tnd = hist.l_re_tw_tnd1;
hist.l_re_tw_gap = hist.l_re_tw_gap1;


% Real interest rates

hist.ri = hist.ni - hist.d4l_cpi_core;

[hist.ri_tnd0, hist.ri_gap0] = hpf(hist.ri, startHist:endFilt, lambda=20000, level=Series(endFilt-1:endFilt,0.75));
hist.ri_tnd1 = Series(startHist:endFilt, 0.75);
hist.ri_gap1 = hist.ri - hist.ri_tnd1;

%{
hist.ri_tnd = [hist.ri_tnd0, hist.ri_tnd1];
hist.ri_gap = [hist.ri_gap0, hist.ri_gap1];

figure();
subplot(2,2,1);
plot(startHist:endFilt, [hist.ri, hist.ri_tnd]);
visual.highlight(startHist:endHist);

subplot(2,2,2);
hold on;
plot(startHist:endFilt, [NaN,hist.ri_gap]);
plot(startHist:endFilt, Series(startHist:endFilt,0), "color", "black");
visual.highlight(startHist:endHist);

subplot(2,2,3);
hold on;
plot(startHist:endFilt, [hist.ri, hist.ni, hist.d4l_cpi, hist.d4l_cpi_core]);
plot(startHist:endFilt, Series(startHist:endFilt,0), "color", "black");
legend("Real rate", "Nominal rate", "Headline", "Core");
visual.highlight(startHist:endHist);


visual.heading("Real interest rate");
%}


hist.ri_tnd = hist.ri_tnd1;
hist.ri_gap = hist.ri_gap1;


% US real interest rates

hist.ri_us = hist.ni_us - hist.d4l_cpi_us;

[hist.ri_us_tnd0, hist.ri_us_gap0] = hpf(hist.ri_us, startHist:endFilt, lambda=20000, level=Series(endFilt-1:endFilt,0));

%{
hist.ri_us_tnd = [hist.ri_us_tnd0];
hist.ri_us_gap = [hist.ri_us_gap0];

figure();
subplot(2,2,1);
plot(startHist:endFilt, [hist.ri_us, hist.ri_us_tnd]);
visual.highlight(startHist:endHist);

subplot(2,2,2);
hold on;
plot(startHist:endFilt, [NaN,hist.ri_us_gap]);
plot(startHist:endFilt, Series(startHist:endFilt,0), "color", "black");
visual.highlight(startHist:endHist);

subplot(2,2,3);
hold on;
plot(startHist:endFilt, [hist.ri_us, hist.ni_us, hist.d4l_cpi, hist.d4l_cpi_core]);
plot(startHist:endFilt, Series(startHist:endFilt,0), "color", "black");
legend("Real rate", "Nominal rate", "Headline", "Core");
visual.highlight(startHist:endHist);
%}


hist.ri_us_tnd = [hist.ri_us_tnd0];
hist.ri_us_gap = [hist.ri_us_gap0];


% Government expenditures


[hist.l_gex_tnd0, hist.l_gex_gap0] = hpf(hist.l_gex, startHist:endFilt, change=Series(endFilt, 4/4));
[hist.l_gex_tnd1, hist.l_gex_gap1] = hpf(hist.l_gex, startHist:endFilt, lambda=100, change=Series(endFilt, 4/4));

%{
hist.l_gex_tnd = [hist.l_gex_tnd0, NaN, hist.l_gex_tnd1];
hist.l_gex_gap = [hist.l_gex_gap0, NaN, hist.l_gex_gap1];

figure();
subplot(2,2,1);
plot(startHist:endFilt, [hist.l_gex, hist.l_gex_tnd]);
visual.highlight(startHist:endHist);

subplot(2,2,2);
plot(startHist:endFilt, 4*diff([hist.l_gex, hist.l_gex_tnd]));
visual.highlight(startHist:endHist);


subplot(2,2,3);
hold on;
plot(startHist:endFilt, [NaN, hist.l_gex_gap]);
plot(startHist:endFilt, Series(startHist:endFilt,0), "color", "black");
visual.highlight(startHist:endHist);
%}


hist.l_gex_tnd = hist.l_gex_tnd0;
hist.l_gex_gap = hist.l_gex_gap0;


% Oil prices

[hist.l_poil_us_tnd, hist.l_poil_us_gap] = ...
    hpf(hist.l_poil_us, startHist:endFilt, lambda=100000, change=Series(endHist, 0));

%{
figure();
subplot(2,2,1);
plot(startHist:endFilt, exp([hist.l_poil_us, hist.l_poil_us_tnd]/100));
visual.highlight(startHist:endHist);

subplot(2,2,2);
plot(startHist:endFilt, 4*diff([hist.l_poil_us, hist.l_poil_us_tnd]));
visual.highlight(startHist:endHist);


subplot(2,2,3);
hold on;
plot(startHist:endFilt, [NaN, hist.l_poil_us_gap]);
plot(startHist:endFilt, Series(startHist:endFilt,0), "color", "black");
visual.highlight(startHist:endHist);
%}


% Forex auctions and premium

[hist.auct_tnd, hist.auct_gap] = llf(hist.auct, startHist:endFilt, lambda=300, level=Series(endHist, 1.6));
hist.prem_gap = Series(startHist:endHist, 0);




list = databank.filterFields(hist, "name", @(n) startsWith(n, "l_"));
hist = databank.apply(hist, @(x) 4*diff(x), "sourceNames", list, "targetNames", "d"+list);
hist = databank.apply(hist, @(x) diff(x, -4), "sourceNames", list, "targetNames", "d4"+list);

databank.toCSV(hist, "csv/complete-hist.csv");

