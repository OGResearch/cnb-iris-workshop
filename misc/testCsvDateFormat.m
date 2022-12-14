
d = databank.fromCSV( ...
    "csv/dateFormat.csv" ...
    , dateFormat="YYYY-FP" ...
);

d2 = databank.fromCSV( ...
    "csv/dateFormat2.csv" ...
    , dateFormat="YYYY-P" ...
    , enforceFrequency=Frequency.MONTHLY ...
);


d3 = databank.fromCSV( ...
    "csv/dateFormat3.csv" ...
    , dateFormat="YYYY-P" ...
    , enforceFrequency=Frequency.MONTHLY ...
    , delimiter=";" ...
);

d4 = databank.fromSheet("csv/decimalComma.xlsx");

