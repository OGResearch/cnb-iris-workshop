x = Series(mm(2022,1), [
101.6
101.1
101.1
101.0
100.7
99.9
100.5
100.9
103.1
101.6
101.5
101.9
101.0
101.0
101.2
100.9
100.0
99.9
100.5
100.7
101.1
100.7
100.5
101.2]);

x = x/100;
x = grow(x, "roc", x, mm(2022,2):mm(2023,12));
x = convert(x, Frequency.QUARTERLY);
q = 400*difflog(x);
y = 100*difflog(x, -4);
