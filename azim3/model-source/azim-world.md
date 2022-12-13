```iris

# AzIM - Rest of world assumptions module

%{
      _              _____  ____    ____
     / \            |_   _||_   \  /   _|
    / _ \     ____    | |    |   \/   |
   / ___ \   [_   ]   | |    | |\  /| |
 _/ /   \ \_  .' /_  _| |_  _| |_\/_| |_
|____| |____|[_____]|_____||_____||_____|

%}


    !variables

        "Foreign CPI, TW" l_cpi_tw
        "Foreign CPI, TW, Q/Q PA" dl_cpi_tw
        "Foreign CPI, TW, Y/Y" d4l_cpi_tw
        "Foreign output gap, TW" l_y_tw_gap

        "Foreign interest rate, US, % PA" ni_us
        "Foreign interest rate trend, US, % PA" ni_us_tnd
        "Foreign real interest rate trend, US, % PA" ri_us_tnd

        "Nominal cross rate, Log TW/USD, Q/Q PA" dl_ne_cross
        "Nominal cross rate, Log TW/USD" l_ne_cross

        "Oil prices, USD Log" l_poil_us
        "Oil prices trend, USD Log" l_poil_us_tnd
        "Oil prices gap, USD Log" l_poil_us_gap


    !shocks

        shk_l_y_tw_gap
        shk_dl_cpi_tw
        shk_ni_us
        shk_ri_us_tnd
        shk_l_poil_us_tnd
        shk_l_poil_us_gap
        shk_dl_ne_cross


    !shocks(:tunes)

        tune_l_y_tw_gap
        tune_dl_cpi_tw
        tune_ni_us
        tune_ri_us_tnd
        tune_l_poil_us_tnd
        tune_l_poil_us_gap
        tune_dl_ne_cross


    !parameters

        ss_dl_cpi_cross<6>
        ss_dl_cpi_us<2>
        ss_dl_ne_cross<5.5>
        ss_ri_us<0>

        c1_l_y_tw_gap<0.8>
        c1_dl_cpi_tw<0.8>
        c1_ni_us<0.8>
        c1_ri_us_tnd
        c1_l_poil_us_gap<0.7>


    !substitutions

        ss_dl_cpi_tw := (ss_dl_cpi_us<2> + ss_dl_cpi_cross<6>);


    !equations

        l_y_tw_gap = ...
            + c1_l_y_tw_gap<0.8> * l_y_tw_gap{-1} ...
            + tune_l_y_tw_gap ...
            + shk_l_y_tw_gap ...
        ;


        dl_cpi_tw = ...
            + c1_dl_cpi_tw<0.8> * dl_cpi_tw{-1} ...
            + (1 - c1_dl_cpi_tw<0.8>) * $ss_dl_cpi_tw$ ...
            + tune_dl_cpi_tw ...
            + shk_dl_cpi_tw ...
        ;


        ni_us = ...
            + c1_ni_us<0.8> * ni_us{-1} ...
            + (1-c1_ni_us<0.8>) * ni_us_tnd  ...
            + tune_ni_us  ...
            + shk_ni_us ...
        ;


        ni_us_tnd = ri_us_tnd + ss_dl_cpi_us<2>;


        ri_us_tnd = ...
            + c1_ri_us_tnd * ri_us_tnd{-1} ...
            + (1 - c1_ri_us_tnd) * ss_ri_us<0> ...
            + tune_ri_us_tnd ...
            + shk_ri_us_tnd ...
        !! ri_us_tnd = ss_ri_us<0>;


        dl_ne_cross = ...
            + ss_dl_ne_cross<5.5> ...
            + tune_dl_ne_cross ...
            + shk_dl_ne_cross ...
        !! dl_ne_cross = ss_dl_ne_cross<5.5>;


        l_poil_us = l_poil_us_tnd + l_poil_us_gap;


        l_poil_us_tnd = ...
            l_poil_us_tnd{-1} ...
            + tune_l_poil_us_tnd ...
            + shk_l_poil_us_tnd;


        l_poil_us_gap = ...
            + c1_l_poil_us_gap<0.7> * l_poil_us_gap{-1} ...
            + tune_l_poil_us_gap ...
            + shk_l_poil_us_gap ...
        !! l_poil_us_gap = 0;


        !for
            cpi_tw
            ne_cross
        !do
            dl_? = 4*(l_? - l_?{-1});
        !end


        !for
            cpi_tw
        !do
            d4l_? = l_? - l_?{-4};
        !end


    !postprocessor

        ne_cross = exp(l_ne_cross/100);
        inv_ne_cross = exp(-l_ne_cross/100);
        poil_us = exp(l_poil_us/100);


    !measurement-variables

        obs_ni_us
        obs_ri_us_tnd
        obs_l_ne_cross
        obs_l_poil_us
        obs_l_poil_us_tnd
        obs_l_cpi_tw
        obs_l_y_tw_gap


    !measurement-equations

        obs_ni_us = ni_us;
        obs_ri_us_tnd = ri_us_tnd;
        obs_l_ne_cross = l_ne_cross;
        obs_l_poil_us = l_poil_us;
        obs_l_poil_us_tnd = l_poil_us_tnd;
        obs_l_cpi_tw = l_cpi_tw;
        obs_l_y_tw_gap = l_y_tw_gap;

```