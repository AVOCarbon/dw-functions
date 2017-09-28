-- Function: report.get_lo001(timestamp without time zone, timestamp without time zone, integer)

-- DROP FUNCTION report.get_lo001(timestamp without time zone, timestamp without time zone, integer);

CREATE OR REPLACE FUNCTION report.get_lo001(IN "date_D" timestamp without time zone, IN "date_F" timestamp without time zone, IN frequence integer)
  RETURNS TABLE("Period_date" timestamp without time zone, "Site" character varying, "Supplier_code" character varying, "Internal_reference" character varying, "Shipment_number" character varying, "PO_number" character varying, "Quantity" numeric, "Movement_value_EUR" numeric, "Movement_value_CUR" numeric, "Reception_price_EUR" numeric, "Reception_price_CUR" numeric, "Variance_refprice_EUR" numeric, "Variance_refprice_CUR" numeric, "Variance_value@refprice_EUR" numeric, "Variance_value@refprice_CUR" numeric, "Purchasing_currency" character varying, "Movement_date" timestamp without time zone, "Price_change" smallint) AS
$BODY$
DECLARE p_debut timestamp without time zone;
DECLARE p_fin timestamp without time zone;

BEGIN

p_debut = dw.get_period_end("date_D", "frequence");
p_fin = dw.get_period_end("date_F", "frequence");

RETURN QUERY 
WITH
"dates_1" AS(
SELECT p_debut::date + n AS "date",
                dw.period_frequency(p_debut::date + n) AS "frequency"
FROM generate_series(0, p_fin::date - p_debut::date) AS x(n)
WHERE (dw.period_frequency(p_debut::date + n) & frequence != 0)
),

"dates" AS(
SELECT "date", COALESCE(LAG("date") OVER (ORDER BY "date"), "date_D"::date - 1)  AS "date_prev", "frequency"
FROM "dates_1"
),

"Movement_over_period" AS (
SELECT "dates"."date"::timestamp without time zone, "LO-D4_Movements".*
FROM "dates" 
LEFT JOIN dw."LO-D4_Movements"
ON "LO-D4_Movements"."Movement_date" > "dates"."date_prev"
AND "LO-D4_Movements"."Movement_date" <= "dates"."date" 
WHERE "LO-D4_Movements"."Movement_date" >= "date_D" AND "LO-D4_Movements"."Movement_date" <= "date_F"
ORDER BY "LO-D4_Movements"."Site", dates."date"
),

"Ref_price" AS (
SELECT "LO-D4_Movements"."Internal_reference",
SUM ("LO-D4_Movements"."Movement_value") As "Ref_value",
SUM ("LO-D4_Movements"."Quantity") As "Ref_quantity",
"LO-D4_Movements"."Site"
FROM dw."LO-D4_Movements"
INNER JOIN (SELECT DISTINCT ON ("LO-D4_Movements"."Internal_reference", "LO-D4_Movements"."Site") "LO-D4_Movements"."Internal_reference",
	"LO-D4_Movements"."Movement_date" As "Ref_date",
	"LO-D4_Movements"."Site"
	FROM dw."LO-D4_Movements"
	INNER JOIN dw."T13_RefSupplier" ON "LO-D4_Movements".from_code::text = "T13_RefSupplier"."Supplier_code"::text AND "LO-D4_Movements"."Site"::text = "T13_RefSupplier"."Site"::text AND "LO-D4_Movements"."Internal_reference"::text = "T13_RefSupplier"."Internal_reference"::text
	WHERE "LO-D4_Movements"."Movement_date"< "date_D"
	ORDER BY "LO-D4_Movements"."Internal_reference", "LO-D4_Movements"."Site", "LO-D4_Movements"."Movement_date" DESC) LOD4_MaxDate
ON "LO-D4_Movements"."Internal_reference" =LOD4_MaxDate."Internal_reference" AND "LO-D4_Movements"."Site" =LOD4_MaxDate."Site" AND "LO-D4_Movements"."Movement_date" =LOD4_MaxDate."Ref_date"
INNER JOIN dw."T13_RefSupplier" ON "LO-D4_Movements".from_code::text = "T13_RefSupplier"."Supplier_code"::text AND "LO-D4_Movements"."Site"::text = "T13_RefSupplier"."Site"::text AND "LO-D4_Movements"."Internal_reference"::text = "T13_RefSupplier"."Internal_reference"::text
GROUP BY "LO-D4_Movements"."Internal_reference", "LO-D4_Movements"."Movement_date", "LO-D4_Movements"."Site"
),
-- update 28/09/17
-- change INNER JOIN dw."T13_RefSupplier to 
-- a LEFT JOIN dw."T13_RefSupplier 

"Receptions_over_period" AS (
SELECT "Movement_over_period".*,
Case 
WHEN "Ref_price"."Ref_quantity" is Null Then -1
WHEN "Ref_price"."Ref_quantity" = 0 Then 0 
ELSE "Ref_price"."Ref_value"/"Ref_price"."Ref_quantity" 
END AS "Ref_price",
"T13_RefSupplier"."Purchasing_currency"
FROM "Movement_over_period"
LEFT JOIN dw."T13_RefSupplier" ON "Movement_over_period".from_code::text = "T13_RefSupplier"."Supplier_code"::text AND "Movement_over_period"."Site"::text = "T13_RefSupplier"."Site"::text AND "Movement_over_period"."Internal_reference"::text = "T13_RefSupplier"."Internal_reference"::text
LEFT JOIN "Ref_price" ON "Movement_over_period"."Site"::text = "Ref_price"."Site"::text AND "Movement_over_period"."Internal_reference"::text = "Ref_price"."Internal_reference"::text
),

"Receptions_with_currency" AS (
SELECT 
"Receptions_over_period".*,
CASE
	WHEN "Receptions_over_period"."Site"::text <> 'Germany'::text THEN "C00_Sites"."Accounting_currency"::character varying
	ELSE "Receptions_over_period"."Purchasing_currency"
END AS "Movement_currency",
"C00_Sites"."Accounting_currency"::character varying,
date_trunc('MONTH'::text, "Receptions_over_period"."Movement_date") + '1 mon -1 days'::interval AS "eom_date",
date_trunc('YEAR'::text, "Receptions_over_period"."Movement_date") + '1 year -1 days'::interval AS "eoy_date"
FROM "Receptions_over_period" 
JOIN dw."C00_Sites" ON "Receptions_over_period"."Site"::text = "C00_Sites"."Site"::text
),

"Receptions_with_exchangerate_MC" AS (
SELECT 
"Receptions_with_currency".*,
COALESCE(exA."ratePerEur", exA_last."ratePerEur_Last")::numeric(15,4) AS "ratePerEur_A"
FROM "Receptions_with_currency"

LEFT JOIN dw."FI-D0_ExchangeRates" AS exA
ON exA."rateType" ='A'
AND "Receptions_with_currency"."Movement_currency" = exA."rateCurrency" 
AND "Receptions_with_currency"."eom_date" = exA."rateDate"
LEFT JOIN dw."FI-D0_ExchangeRates_LAST" AS exA_last
ON "Receptions_with_currency"."Movement_currency" = exA_last.rate_cur 
AND exA_last."rate_type" = 'A'

),


"Receptions_EUR" AS (
SELECT 
"Receptions_with_exchangerate_MC"."date",
"Receptions_with_exchangerate_MC"."eom_date",
"Receptions_with_exchangerate_MC"."eoy_date",
"Receptions_with_exchangerate_MC"."Site",
"Receptions_with_exchangerate_MC"."from_code" AS "Supplier_code",
"Receptions_with_exchangerate_MC"."Internal_reference",
"Receptions_with_exchangerate_MC"."shipment_number",
"Receptions_with_exchangerate_MC"."PO_number",
"Receptions_with_exchangerate_MC"."Quantity",
"Receptions_with_exchangerate_MC"."Movement_currency",
"Receptions_with_exchangerate_MC"."Movement_value",
"Receptions_with_exchangerate_MC"."Ref_price",
CASE WHEN "Receptions_with_exchangerate_MC"."Movement_currency" = 'EUR'::bpchar 
THEN "Receptions_with_exchangerate_MC"."Movement_value"
ELSE ("Receptions_with_exchangerate_MC"."Movement_value" / "Receptions_with_exchangerate_MC"."ratePerEur_A")
END AS "Movement_value_EUR",
CASE 
WHEN "Receptions_with_exchangerate_MC"."Ref_price" = -1 Then -1
WHEN "Receptions_with_exchangerate_MC"."Movement_currency" = 'EUR'::bpchar THEN "Receptions_with_exchangerate_MC"."Ref_price"
ELSE ("Receptions_with_exchangerate_MC"."Ref_price" / "Receptions_with_exchangerate_MC"."ratePerEur_A")
END AS "Ref_price_EUR",
"Receptions_with_exchangerate_MC"."Accounting_currency",
"Receptions_with_exchangerate_MC"."Purchasing_currency",
"Receptions_with_exchangerate_MC"."Movement_date"
FROM "Receptions_with_exchangerate_MC"
),

"Receptions_with_exchangerate_AC" AS (
SELECT 
"Receptions_EUR".*,
COALESCE(exA."ratePerEur", exA_last."ratePerEur_Last")::numeric(15,4) AS "ratePerEur_A"
FROM "Receptions_EUR"
LEFT JOIN dw."FI-D0_ExchangeRates" AS exA
ON exA."rateType" ='A'
AND "Receptions_EUR"."Accounting_currency" = exA."rateCurrency" 
AND "Receptions_EUR"."eom_date" = exA."rateDate"
LEFT JOIN dw."FI-D0_ExchangeRates_LAST" AS exA_last
ON "Receptions_EUR"."Accounting_currency" = exA_last.rate_cur 
AND exA_last."rate_type" = 'A'

),

"Receptions_final" AS (
SELECT 
"Receptions_with_exchangerate_AC"."date",
"Receptions_with_exchangerate_AC"."Site",
"Receptions_with_exchangerate_AC"."Supplier_code",
"Receptions_with_exchangerate_AC"."Internal_reference",
"Receptions_with_exchangerate_AC"."shipment_number",
"Receptions_with_exchangerate_AC"."PO_number",
"Receptions_with_exchangerate_AC"."Quantity"::numeric(15,4),
"Receptions_with_exchangerate_AC"."Movement_value_EUR"::numeric(15,4),
CASE WHEN "Receptions_with_exchangerate_AC"."Movement_currency" = "Receptions_with_exchangerate_AC"."Accounting_currency"
THEN "Receptions_with_exchangerate_AC"."Movement_value"::numeric(15,4)
ELSE ("Receptions_with_exchangerate_AC"."Movement_value_EUR" / "Receptions_with_exchangerate_AC"."ratePerEur_A")::numeric(15,4)
END AS "Movement_value_CUR",
CASE 
	WHEN "Receptions_with_exchangerate_AC"."Quantity" <> 0 Then ("Receptions_with_exchangerate_AC"."Movement_value_EUR"/"Receptions_with_exchangerate_AC"."Quantity") ::numeric(15,4)
	ELSE 0::numeric(15,4)
END AS "Reception_price_EUR",
CASE 
	WHEN ("Receptions_with_exchangerate_AC"."Quantity" <> 0 AND "Receptions_with_exchangerate_AC"."Movement_currency" = "Receptions_with_exchangerate_AC"."Accounting_currency") THEN ("Receptions_with_exchangerate_AC"."Movement_value"/"Receptions_with_exchangerate_AC"."Quantity")::numeric(15,4)
	WHEN ("Receptions_with_exchangerate_AC"."Quantity" <> 0) THEN (("Receptions_with_exchangerate_AC"."Movement_value_EUR" / "Receptions_with_exchangerate_AC"."ratePerEur_A")/"Receptions_with_exchangerate_AC"."Quantity")::numeric(15,4)
	ELSE 0::numeric(15,4)
END AS "Reception_price_CUR",
"Receptions_with_exchangerate_AC"."Ref_price_EUR"::numeric(15,4) AS "Variance_refprice_EUR",
CASE 
WHEN "Receptions_with_exchangerate_AC"."Ref_price" = -1 Then -1::numeric(15,4)
WHEN "Receptions_with_exchangerate_AC"."Movement_currency" = "Receptions_with_exchangerate_AC"."Accounting_currency"
THEN "Receptions_with_exchangerate_AC"."Ref_price"::numeric(15,4)
ELSE ("Receptions_with_exchangerate_AC"."Ref_price_EUR" / "Receptions_with_exchangerate_AC"."ratePerEur_A")::numeric(15,4)
END AS "Variance_refprice_CUR",
CASE
WHEN "Receptions_with_exchangerate_AC"."Ref_price_EUR" =-1 Then 0::numeric(15,4)
ELSE ("Receptions_with_exchangerate_AC"."Ref_price_EUR"*"Receptions_with_exchangerate_AC"."Quantity")::numeric(15,4) 
END AS "Variance_value@refprice_EUR",
CASE 
WHEN "Receptions_with_exchangerate_AC"."Ref_price" = -1 Then 0::numeric(15,4)
WHEN "Receptions_with_exchangerate_AC"."Movement_currency" = "Receptions_with_exchangerate_AC"."Accounting_currency"
THEN ("Receptions_with_exchangerate_AC"."Ref_price"*"Receptions_with_exchangerate_AC"."Quantity")::numeric(15,4)
ELSE (("Receptions_with_exchangerate_AC"."Ref_price_EUR" / "Receptions_with_exchangerate_AC"."ratePerEur_A")*"Receptions_with_exchangerate_AC"."Quantity")::numeric(15,4)
END AS "Variance_value@refprice_CUR",
"Receptions_with_exchangerate_AC"."Purchasing_currency",
"Receptions_with_exchangerate_AC"."Movement_date"
FROM "Receptions_with_exchangerate_AC"
)

SELECT *, 
CASE WHEN Round("Receptions_final"."Movement_value_CUR",0)=Round("Receptions_final"."Variance_value@refprice_CUR",0) THEN 0::smallint
Else -1::smallint
End AS "Price_change"
FROM "Receptions_final"
-- update 28/09/17 : adding the condition below to remove where it is coming from a warehouse
WHERE Supplier_code != 'WH';

END
$BODY$
  LANGUAGE plpgsql STABLE
  COST 100
  ROWS 1000;
ALTER FUNCTION report.get_lo001(timestamp without time zone, timestamp without time zone, integer)
  OWNER TO avocarbon;
