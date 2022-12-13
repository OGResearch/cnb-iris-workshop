
close all
clear

rawSA = databank.fromCSV("../macro-data/cQuarterly_sa.csv");
rawSU = databank.fromCSV("../macro-data/cQuarterly_su.csv");


startHist = qq(2003,1);
endHist = qq(2022,2);

hist = struct();

hist.yn = rawSA.rgdp_noil_sa;
hist.l_yn = 100*log(hist.yn);

hist.pyn = rawSA.gdp_noil_def_sa;
hist.l_pyn = 100*log(hist.pyn);

hist.nyn = hist.pyn * hist.yn;
hist.l_nyn = 100*log(hist.nyn);

hist.l_cpi = 100*log(rawSA.cpi_sa);
hist.l_cpi_u = 100*log(rawSU.cpi_su);
hist.l_cpi_tw = 100*log(rawSA.tp_cpi_sa);
hist.l_cpi_us = 100*log(rawSA.cpi_us_sa);

hist.auct = 3*rawSA.usd_demand_sa / 1000;
hist.l_auct = 100*log(hist.auct);

hist.ofr = rawSA.foreign_reserves / 1000;
hist.l_ofr = 100*log(hist.ofr);

hist.ni = rawSU.az_ir_su;
hist.ni_us = rawSU.fed_ir_su;
hist.inv_ne_us = rawSU.fx_rate_su;
hist.ne_us = 1/rawSU.fx_rate_su;
hist.ne_tw = (rawSU.neer_su/100);
hist.inv_ne_tw = 1/(rawSU.neer_su/100);
hist.l_ne_us = -100*log(rawSU.fx_rate_su);
hist.l_ne_tw = 100*log(hist.ne_tw);
hist.l_y_tw_gap = rawSA.foreignoutput_gap;

hist.poil_us = rawSU.oil_price_su;
hist.l_poil_us = 100*log(rawSU.oil_price_su);

hist.l_ne_cross = hist.l_ne_tw - hist.l_ne_us;
hist.ne_cross = hist.ne_tw / hist.ne_us;
hist.inv_ne_cross = 1/hist.ne_cross;
hist.l_ne_us_tar = hist.l_ne_us;
hist.dl_cpi_tar = Series(startHist:endHist, 6);


hist.l_oil = 100*log(rawSA.oil_prod_sa * rawSU.oil_price_su * rawSU.fx_rate_su / rawSA.cpi_sa);

hist.l_gex = 100*log(rawSA.gov_sa / rawSA.cpi_sa);
% hist.l_gex = 100*log(rawSA.gov_sa / rawSA.core_sa);

hist.l_cpi_core = 100*log(rawSA.core_sa);
hist.l_cpi_core_u = 100*log(rawSU.core_su);

hist.l_re_tw = hist.l_ne_tw + hist.l_cpi - hist.l_cpi_tw;
%hist.l_re_tw = hist.l_ne_tw + hist.l_cpi_core - hist.l_cpi_tw;

list = databank.filterFields(hist, "name", @(n) startsWith(n, "l_"));
hist = databank.apply(hist, @(x) 4*diff(x), "sourceNames", list, "targetNames", "d"+list);
hist = databank.apply(hist, @(x) diff(x, -4), "sourceNames", list, "targetNames", "d4"+list);

weight_core = 0.70;

hist.dl_cpi_nonc = (hist.dl_cpi - weight_core*hist.dl_cpi_core) / (1 - weight_core);
hist.dl_cpi_nonc_u = (hist.dl_cpi_u - weight_core*hist.dl_cpi_core_u) / (1 - weight_core);
hist.l_cpi_nonc = cumsum(hist.dl_cpi_nonc/4);

databank.toCSV(hist, "csv/hist-data.csv");


