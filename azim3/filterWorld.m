
close all
clear

startHist = qq(2003,1);
endHist = qq(2022,2);
startProj = endHist + 1;
endProj = endHist + 10*4;

w = Model.fromFile( ...
    "model-source/azim-world.model" ... 
    , growth=true ...
    , defaultStd=1 ...
    , markdown=true ...
);

tuneNames = byAttributes(w, ":tunes");
w = assign(w, "std_"+tuneNames, 0);
access(w, "std-values")

p = getBaselineCalibration();
w = assign(w, p);

w.std_shk_l_poil_us_tnd = 0.5;
w = steady(w, blocks=false);
w = solve(w);


% Prepare historical observations
hist = databank.fromCSV("csv/hist-data.csv");
names = access(w, "measurement-variables");
inFilt = databank.forModel(w, []);
inFilt = databank.copy(hist, sourceNames=erase(names, "obs_"), targetNames=names, targetDb=inFilt, whenMissing="silent");
databank.list(inFilt)


% Prepare judgmental tunes
inFilt.obs_l_poil_us_tnd(endHist) = 100*log(60);


% Run kalman filter
outFilt = kalmanFilter(w, inFilt, startHist:endProj, meanOnly=true, relative=true);


% Simulate contributions of shocks to all world variables
c = simulate(w, outFilt, startHist:endProj, anticipate=false, contributions=true);
figure();
bar(c.dl_poil_us, 'stacked'); legend([access(w, "transition-shocks"), "Initials+Const", "Nonlin"], "interpreter", "none");




% Save results to CSV data file
databank.toSheet(outFilt, "csv/world-assumptions-filter.csv");


% Report the filter results
r = rephrase.Report("Rest of world assumptions filter");

h = rephrase.Highlight(startProj, endProj);
tuneSettings = {"mode", "markers", "markers", struct("symbol", "square", "color", [0,0,0])};

g = rephrase.Grid("", [], 3, "pass", {"dateFormat", "YYYY-Q", "highlight", h, "markers", false});

g + rephrase.Chart.fromSeries( ...
    {comment(outFilt.ni_us), startHist:endProj} ...
    , {"Data", outFilt.obs_ni_us} ...
    , {"Trend", outFilt.ni_us_tnd} ...
    , {"Tune", inFilt.obs_ri_us_tnd, tuneSettings{:}} ...
);

g + rephrase.Chart.fromSeries( ...
    {comment(outFilt.l_poil_us), startHist:endProj} ...
    , {"Data", outFilt.obs_l_poil_us} ...
    , {"Trend", outFilt.l_poil_us_tnd} ...
    , {"Tune", inFilt.obs_l_poil_us_tnd, tuneSettings{:}} ...
);

g + rephrase.Chart.fromSeries( ...
    {comment(outFilt.dl_cpi_tw), startHist:endProj} ...
    , {"Data", outFilt.dl_cpi_tw} ...
);

g + rephrase.Chart.fromSeries( ...
    {comment(outFilt.l_ne_cross), startHist:endProj} ...
    , {"Data", outFilt.l_ne_cross} ...
);

g + rephrase.Chart.fromSeries( ...
    {comment(outFilt.l_y_tw_gap), startHist:endProj} ...
    , {"Data", outFilt.l_y_tw_gap} ...
);

r + g;
build(r, "html/world-assumptions-filter");

