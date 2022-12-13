
function p = getBaselineCalibration(p)

    if nargin==0
        p = struct();
    end

    % Std dev for kalman filtering

    p.std_shk_ri_us_tnd = 0.15;
    p.std_shk_l_poil_us_tnd = 0.15;
    p.std_shk_ri_tnd = 0.15;
    p.std_shk_dl_re_tw_tnd = 0.15;
    p.std_shk_dl_yn_tnd = 0.25;
    p.std_shk_l_yn_gap = 1;
    p.std_shk_dl_cpi_tar = 0.15;
    p.std_shk_dl_cpi_core = 5;



    % Steady state parameters

    p.ss_dl_yn = 4;
    p.ss_dl_cpi = 6;

    p.ss_ri = 0.75;
    p.ss_dl_re_tw = 3.5;

    p.ss_dl_cpi_us = 2;
    p.ss_dl_cpi_cross = 6;

    p.ss_dl_ne_cross = 5.5;
    p.ss_ri_us = 0;

    p.weight_core = 0.70;
    p.ss_auct = 1.6;

    % Aggregate demand (output gap)
    p.c1_l_yn_gap = 0.75;
    p.c2_l_yn_gap = 0.10;
    p.c3_l_yn_gap = 0.10;
    p.c4_l_yn_gap = 0.02;
    p.c5_l_yn_gap = 0.09;
    p.c6_l_yn_gap = 0.10;


    % Phillips curve (core CPI)
    p.c1_dl_cpi_core = 0.55; % t-1
    p.c2_dl_cpi_core = 0.10; % Output gap
    p.c3_dl_cpi_core = 0.06; % Real exchange rate gap

    % Noncore CPI
    p.c1_dl_cpi_nonc = 0;
    p.c2_dl_cpi_nonc = 1;


    % Monetary policy 
    p.c1_ni_tar = 0.75;

    p.c1_react = 4;
    p.c2_react = 0;

    p.c1_l_ne_us = 1;
    p.c1_ni = 0.2;

    p.c1_dl_cpi_tar = 0;


    % Exchange rate
    p.c1_prem_gap = 0.6;


    % Forex auctions
    p.c1_auct_gap = 0.15;


    % World and trend parameters
    p.c1_dl_yn_tnd = 0.85;
    p.c1_l_ne_us_market = 0.15;
    p.c1_ri_tnd = 0.95;
    p.c1_dl_re_tw_tnd = 0.90;

    p.c1_l_gex_gap = 0.5;
    p.c2_l_gex_gap = 1;

    p.c1_l_y_tw_gap = 0.8;
    p.c1_dl_cpi_tw = 0.8;
    p.c1_ni_us = 0.8;
    p.c1_ri_us_tnd = 0.95;

    p.c1_l_poil_us_gap = 0.7;

end%


