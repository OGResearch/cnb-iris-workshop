

load mat/createModel.mat m


d = databank.forModel(m, 1:40);

d.shk_y_gap(1:4) = 0.1;

s1 = simulate( ...
    m, d, 1:40 ...
    , prependInput=true ...
    , method="stacked" ...
);

p2 = Plan.forModel(m, 1:40);
p2 = swap(p2, 1:4, ["r", "shk_r"]);

s2 = simulate( ...
    m, d, 1:40 ...
    , prependInput=true ...
    , method="stacked" ...
    , plan=p2 ...
);

ch = Chartpack();
ch.Range = 0:40;
ch.Round = 8;
ch + access(m, "transition-variables");
draw(ch, databank.merge("horzcat", s1, s2));

