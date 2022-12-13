```iris

# AzIM - Core dynamics module

%{
          _              _____  ____    ____
         / \            |_   _||_   \  /   _|
        / _ \     ____    | |    |   \/   |
       / ___ \   [_   ]   | |    | |\  /| |
     _/ /   \ \_  .' /_  _| |_  _| |_\/_| |_
    |____| |____|[_____]|_____||_____||_____|

%}


    !variables

        "Nonoil output" l_yn
        "Nonoil output, Q/Q PA" dl_yn
        "Nonoil output, Y/Y" d4l_yn
        "Nonoil output gap" l_yn_gap

        "Headline CPI, Q/Q PA" dl_cpi
        "Headline CPI, Y/Y" d4l_cpi
        "Core CPI, Q/Q PA" dl_cpi_core
        "Core CPI, Y/Y PA" d4l_cpi_core
        "Noncore CPI, Q/Q PA" dl_cpi_nonc
        "Noncore CPI, Y/Y PA" d4l_cpi_nonc

        "Headline CPI expectations" E_dl_cpi
        "Core CPI expectations" E_dl_cpi_core

        "Headline CPI" l_cpi
        "Core CPI" l_cpi_core
        "Noncore CPI" l_cpi_nonc

        "Nominal policy rate target" ni_tar
        "Nominal policy rate" ni
        "Monetary policy reaction term" react
        "Forex intervention pressures, % PA" int

        "Market determined nominal exchange rate, USD" l_ne_us_market
        "Nominal exchange rate, AZN/USD" inv_ne_us
        "Nominal exchange rate, USD/AZN" ne_us
        "Nominal exchange rate, Log USD/AZN" l_ne_us
        "Nominal exchange rate, USD/AZN Q/Q PA" dl_ne_us
        "Nominal exchange rate expectations" E_l_ne_us
        "Nominal effective exchange rate, TW/AZN" ne_tw
        "Nominal effective exchange rate, TW/AZN" l_ne_tw
        "Nominal effective exchange rate, TW/AZN Q/Q PA" dl_ne_tw
        "UIP disparity" prem
        "UIP disparity gap" prem_gap
        l_ne_us_tar
        dl_ne_us_tar

        ri
        "Real policy rate gap" ri_gap

        l_re_tw
        "Real exchange rate gap, TW" l_re_tw_gap

        "Government expenditures gap" l_gex_gap

    !log-variables

        inv_ne_us, ne_us, ne_tw

    !parameters

        "CPI composition weight of core CPI" weight_core<0.7>

        "AR in nonoil output gap" c1_l_yn_gap<0.75>
        "FW in nonoil output gap" c2_l_yn_gap<0.1>
        "Real interest rate gap in aggregate demand" c3_l_yn_gap<0.1>
        "Real exchange rate gap in aggregate demand" c4_l_yn_gap<0.02>
        "Government expenditure in aggregate demand" c5_l_yn_gap<0.09>
        "World demand in aggregate demand" c6_l_yn_gap<0.1>

        "AR in core CPI inflation" c1_dl_cpi_core<0.55>
        "Nonoil output gap in Phillips curve" c2_dl_cpi_core<0.1>
        "Real exchange rate gap in Phillips curve" c3_dl_cpi_core<0.06>

        "AR in noncore CPI inflation" c1_dl_cpi_nonc<0>
        "Core CPI in noncore CPI equation" c2_dl_cpi_nonc<1>

        "AR in nominal policy rate" c1_ni_tar<0.75>
        "Inflation deviation from target in reaction function" c1_react<4>
        "Nonoil output gap in reaction function" c2_react<0>

        "Support to forex management through interest rate" c1_ni<0.2>

        "Oil transfers in UIP" c1_l_ne_us_market<0.15>

        "AR in UIP disparity gap" c1_prem_gap<0.6>
        "AR in government expenditures" c1_l_gex_gap<0.5>
        "Oil transfers in government expenditures" c2_l_gex_gap<1>

        "Intervention parameter" c1_l_ne_us<1>


    !shocks

        shk_dl_cpi_core
        shk_dl_cpi_nonc
        shk_l_neer
        shk_l_yn_gap
        shk_ni
        shk_ni_tar
        shk_react
        shk_l_ne_us_tar
        shk_prem_gap
        shk_l_gex_gap


    !shocks(:tunes)

        tune_dl_cpi_core
        tune_dl_cpi_nonc
        tune_l_neer
        tune_l_yn_gap
        tune_prem_gap
        tune_l_gex_gap


    !equations

    % __Real output__

        % Nonoil real output
        l_yn = l_yn_tnd + l_yn_gap;


## Aggregate demand (Output gap equation)

$$
\hat y_gap = c_1 \, \hat y_gap{-1} 
$$

        %============================================
        l_yn_gap = ...
            + c1_l_yn_gap<0.75> * l_yn_gap{-1} ...
            + c2_l_yn_gap<0.1> * l_yn_gap{+1} ...
            - c3_l_yn_gap<0.1> * ri_gap{-1} ...
            - c4_l_yn_gap<0.02> * l_re_tw_gap{-1} ...
            + c5_l_yn_gap<0.09> * l_gex_gap ...
            + c6_l_yn_gap<0.1> * l_y_tw_gap ...
            + tune_l_yn_gap ...
            + shk_l_yn_gap ...
        ;
        %============================================


    % __CPI inflation__

        % Headline CPI
        dl_cpi = ...
            + weight_core<0.7> * dl_cpi_core ...
            + (1-weight_core<0.7>) * dl_cpi_nonc ...
        ;


        % Phillips curve
        %============================================
        dl_cpi_core = ...
            + c1_dl_cpi_core<0.55> * dl_cpi_core{-1} ...
            + (1 - c1_dl_cpi_core<0.55>) * E_dl_cpi_core ...
            + c2_dl_cpi_core<0.1> * l_yn_gap ...
            - c3_dl_cpi_core<0.06> * l_re_tw_gap ...
            + tune_dl_cpi_core ...
            + shk_dl_cpi_core ...
        ;
        %============================================


        % Inflation expectations
        E_dl_cpi = dl_cpi{+1};
        E_dl_cpi_core = dl_cpi_core{+1};


        % Non-core inflation
        dl_cpi_nonc = ...
            + c1_dl_cpi_nonc<0> * dl_cpi_nonc{-1} ...
            + c2_dl_cpi_nonc<1> * dl_cpi_core ...
            + (1 - c1_dl_cpi_nonc<0> - c2_dl_cpi_nonc<1>) * ss_dl_cpi<6> ...
            + tune_dl_cpi_nonc ...
            + shk_dl_cpi_nonc ...
        ;


    % __Monetary policy and interest rates__


        % Monetary policy reaction function
        %============================================
        ni_tar = ...
            + c1_ni_tar<0.75> * ni{-1} ...
            + (1 - c1_ni_tar<0.75>) * [ ni_tnd + react ] ...
            + shk_ni_tar ...
        ;
        %============================================


        react = ...
            + c1_react<4> * (d4l_cpi{+3} - dl_cpi_tar) ...
            + c2_react<0> * l_yn_gap ...
            + shk_react ...
        ;


        % Actual policy rate: Support to forex management through interest rate
        % * c1_ni<0.2>=0 no support
        % * c1_ni<0.2>=1 unconditional support
        (1 - c1_ni<0.2>)*(ni - ni_tar) = c1_ni<0.2>*int;


        % Real interest rate definition
        ri = ni - E_dl_cpi_core;
        ri = ri_tnd + ri_gap;


        % Exchange rate target
        l_ne_us_tar = ...
            + l_ne_us_tar{-1} ...
            + $ss_dl_ne_us$/4 ...
            + shk_l_ne_us_tar ...
        ;


        % Actual exchange rate: Forex management through interventions
        % * c1_l_ne_us<1>=0 float
        % * c1_l_ne_us<1>=1 peg
        l_ne_us = ...
            + (1 - c1_l_ne_us<1>) * l_ne_us_market ...
            + c1_l_ne_us<1> * l_ne_us_tar ...
        !! l_ne_us = l_ne_us_tar;


        % (1 - c1_l_ne_us<1>) * int = c1_l_ne_us<1> * (l_ne_us - l_ne_us_tar);

        % Extent of forex interventions by the central bank
        % int>0 means CB selling forex
        % int<0 means CB buying forex
        int = l_ne_us - l_ne_us_market;


    % __Exchange rates__


        % Forex parity against USD
        %============================================
        ni - ni_us = ...
            - 4 * (E_l_ne_us - l_ne_us_market) ...
            + prem ...
            - c1_l_ne_us_market<0.15> * l_poil_us_gap ...
            + tune_l_neer ...
            + shk_l_neer ...
        ;
        %============================================

        % Nominal exchange rate expectations
        E_l_ne_us = l_ne_us{+1};


        % Nominal effective exchange rate
        l_ne_tw = l_ne_us + l_ne_cross;


        % Real exchange rate definition
        l_re_tw = l_ne_tw + l_cpi - l_cpi_tw;
        l_re_tw = l_re_tw_tnd + l_re_tw_gap;


        % Forex disparity
        prem = prem_tnd + prem_gap;
        prem_gap = ...
            + c1_prem_gap<0.6> * prem_gap{-1} ...
            + tune_prem_gap ...
            + shk_prem_gap ...
        ;


    % __Government and oil__

        l_gex_gap = ...
            + c1_l_gex_gap<0.5> * l_gex_gap{-1} ...
            + tune_l_gex_gap ...
            + shk_l_gex_gap ...
        ;


    % __Rates of change__

        % Quarter/quarter annualized
        !for
            yn
            cpi
            cpi_core
            cpi_nonc
            ne_us
            ne_us_tar
            ne_tw
        !do
            dl_? = 4*(l_? - l_?{-1});
        !end


        % Year/year
        !for
            cpi, yn, cpi_core, cpi_nonc
        !do
            d4l_? = l_? - l_?{-4};
        !end

        ne_us = exp(l_ne_us/100);
        inv_ne_us = exp(-l_ne_us/100);
        ne_tw = exp(l_ne_tw/100);


```