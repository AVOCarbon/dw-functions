-- View: report."Axis_Reference_All"

-- DROP VIEW report."Axis_Reference_All";

CREATE OR REPLACE VIEW report."Axis_Reference_All" AS 
 SELECT "T01_References"."Site",
    "T01_References"."Internal_reference" AS "Reference",
    "T01_References"."Internal_reference" AS "Reference_internal",
    t12."Customer_reference" AS "Reference_customer",
    t13."Supplier_reference" AS "Reference_supplier",
    "T01_References"."Reference_description",
    "T01_References"."Workshop" AS "Reference_workshop",
    "T01_References"."Production_line" AS "Reference_line",
    "C02_ProductSegments"."Segment_name" AS "Reference_segment",
    "C09_PurchasingFamilies"."Family_name" AS "Reference_purchasingfamily",
    "C03_MotorApplications"."Motor_application" AS "Reference_motorapplication",
        CASE
            WHEN "T02_Customers"."Global_customer_C04"::text = 'AVOCarbon'::text OR "T03_Suppliers"."Global_supplier"::text = 'AVOCarbon'::text THEN 'Y'::character varying
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
        CASE
            WHEN "T02_Customers"."Global_customer_C04"::text = '#ND'::text THEN '(Other)'::character varying
            ELSE "T02_Customers"."Global_customer_C04"
        END AS "Customer_global",
    "T02_Customers"."Customer_code",
    "T02_Customers"."Customer_name",
    "T02_Customers"."Account_manager" AS "Customer_account_manager",
        CASE
            WHEN "T02_Customers"."Global_customer_C04"::text = 'AVOCarbon'::text THEN 'Y'::character varying
            ELSE 'N'::character varying
        END AS "Customer_interco",
    "T02_Customers"."Incoterm" AS "Customer_incoterm",
    "T02_Customers"."Incoterm_location" AS "Customer_incoterm_location",
    "T02_Customers"."Incoterm_via" AS "Customer_incoterm_via",
    cc05."Continent" AS "Customer_continent",
    cc05."Country" AS "Customer_country",
    "T02_Customers"."City" AS "Customer_city",
    "T02_Customers"."ZipCode" AS "Customer_zipcode",
    t12."Selling_unit",
    t12."Selling_price",
    t12."Selling_currency",
    "T02_Customers"."Payment_term_days" AS "Selling_payment_term_days",
    "T02_Customers"."Payment_term_type" AS "Selling_payment_term_type",
    t12."Consigned" AS "Selling_consigned",
    t12."Product_grossweight" AS "Selling_grossweight",
    t12."Product_grosscube" AS "Selling_grosscube",
    t12."Eco_order_qty" AS "Selling_eco_order_qty",
    t12."Pack_order_qty" AS "Selling_pack_order_qty",
    COALESCE(t12."Min_order_qty"::numeric, "T02_Customers"."Min_order_qty", 0::numeric)::integer AS "Selling_moq",
    COALESCE(t12."Min_order_value"::numeric, "T02_Customers"."Min_order_value", 0::numeric)::integer AS "Selling_mov",
    t12."Leadtime_days" AS "Selling_leadtime_days",
    "T01_References"."Product_netweight" AS "Reference_netweight",
    "T01_References"."Storage_unit" AS "Sc_storage_unit",
    "T01_References"."Production_unit" AS "Sc_production_unit",
    "T01_References"."Inventory_status" AS "Sc_inventory_status",
    "T01_References"."Inventory_price" AS "Sc_inventory_price",
        CASE
            WHEN t13."Internal_reference" IS NOT NULL THEN 'RM'::text
            ELSE
            CASE
                WHEN t12."Internal_reference" IS NOT NULL THEN 'FG'::text
                ELSE 'WIP'::text
            END
        END AS "Sc_inventory_type"
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
     LEFT JOIN (( SELECT "T12_RefCustomer"."Customer_code",
            "T12_RefCustomer"."Internal_reference",
            "T12_RefCustomer"."Customer_reference",
            "T12_RefCustomer"."Application_code",
            "T12_RefCustomer"."Selling_unit",
            "T12_RefCustomer"."Selling_price",
            "T12_RefCustomer"."Selling_currency",
            "T12_RefCustomer"."Consigned",
            "T12_RefCustomer"."Eco_order_qty",
            "T12_RefCustomer"."Pack_order_qty",
            "T12_RefCustomer"."Min_order_qty",
            "T12_RefCustomer"."Min_order_value",
            "T12_RefCustomer"."Product_grossweight",
            "T12_RefCustomer"."Product_grosscube",
            "T12_RefCustomer"."Leadtime_days",
            "T12_RefCustomer"."Site",
            "T12_RefCustomer"."Import_date",
            "T12_RefCustomer"."Ref_price",
            "T12_RefCustomer"."Customer_active"
           FROM dw."T12_RefCustomer") t12
     LEFT JOIN (dw."T02_Customers"
     LEFT JOIN dw."C05_GeographicAreas" cc05 ON "T02_Customers"."Country_ISO3"::text = cc05."Country_ISO3"::text) ON "T02_Customers"."Site"::text = t12."Site"::text AND "T02_Customers"."Customer_code"::text = t12."Customer_code"::text
     LEFT JOIN dw."C03_MotorApplications" ON t12."Application_code"::text = "C03_MotorApplications"."Application_code"::text) ON "T01_References"."Site"::text = t12."Site"::text AND "T01_References"."Internal_reference"::text = t12."Internal_reference"::text
     LEFT JOIN dw."C02_ProductSegments" ON "T01_References"."Segment_code"::text = "C02_ProductSegments"."Segment_code"::text;

ALTER TABLE report."Axis_Reference_All"
  OWNER TO avocarbon;
