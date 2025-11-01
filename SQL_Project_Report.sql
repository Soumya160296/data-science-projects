-----------------------------------------------------------------------------------------------------------------------------------

                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/

-- 1. WRITE A QUERY TO DISPLAY CUSTOMER FULL NAME WITH THEIR TITLE (MR/MS), BOTH FIRST NAME AND LAST NAME ARE IN UPPER CASE WITH 
-- CUSTOMER EMAIL ID, CUSTOMER CREATIONDATE AND DISPLAY CUSTOMER’S CATEGORY AFTER APPLYING BELOW CATEGORIZATION RULES:
	-- i.IF CUSTOMER CREATION DATE YEAR <2005 THEN CATEGORY A
    -- ii.IF CUSTOMER CREATION DATE YEAR >=2005 AND <2011 THEN CATEGORY B
    -- iii.IF CUSTOMER CREATION DATE YEAR>= 2011 THEN CATEGORY C
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER TABLE]

#Soln.-

# select *  FROM online_customer;

SELECT 
    CASE
        WHEN YEAR(customer_creation_date) < 2005 THEN 'Category A'
        WHEN YEAR(customer_creation_date) >= 2005 AND YEAR(customer_creation_date) < 2011 THEN 'Category B'
        ELSE 'Category C'
    END AS customer_category,
    UPPER(CONCAT(
        CASE 
            WHEN customer_gender = 'M' THEN 'MR'
            WHEN customer_gender = 'F' THEN 'MS'
            ELSE ''
        END,
        ' ',
        COALESCE(UPPER(customer_fname), ''),
        ' ',
        COALESCE(UPPER(customer_lname), '')
    )) AS full_name,
    customer_email,
    customer_creation_date
FROM 
    online_customer
LIMIT 5;



-- 2. WRITE A QUERY TO DISPLAY THE FOLLOWING INFORMATION FOR THE PRODUCTS, WHICH HAVE NOT BEEN SOLD:  PRODUCT_ID, PRODUCT_DESC, 
-- PRODUCT_QUANTITY_AVAIL, PRODUCT_PRICE,INVENTORY VALUES(PRODUCT_QUANTITY_AVAIL*PRODUCT_PRICE), NEW_PRICE AFTER APPLYING DISCOUNT 
-- AS PER BELOW CRITERIA. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- i.IF PRODUCT PRICE > 20,000 THEN APPLY 20% DISCOUNT
    -- ii.IF PRODUCT PRICE > 10,000 THEN APPLY 15% DISCOUNT
    -- iii.IF PRODUCT PRICE =< 10,000 THEN APPLY 10% DISCOUNT
    
    -- HINT: USE CASE STATEMENT, NO PERMANENT CHANGE IN TABLE REQUIRED. [NOTE: TABLES TO BE USED -PRODUCT, ORDER_ITEMS TABLE] 
    
#Soln.-

SELECT 
    p.product_id,
    p.product_desc,
    p.product_quantity_avail,
    p.product_price,
    (p.product_quantity_avail * p.product_price) AS inventory_value,
    CASE
        WHEN p.product_price > 20000 THEN p.product_price * 0.8
        WHEN p.product_price > 10000 THEN p.product_price * 0.85
        ELSE p.product_price * 0.9
    END AS new_price
FROM 
    product p
LEFT JOIN 
    order_items oi ON p.product_id = oi.product_id
WHERE 
    oi.product_id IS NULL
ORDER BY 
    inventory_value DESC
LIMIT 5;



-- 3. WRITE A QUERY TO DISPLAY PRODUCT_CLASS_CODE, PRODUCT_CLASS_DESCRIPTION, COUNT OF PRODUCT TYPE IN EACH PRODUCT CLASS, 
-- INVENTORY VALUE (P.PRODUCT_QUANTITY_AVAIL*P.PRODUCT_PRICE). INFORMATION SHOULD BE DISPLAYED FOR ONLY THOSE PRODUCT_CLASS_CODE 
-- WHICH HAVE MORE THAN 1,00,000 INVENTORY VALUE. SORT THE OUTPUT WITH RESPECT TO DECREASING VALUE OF INVENTORY_VALUE.
	-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS]
    
#Soln.-

# select * from product;

SELECT 
    pc.product_class_code,
    pc.product_class_desc,
    COUNT(p.product_id) AS product_count,
    SUM(p.product_quantity_avail * p.product_price) AS inventory_value
FROM 
    product p
INNER JOIN 
    product_class pc ON p.product_class_code = pc.product_class_code
GROUP BY 
    pc.product_class_code, pc.product_class_desc
HAVING 
    SUM(p.product_quantity_avail * p.product_price) > 100000
ORDER BY 
    inventory_value DESC
LIMIT 5;



-- 4. WRITE A QUERY TO DISPLAY CUSTOMER_ID, FULL NAME, CUSTOMER_EMAIL, CUSTOMER_PHONE AND COUNTRY OF CUSTOMERS WHO HAVE CANCELLED 
-- ALL THE ORDERS PLACED BY THEM(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]

#Soln.-

SELECT 
    oc.customer_id,
    CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS full_name,
    oc.customer_email,
    oc.customer_phone,
    a.country
FROM 
    online_customer oc
JOIN 
    address a ON oc.address_id = a.address_id
WHERE 
    oc.customer_id IN (
        SELECT 
            oh.customer_id
        FROM 
            order_header oh
        WHERE 
            oh.order_status = 'Cancelled'
        GROUP BY 
            oh.customer_id
        HAVING 
            COUNT(*) = (SELECT COUNT(*) FROM order_header WHERE customer_id = oh.customer_id)
    )
LIMIT 5;


        
-- 5. WRITE A QUERY TO DISPLAY SHIPPER NAME, CITY TO WHICH IT IS CATERING, NUMBER OF CUSTOMER CATERED BY THE SHIPPER IN THE CITY AND 
-- NUMBER OF CONSIGNMENTS DELIVERED TO THAT CITY FOR SHIPPER DHL(9 ROWS)
	-- [NOTE: TABLES TO BE USED -SHIPPER, ONLINE_CUSTOMER, ADDRESSS, ORDER_HEADER]
    
#Soln.-

SELECT 
    s.shipper_name,
    a.city AS city_catered,
    COUNT(DISTINCT oc.customer_id) AS num_customers_catered,
    COUNT(oh.order_id) AS num_consignments_delivered
FROM 
    shipper s
INNER JOIN 
    order_header oh ON s.shipper_id = oh.shipper_id
INNER JOIN 
    online_customer oc ON oh.customer_id = oc.customer_id
INNER JOIN 
    address a ON oc.address_id = a.address_id
WHERE 
    s.shipper_name = 'DHL'
GROUP BY 
    s.shipper_name, a.city
LIMIT 5;



-- 6. WRITE A QUERY TO DISPLAY CUSTOMER ID, CUSTOMER FULL NAME, TOTAL QUANTITY AND TOTAL VALUE (QUANTITY*PRICE) SHIPPED WHERE MODE 
-- OF PAYMENT IS CASH AND CUSTOMER LAST NAME STARTS WITH 'G'
	-- [NOTE: TABLES TO BE USED -ONLINE_CUSTOMER, ORDER_ITEMS, PRODUCT, ORDER_HEADER]
#Soln.-

SELECT 
    oc.customer_id,
    CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS customer_full_name,
    SUM(oi.product_quantity) AS total_quantity,
    SUM(oi.product_quantity * p.product_price) AS total_value_shipped
FROM 
    online_customer oc
JOIN 
    order_header oh ON oc.customer_id = oh.customer_id
JOIN 
    order_items oi ON oh.order_id = oi.order_id
JOIN 
    product p ON oi.product_id = p.product_id
WHERE 
    oh.payment_mode = 'Cash' AND oc.customer_lname LIKE 'G%'
GROUP BY 
    oc.customer_id, oc.customer_fname, oc.customer_lname
LIMIT 5;


    
-- 7. WRITE A QUERY TO DISPLAY ORDER_ID AND VOLUME OF BIGGEST ORDER (IN TERMS OF VOLUME) THAT CAN FIT IN CARTON ID 10  
	-- [NOTE: TABLES TO BE USED -CARTON, ORDER_ITEMS, PRODUCT]
    
#Soln.-

SELECT 
    oi.order_id,
    SUM(p.len * p.width * p.height * oi.product_quantity) AS order_volume
FROM 
    order_items oi
JOIN 
    product p ON oi.product_id = p.product_id
WHERE 
    p.product_id IN (
        SELECT 
            oi.product_id 
        FROM 
            carton c
        WHERE 
            c.carton_id = 10
    )
GROUP BY 
    oi.order_id
ORDER BY 
    order_volume DESC
LIMIT 1;



-- 8. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC, PRODUCT_QUANTITY_AVAIL, QUANTITY SOLD, AND SHOW INVENTORY STATUS OF 
-- PRODUCTS AS BELOW AS PER BELOW CONDITION:
	-- A.FOR ELECTRONICS AND COMPUTER CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY',
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 10% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY', 
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 50% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 50% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- B.FOR MOBILES AND WATCHES CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 20% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 60% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv.IF INVENTORY QUANTITY IS MORE OR EQUAL TO 60% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
	-- C.REST OF THE CATEGORIES, 
		-- i.IF SALES TILL DATE IS ZERO THEN SHOW 'NO SALES IN PAST, GIVE DISCOUNT TO REDUCE INVENTORY', 
        -- ii.IF INVENTORY QUANTITY IS LESS THAN 30% OF QUANTITY SOLD, SHOW 'LOW INVENTORY, NEED TO ADD INVENTORY',  
        -- iii.IF INVENTORY QUANTITY IS LESS THAN 70% OF QUANTITY SOLD, SHOW 'MEDIUM INVENTORY, NEED TO ADD SOME INVENTORY', 
        -- iv. IF INVENTORY QUANTITY IS MORE OR EQUAL TO 70% OF QUANTITY SOLD, SHOW 'SUFFICIENT INVENTORY'
        
			-- [NOTE: TABLES TO BE USED -PRODUCT, PRODUCT_CLASS, ORDER_ITEMS] (USE SUB-QUERY)

#Soln.-

SELECT 
    p.product_id,
    p.product_desc,
    p.product_quantity_avail,
    COALESCE(quantity_sold, 0) AS quantity_sold,
    CASE 
        WHEN pc.product_class_desc IN ('Electronics', 'Computer') THEN
            CASE 
                WHEN COALESCE(quantity_sold, 0) = 0 THEN 'No sales in past, give discount to reduce inventory'
                WHEN p.product_quantity_avail < 0.1 * COALESCE(quantity_sold, 0) THEN 'Low inventory, need to add inventory'
                WHEN p.product_quantity_avail < 0.5 * COALESCE(quantity_sold, 0) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        WHEN pc.product_class_desc IN ('Mobiles', 'Watches') THEN
            CASE 
                WHEN COALESCE(quantity_sold, 0) = 0 THEN 'No sales in past, give discount to reduce inventory'
                WHEN p.product_quantity_avail < 0.2 * COALESCE(quantity_sold, 0) THEN 'Low inventory, need to add inventory'
                WHEN p.product_quantity_avail < 0.6 * COALESCE(quantity_sold, 0) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
        ELSE
            CASE 
                WHEN COALESCE(quantity_sold, 0) = 0 THEN 'No sales in past, give discount to reduce inventory'
                WHEN p.product_quantity_avail < 0.3 * COALESCE(quantity_sold, 0) THEN 'Low inventory, need to add inventory'
                WHEN p.product_quantity_avail < 0.7 * COALESCE(quantity_sold, 0) THEN 'Medium inventory, need to add some inventory'
                ELSE 'Sufficient inventory'
            END
    END AS inventory_status
FROM 
    product p
JOIN 
    product_class pc ON p.product_class_code = pc.product_class_code
LEFT JOIN 
    (
        SELECT 
            oi.product_id,
            SUM(oi.product_quantity) AS quantity_sold
        FROM 
            order_items oi
        JOIN 
            order_header oh ON oi.order_id = oh.order_id
        WHERE 
            oh.order_status = 'Completed'
        GROUP BY 
            oi.product_id
    ) AS sales ON p.product_id = sales.product_id
LIMIT 5;

    


-- 9. WRITE A QUERY TO DISPLAY PRODUCT_ID, PRODUCT_DESC AND TOTAL QUANTITY OF PRODUCTS WHICH ARE SOLD TOGETHER WITH PRODUCT ID 201 
-- AND ARE NOT SHIPPED TO CITY BANGALORE AND NEW DELHI. DISPLAY THE OUTPUT IN DESCENDING ORDER WITH RESPECT TO TOT_QTY.(USE SUB-QUERY)
	-- [NOTE: TABLES TO BE USED -ORDER_ITEMS,PRODUCT,ORDER_HEADER, ONLINE_CUSTOMER, ADDRESS]
    
#Soln.-

SELECT 
    p.product_id,
    p.product_desc,
    SUM(oi.product_quantity) AS total_quantity
FROM 
    order_items oi
JOIN 
    product p ON oi.product_id = p.product_id
JOIN 
    order_header oh ON oi.order_id = oh.order_id
JOIN 
    online_customer oc ON oh.customer_id = oc.customer_id
JOIN 
    address a ON oc.address_id = a.address_id
WHERE 
    oi.product_id <> 201
    AND oi.order_id IN (
        SELECT 
            oi2.order_id
        FROM 
            order_items oi2
        JOIN 
            order_header oh2 ON oi2.order_id = oh2.order_id
        JOIN 
            online_customer oc2 ON oh2.customer_id = oc2.customer_id
        JOIN 
            address a2 ON oc2.address_id = a2.address_id
        WHERE 
            oi2.product_id = 201
            AND a2.city NOT IN ('Bangalore', 'New Delhi')
    )
GROUP BY 
    p.product_id, p.product_desc
ORDER BY 
    total_quantity DESC
LIMIT 5;



-- 10. WRITE A QUERY TO DISPLAY THE ORDER_ID,CUSTOMER_ID AND CUSTOMER FULLNAME AND TOTAL QUANTITY OF PRODUCTS SHIPPED FOR ORDER IDS 
-- WHICH ARE EVENAND SHIPPED TO ADDRESS WHERE PINCODE IS NOT STARTING WITH "5" 
	-- [NOTE: TABLES TO BE USED - ONLINE_CUSTOMER,ORDER_HEADER, ORDER_ITEMS, ADDRESS]
    
#Soln.-

SELECT 
    oh.order_id,
    oc.customer_id,
    CONCAT(oc.customer_fname, ' ', oc.customer_lname) AS customer_fullname,
    SUM(oi.product_quantity) AS total_quantity
FROM 
    order_header oh
JOIN 
    online_customer oc ON oh.customer_id = oc.customer_id
JOIN 
    address a ON oc.address_id = a.address_id
JOIN 
    order_items oi ON oh.order_id = oi.order_id
WHERE 
    oh.order_id % 2 = 0
    AND LEFT(a.pincode, 1) <> '5'
GROUP BY 
    oh.order_id, oc.customer_id, customer_fullname
ORDER BY 
    oh.order_id
LIMIT 5;
