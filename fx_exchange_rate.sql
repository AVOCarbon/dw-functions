-- rate type go as follow

-- rateType
-- ‘E’ = End of month = closing rate -- must be inserted every month
-- ‘B’ = Budget -- must be inserted once a year
-- ‘A’ = Average of the month

-- end of year rate

INSERT INTO dw."FI-D0_ExchangeRates" VALUES('INR','B','2018-12-31 00:00:00',75,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('KRW','B','2018-12-31 00:00:00',1300,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('MXN','B','2018-12-31 00:00:00',21,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('CNY','B','2018-12-31 00:00:00',7.80,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('TND','B','2018-12-31 00:00:00',2.90,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('USD','B','2018-12-31 00:00:00',1.20,'2018-02-01 00:00:00');


-- end of month rate

INSERT INTO dw."FI-D0_ExchangeRates" VALUES('CNY','E','2017-12-31 00:00:00',7.80,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('INR','E','2017-12-31 00:00:00',76.60,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('KRW','E','2017-12-31 00:00:00',1279.61,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('MXN','E','2017-12-31 00:00:00',23.66,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('USD','E','2017-12-31 00:00:00',1.19,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('TND','E','2017-12-31 00:00:00',2.94,'2018-02-01 00:00:00');


INSERT INTO dw."FI-D0_ExchangeRates" VALUES('CNY','E','2018-01-31 00:00:00',7.80,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('INR','E','2018-01-31 00:00:00',76.60,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('KRW','E','2018-01-31 00:00:00',1279.61,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('MXN','E','2018-01-31 00:00:00',23.66,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('USD','E','2018-01-31 00:00:00',1.19,'2018-02-01 00:00:00');
INSERT INTO dw."FI-D0_ExchangeRates" VALUES('TND','E','2018-01-31 00:00:00',2.94,'2018-02-01 00:00:00');
