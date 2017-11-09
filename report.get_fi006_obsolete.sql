-- Function: report.get_fi006_obsolete(timestamp without time zone, timestamp without time zone, integer)

-- DROP FUNCTION report.get_fi006_obsolete(timestamp without time zone, timestamp without time zone, integer);

CREATE OR REPLACE FUNCTION report.get_fi006_obsolete(IN "date_D" timestamp without time zone, IN "date_F" timestamp without time zone, IN frequence integer)
  RETURNS TABLE("Period_date" timestamp without time zone, 
  				"Site" character varying, 
  				"Internal_reference" character varying, 
  				"Inventory_quantity" numeric, "
  				Inventory_location" character, 
  				"Inventory_unitprice" numeric, 
  				"Inventory_value_gross_CUR" numeric, 
  				"Inventory_value_gross_EUR" numeric, 
  				"Inventory_value_net_CUR" numeric, 
  				"Inventory_value_net_EUR" numeric, 
  				"Inventory_obsolete" character varying, 
  				"Inventory_lastmovement" timestamp without time zone, 
  				"Inventory_dateOBS" timestamp without time zone, 
  				"Inventory_M" integer, 
  				"Inventory_M+1" integer, 
  				"Inventory_M+2" integer, 
  				"Inventory_M+3" integer, 
  				"Inventory_M+4" integer, 
  				"Inventory_M+5" integer, 
  				"Inventory_ForecastOBS" integer) AS
$BODY$

BEGIN

RETURN QUERY 
WITH

-- 08/11/17
-- change only done for France
-- adding all columns by name instead of by a *

"Inventory" AS (
	SELECT "Period_date",
			"Site",
			"Internal_reference",
			"Inventory_quantity",
			"Inventory_location",
			"Inventory_unitprice",
			"Inventory_value_gross_CUR",
			"Inventory_value_gross_EUR",
			"Inventory_value_net_CUR",
			"Inventory_value_net_EUR",
			"Inventory_obsolete",
			"Inventory_lastmovement"
	FROM report.get_fi006("date_D","date_F", frequence)
),

 "Ref" AS (
	 SELECT "Inventory"."Internal_reference", 
		"Inventory"."Site",
		Max("Inventory"."Inventory_lastmovement")AS "Inventory_lastmovement"
	FROM "Inventory" 
	GROUP BY "Inventory"."Internal_reference", "Inventory"."Site"
),

 "Ref_obs" AS (
	SELECT "Inventory"."Internal_reference", 
		"Inventory"."Site",
		Min("Inventory"."Inventory_lastmovement")AS "Inventory_lastmovement",
		date_trunc('DAY'::text, Min("Inventory"."Inventory_lastmovement") + '180 days'::interval) AS "Inventory_dateOBS" 
	FROM "Inventory"
	WHERE round("Inventory"."Inventory_value_gross_CUR",0)<>round("Inventory"."Inventory_value_net_CUR",0) 
	GROUP BY "Inventory"."Internal_reference", "Inventory"."Site"
 ),
 
 "Obs" AS (
	SELECT DISTINCT "Ref"."Internal_reference",
		"Ref"."Site",
		CASE
			WHEN date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) >= 180::double precision THEN 1
			ELSE 0
		END AS "Inventory_M",
		CASE
			WHEN date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) >= 150::double precision AND date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) < 180::double precision THEN 1
			ELSE 0
		END AS "Inventory_M+1",
		CASE
			WHEN date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) >= 120::double precision AND date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) < 150::double precision THEN 1
			ELSE 0
		END AS "Inventory_M+2",
		CASE
			WHEN date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) >= 90::double precision AND date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) < 120::double precision THEN 1
			ELSE 0
		END AS "Inventory_M+3",
		CASE
			WHEN date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) >= 60::double precision AND date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) < 90::double precision THEN 1
			ELSE 0
		END AS "Inventory_M+4",
		CASE
			WHEN date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) >= 30::double precision AND date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) < 60::double precision THEN 1
			ELSE 0
		END AS "Inventory_M+5",
		CASE
			WHEN date_part('days'::text, date_trunc('MONTH'::text, current_date::timestamp with time zone) + '1 mon -1 days'::interval - "Ref"."Inventory_lastmovement"::timestamp with time zone) >= 30::double precision THEN 1
			ELSE 0
		END AS "Inventory_ForecastOBS"
	FROM "Ref"
)

SELECT "Inventory".*,
	"Ref_obs"."Inventory_dateOBS",
	"Obs"."Inventory_M",
	"Obs"."Inventory_M+1",
	"Obs"."Inventory_M+2",
	"Obs"."Inventory_M+3",
	"Obs"."Inventory_M+4",
	"Obs"."Inventory_M+5",
	"Obs"."Inventory_ForecastOBS"
FROM "Inventory"
LEFT JOIN "Obs" ON "Inventory"."Internal_reference"::text ="Obs"."Internal_reference"::text AND "Inventory"."Site"::text ="Obs"."Site"::text
LEFT JOIN "Ref_obs" ON "Inventory"."Internal_reference"::text ="Ref_obs"."Internal_reference"::text AND "Inventory"."Site"::text ="Ref_obs"."Site"::text
WHERE "Inventory"."Site"::text <> 'Corporate'::text;
  
END
$BODY$
  LANGUAGE plpgsql STABLE
  COST 100
  ROWS 1000;
ALTER FUNCTION report.get_fi006_obsolete(timestamp without time zone, timestamp without time zone, integer)
  OWNER TO avocarbon;
