-- View: report."Axis_RefSupplier"

-- DROP VIEW report."Axis_RefSupplier";

-- 17/11/17
-- added the column "t13.Supplier_active" to the list of retrieved columns

CREATE OR REPLACE VIEW report."Axis_RefSupplier" AS 
 SELECT "T01_References"."Site",
    "T01_References"."Internal_reference" AS "Reference",
    "T01_References"."Internal_reference" AS "Reference_internal",
    t13."Supplier_reference" AS "Reference_supplier",
    "T01_References"."Reference_description",
    "T01_References"."Workshop" AS "Reference_workshop",
    "T01_References"."Production_line" AS "Reference_line",
    "C02_ProductSegments"."Segment_name" AS "Reference_segment",
    "C09_PurchasingFamilies"."Family_code" AS "Reference_purchasingcode",
    "C09_PurchasingFamilies"."Family_name" AS "Reference_purchasingfamily",
    "C09_PurchasingFamilies"."Family_sub1" AS "Reference_purchasingsubcode",
    "C09_PurchasingFamilies".family_sub_name AS "Reference_purchasingsubname",
        CASE
            WHEN "T03_Suppliers"."Global_supplier"::text = 'AVOCarbon'::text THEN 'Y'::character varying
            ELSE 'N'::character varying
        END AS "Reference_interco",
        CASE
            WHEN "T01_References"."Product_trading" = 'Y'::bpchar OR "T01_References"."Product_trading" = '1'::bpchar THEN 'Y'::character varying
            WHEN "T01_References"."Product_trading" = 'N'::bpchar OR "T01_References"."Product_trading" = '0'::bpchar THEN 'N'::character varying
            ELSE 'U'::character varying
        END AS "Reference_trading",
    "T01_References"."Cogs_rm",
    "T01_References"."Cogs_dl",
    "T01_References"."Cogs_voh",
        CASE
            WHEN "T03_Suppliers"."Global_supplier"::text = '#ND'::text THEN '(Other)'::character varying
            ELSE "T03_Suppliers"."Global_supplier"
        END AS "Supplier_global",
    "T03_Suppliers"."Supplier_code",
    "T03_Suppliers"."Supplier_name",
    ("T03_Suppliers"."Supplier_name"::text || '_'::text) || "T01_References"."Internal_reference"::text AS "Supplier_Product",
    (((("T03_Suppliers"."Supplier_name"::text || ' > '::text) || "T01_References"."Site"::text) || ' ( '::text) || "T03_Suppliers"."Incoterm"::text) || ' )'::text AS "Flow_name",
    ("T03_Suppliers"."Country_ISO3_C05"::text || ' > '::text) || "T01_References"."Site"::text AS "Flow_country",
    (sc05."Continent"::text || ' > '::text) || "T01_References"."Site"::text AS "Flow_continent",
    "T03_Suppliers"."Account_manager" AS "Supplier_account_manager",
        CASE
            WHEN "T03_Suppliers"."Global_supplier"::text = 'AVOCarbon'::text THEN 'Y'::character varying
            ELSE 'N'::character varying
        END AS "Supplier_interco",
    "T03_Suppliers"."Incoterm" AS "Supplier_incoterm",
    "T03_Suppliers"."Incoterm_location" AS "Supplier_incoterm_location",
    "T03_Suppliers"."Incoterm_via" AS "Supplier_incoterm_via",
    sc05."Continent" AS "Supplier_continent",
    sc05."Country" AS "Supplier_country",
    "T03_Suppliers"."City" AS "Supplier_city",
    "T03_Suppliers"."ZipCode" AS "Supplier_zipcode",
    t13."Purchasing_unit",
    t13."Purchasing_price",
    t13."Purchasing_currency",
    "T03_Suppliers"."Payment_term_days" AS "Purchasing_payment_term_days",
    "T03_Suppliers"."Payment_term_type" AS "Purchasing_payment_term_type",
    t13."Consigned" AS "Purchasing_consigned",
    t13."Product_grossweight" AS "Purchasing_grossweight",
    t13."Product_grosscube" AS "Purchasing_grosscube",
    t13."Eco_order_qty" AS "Purchasing_eco_order_qty",
    t13."Pack_order_qty" AS "Purchasing_pack_order_qty",
    COALESCE(t13."Min_order_qty"::numeric, "T03_Suppliers"."Min_order_qty", 0::numeric)::integer AS "Purchasing_moq",
    COALESCE(t13."Min_order_value"::numeric, "T03_Suppliers"."Min_order_value", 0::numeric)::integer AS "Purchasing_mov",
    t13."Leadtime_days" AS "Purchasing_leadtime_days",
    "T01_References"."Product_netweight" AS "Reference_netweight",
    "T01_References"."Storage_unit" AS "Sc_storage_unit",
    "T01_References"."Production_unit" AS "Sc_production_unit",
    "T01_References"."Inventory_status" AS "Sc_inventory_status",
    "T01_References"."Inventory_price" AS "Sc_inventory_price",
    "T01_References"."HS_code",
    t13."Supplier_active"
   FROM dw."T01_References"
     LEFT JOIN (( SELECT "T13_RefSupplier"."Supplier_code",
            "T13_RefSupplier"."Internal_reference",
            "T13_RefSupplier"."Supplier_reference",
            "T13_RefSupplier"."Family_code",
            "T13_RefSupplier"."Purchasing_unit",
            "T13_RefSupplier"."Purchasing_price",
            "T13_RefSupplier"."Purchasing_currency",
            "T13_RefSupplier"."Consigned",
            "T13_RefSupplier"."Eco_order_qty",
            "T13_RefSupplier"."Pack_order_qty",
            "T13_RefSupplier"."Min_order_qty",
            "T13_RefSupplier"."Min_order_value",
            "T13_RefSupplier"."Product_grossweight",
            "T13_RefSupplier"."Product_grosscube",
            "T13_RefSupplier"."Leadtime_days",
            "T13_RefSupplier"."Supplier_active",
            "T13_RefSupplier"."Site",
            "T13_RefSupplier"."Import_date",
            "T13_RefSupplier"."Ref_price"
           FROM dw."T13_RefSupplier") t13
     LEFT JOIN (dw."T03_Suppliers"
     LEFT JOIN dw."C05_GeographicAreas" sc05 ON "T03_Suppliers"."Country_ISO3_C05"::text = sc05."Country_ISO3"::text) ON "T03_Suppliers"."Site"::text = t13."Site"::text AND "T03_Suppliers"."Supplier_code"::text = t13."Supplier_code"::text
     LEFT JOIN dw."C09_PurchasingFamilies" ON t13."Family_code"::text = "C09_PurchasingFamilies"."Family_code"::text) ON "T01_References"."Site"::text = t13."Site"::text AND "T01_References"."Internal_reference"::text = t13."Internal_reference"::text
     LEFT JOIN dw."C02_ProductSegments" ON "T01_References"."Segment_code"::text = "C02_ProductSegments"."Segment_code"::text;

ALTER TABLE report."Axis_RefSupplier"
  OWNER TO avocarbon;
