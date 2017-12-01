
-- enleve tous les from_code qui ne sont pas expediteurs
-- WH = warehouse
-- PR = production
-- PL = plateforme 
-- TR = transfert
WITH 
temp_lod4_1 AS
(
SELECT 
	* 
FROM dw."LO-D4_Movements"
WHERE from_code NOT IN
('PL',
'PR',
'TR',
'WH')
),

-- 2eme etape 
-- permet d'avoir le prix de l'article selon la somme des achats livres (Movement_value) 
-- divise par la somme des quantites recues (Quantity)
temp_lod4_2 AS
(
SELECT 
	from_code,
	"Internal_reference",
	(SUM("Movement_value") / SUM("Quantity")) AS average_price, 
	EXTRACT(YEAR FROM "Movement_date") AS year,
	"Site"
FROM toto
-- WHERE "Internal_reference" = '20-0108-07P'
-- enleve tous les retours (quantité et mouvement)
WHERE "Quantity" >0 AND "Movement_value" > 0
GROUP BY EXTRACT(YEAR FROM "Movement_date"),from_code,"Internal_reference","Site"
),
temp_lod4_3 AS
(
SELECT DISTINCT 
	"Supplier_name",
	temp_l2."Internal_reference",
	average_price,
	year,
	temp_l2."Site"
FROM temp_lod4_2 as temp_l2 
INNER JOIN dw."T03_Suppliers" as t03 
ON temp_l2.from_code = t03."Supplier_code"
--WHERE year='2017'
ORDER BY year
)
-- le row_number permet de savoir s'il y'a des doublons
SELECT *
,
	ROW_NUMBER () OVER (
 PARTITION BY "Supplier_name","Internal_reference",year
 ORDER BY
 year) as row 
 FROM temp_lod4_3



