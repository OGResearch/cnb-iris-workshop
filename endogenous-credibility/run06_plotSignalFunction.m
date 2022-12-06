
close all
clear

targ = 5;
pie4 = 0 : 0.1 : 10;

f = @(pie4, targ, omega, k) exp(-(omega*(pie4 - targ)).^k);


figure();
hold on;
plot(pie4, f(pie4, targ, 1, 2));
plot(pie4, f(pie4, targ, 1, 4));
plot(pie4, f(pie4, targ, 1/2, 4));
h = xline(targ, "label", "Inflation target", "labelVerticalAlignment", "middle");

legend("omega=1, k=2", "omega=1, k=4", "omega=1/2, k=4");
title("Credibility signal function for different parameters");

xlabel("Actual inflation");
ylabel("Signal between 0 and 1");

print -dpng docs/credibility-signal

