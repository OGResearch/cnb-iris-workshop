```iris

# AzIM - Long-run sustainability trend module

%{
```
      _              _____  ____    ____
     / \            |_   _||_   \  /   _|
    / _ \     ____    | |    |   \/   |
   / ___ \   [_   ]   | |    | |\  /| |
 _/ /   \ \_  .' /_  _| |_  _| |_\/_| |_
|____| |____|[_____]|_____||_____||_____|

```
%}


    !variables

        "Output trend, Q/Q PA" dl_yn_tnd
        l_yn_tnd
        "Real exchange rate, TW Y/Y PA" dl_re_tw_tnd
        l_re_tw_tnd

        ni_tnd
        dl_cpi_tar
        "Real policy rate trend, % PA" ri_tnd
        prem_tnd


    !shocks

        shk_dl_yn_tnd
        shk_dl_cpi_tar


    !parameters

        ss_dl_cpi<6>
        ss_dl_yn<4>
        ss_ri<0.75>
        ss_dl_re_tw<3.5>

        c1_dl_yn_tnd<0.95>
        c1_dl_cpi_tar<1>


    !substitutions

        ss_dl_ne_us := (ss_dl_re_tw<3.5> - ss_dl_ne_cross<5.5> - (dl_cpi_tar - $ss_dl_cpi_tw$));


    !equations

        % Potential output
        dl_yn_tnd = ...
            c1_dl_yn_tnd<0.95> * dl_yn_tnd{-1} ...
            + (1 - c1_dl_yn_tnd<0.95>) * ss_dl_yn<4> ...
            + shk_dl_yn_tnd ...
        !! dl_yn_tnd = ss_dl_yn<4>;


        % Policy neutral nominal rate
        ni_tnd = ri_tnd + d4l_cpi{+3};


        % Inflation target
        dl_cpi_tar = ...
            + c1_dl_cpi_tar<1> * dl_cpi_tar{-1} ...
            + (1 - c1_dl_cpi_tar<1>) * ss_dl_cpi<6> ...
            + shk_dl_cpi_tar ...
        !! dl_cpi_tar = ss_dl_cpi<6>;

        % Real effective exchange rate
        dl_re_tw_tnd = ss_dl_re_tw<3.5>;

        % Trend in real interest rate
        ri_tnd = ss_ri<0.75>;

        % Real trend parity (=>prem_tnd)
        ri_tnd - ri_us_tnd = -(dl_re_tw_tnd - ss_dl_ne_cross<5.5> + ss_dl_cpi_cross<6>) + prem_tnd;


        % Rates of change
        !for
            yn_tnd
            re_tw_tnd
        !do
            dl_? = 4*(l_? - l_?{-1});
        !end


```