
clear
close all

load mat/createModel.mat m

checkSteady(m); 
m = solve(m); 

T = 40;
N = 5;
d = sstatedb(m, 1:T);
d.shk_y_gap(1:N) = -1.2;

anticipate = true;

p = Plan.forModel(m, 1:T, "anticipate", anticipate);
p = swap(p, 1:5, ["y_gap", "shk_y_gap"]);

s0 = simulate(m, d, 1:T, "prependInput", true);


s1 = simulate( ...
    m, d, 1:T ...
    , "prependInput", true ...
    , "method", "stacked" ...
    , "anticipate", anticipate ...
);


ch = databank.Chartpack();
ch.Range = 0:T;
ch.Round = 8;
ch.CaptionFromComment = true;

ch < ["y_gap", "pie", "pie4", "r", "rr", "c", "s"];

draw(ch, databank.merge("horzcat", s0, s1));

