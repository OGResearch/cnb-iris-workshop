
function reportProjections(fileName, base, alt, jbase, jalt, startProj, endProj);

    chartRange = startProj-4*4 : startProj+4*4;

    baseLabel = base.Label__;
    altLabel = alt.Label__;

    startProjYear = convert(startProj, Frequency.YEARLY);
    endProjYear = convert(endProj, Frequency.YEARLY);
    tableRange = startProjYear-3 : startProjYear+4;

    tuneMarkers = struct("color", "#666666", "symbol", "square", "size", 10);
    tuneSettings = {"mode", "markers", "markers", tuneMarkers};

    h = rephrase.Highlight(chartRange(1), startProj-1);

    r = rephrase.Report("AzIM Projection Report");

    p = rephrase.Pager(" ", pass={"dateFormat", "YYYY-Q", "highlight", h, "round", 4, "YZeroLine", true});

    g = rephrase.Grid("World assumptions", [], 3);
    for n = ["ni_us", "dl_cpi_tw", "l_y_tw_gap", "inv_ne_cross", "poil_us", "d4l_cpi_tw"]
        x = [alt.(n), base.(n)];
        j = [jbase.(n), jalt.(n)];
        title = comment(x);
        title = title(1);
        ch = rephrase.Chart.fromSeries( ...
            {title, chartRange} ...
            , {[altLabel, baseLabel], x} ...
            , {["Tune", "Tune"], j, tuneSettings{:}} ...
        );
        g + ch;
    end
    p + g;

    g = rephrase.Grid("Trend assumptions", [], 3);
    for n = ["dl_yn_tnd", "ri_tnd", "dl_re_tw_tnd"]
        x = [alt.(n), base.(n)];
        j = [jbase.(n), jalt.(n)];
        title = comment(x);
        title = title(1);
        ch = rephrase.Chart.fromSeries( ...
            {title, chartRange} ...
            , {[altLabel, baseLabel], x} ...
            , {["Tune", "Tune"], j, tuneSettings{:}} ...
        );
        g + ch;
    end
    p + g;

    g = rephrase.Grid("Monetary policy variables", [], 3);
    for n = ["ni", "inv_ne_us", "ne_tw", "auct"]
        x = [alt.(n), base.(n)];
        j = [jbase.(n), jalt.(n)];
        title = comment(x);
        title = title(1);
        ch = rephrase.Chart.fromSeries( ...
            {title, chartRange} ...
            , {[altLabel, baseLabel], x} ...
            , {["Tune", "Tune"], j, tuneSettings{:}} ...
        );
        g + ch;
    end
    p + g;

    g = rephrase.Grid("Macro variables - analytical", [], 3);
    for n = ["l_yn_gap", "dl_cpi", "dl_cpi_core", "dl_cpi_nonc", "ri_gap", "l_re_tw_gap"]
        x = [alt.(n), base.(n)];
        j = [jbase.(n), jalt.(n)];
        title = comment(x);
        title = title(1);
        ch = rephrase.Chart.fromSeries( ...
            {title, chartRange} ...
            , {[altLabel, baseLabel], x} ...
            , {["Tune", "Tune"], j, tuneSettings{:}} ...
        );
        g + ch;
    end
    p + g;

    g = rephrase.Grid("Macro variables - reporting", [], 3);
    for n = ["dl_yn", "d4l_yn", "d4l_cpi", "d4l_cpi_core", "d4l_cpi_nonc", "d4l_pyn", "d4l_nyn"]
        x = [alt.(n), base.(n)];
        j = [jbase.(n), jalt.(n)];
        title = comment(x);
        title = title(1);
        ch = rephrase.Chart.fromSeries( ...
            {title, chartRange} ...
            , {[altLabel, baseLabel], x} ...
            , {["Tune", "Tune"], j, tuneSettings{:}} ...
        );
        g + ch;
    end
    p + g;

    r + p;

    r + rephrase.Section("Tabular annex");

    columnClass = repmat("", 1, numel(tableRange));
    columnClass(tableRange<startProjYear) = "history-dates";
    columnClass(tableRange==startProjYear) = "ntf-dates";
    columnClass(tableRange>startProjYear) = "projection-dates";

    t = rephrase.Table("Executive summary", tableRange, "dateFormat", "YYYY", "pass", {"columnClass", columnClass});

    cond = struct();

    ys = @(x) convert(x, Frequency.YEARLY, method="sum");
    ya = @(x) convert(x, Frequency.YEARLY, method="mean");
    pya = @(x) pct(ya(x));
    pye = @(x) pct(convert(x, Frequency.YEARLY, method="last"));

    t + rephrase.DiffSeries("Nonoil GDP", pya(base.yn), pya(alt.yn), "units", "% Y/Y (avg)");
    t + rephrase.DiffSeries("Headline CPI", pye(base.cpi), pye(alt.cpi), "units", "% Y/Y (end)");
    t + rephrase.DiffSeries("Core CPI", pye(base.cpi_core), pye(alt.cpi_core), "units", "% Y/Y (end)");
    t + rephrase.DiffSeries("Noncore CPI", pye(base.cpi_nonc), pye(alt.cpi_nonc), "units", "% Y/Y (end)");
    t + rephrase.DiffSeries("CBAR policy rate", ya(base.ni), ya(alt.ni), "units", "% PA");
    t + rephrase.DiffSeries("Nominal exchange rate AZN/USD", ya(base.inv_ne_us), ya(alt.inv_ne_us), "units", "AZN/USD");
    t + rephrase.DiffSeries("Nominal effective exchange rate TWI/AZN", 100*ya(base.ne_tw), 100*ya(alt.ne_tw), "units", "Index");
    t + rephrase.DiffSeries("Forex auctions", ys(base.auct), ys(alt.auct), "units", "AZN Bil");

    t + rephrase.DiffSeries("Nonoil GDP gap", 100*(ya(base.yn)/ya(base.yn_tnd)-1), 100*(ya(alt.yn)/ya(alt.yn_tnd)-1), "units", "%");

    r + t;


    r + rephrase.Section("Behavioral contributions");

    contRange = startProj : startProj+3*4;

    barSettings = {"type", "bar"};

    ch = rephrase.Chart.fromSeries( ...
        {"Core CPI, % Q/Q PA", contRange, "dateFormat", "YYYY-Q", "barMode", "relative"} ...
        , {"Persistence", base.dl_cpi_core{-1}-base.ss_dl_cpi, barSettings{:} } ...
        , {"Domestic cost", base.cont_dl_cpi_core__l_yn_gap, barSettings{:} } ...
        , {"Import cost", base.cont_dl_cpi_core__l_re_tw_gap, barSettings{:} } ...
        , {"Tunes", base.cont_dl_cpi_core__tune, barSettings{:} } ...
        , {"Shocks", base.cont_dl_cpi_core__shk, barSettings{:} } ...
        , {"Projection", base.dl_cpi_core-base.ss_dl_cpi, "color", "#ffffff", "lineWidth", 6, "showLegend", false } ...
        , {"Projection", base.dl_cpi_core-base.ss_dl_cpi, "color", "#000000", "lineWidth", 3 } ...
    );

    r + ch;

    contRange = startProj : startProj+3*4;

    barSettings = {"type", "bar"};

    ch = rephrase.Chart.fromSeries( ...
        {"Core CPI, % Q/Q PA", contRange, "dateFormat", "YYYY-Q", "barMode", "relative"} ...
        , {"Persistence", alt.dl_cpi_core{-1}-alt.ss_dl_cpi, barSettings{:} } ...
        , {"Domestic cost", alt.cont_dl_cpi_core__l_yn_gap, barSettings{:} } ...
        , {"Import cost", alt.cont_dl_cpi_core__l_re_tw_gap, barSettings{:} } ...
        , {"Tunes", alt.cont_dl_cpi_core__tune, barSettings{:} } ...
        , {"Shocks", alt.cont_dl_cpi_core__shk, barSettings{:} } ...
        , {"Projection", alt.dl_cpi_core-alt.ss_dl_cpi, "color", "#ffffff", "lineWidth", 6, "showLegend", false } ...
        , {"Projection", alt.dl_cpi_core-alt.ss_dl_cpi, "color", "#000000", "lineWidth", 3 } ...
    );

    r + rephrase.Section(" ");
    r + ch;

    build(r, fileName, "userStyle", "html/extra.css");

end%

