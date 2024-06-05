--tìm sản phẩm theo tên--
SELECT * FROM PRODUCTS WHERE PRODUCT_NAME LIKE '%%%yon%%';

--tìm sản phẩm theo giá--
SELECT * FROM PRODUCTS WHERE UNIT_PRICE::numeric BETWEEN 1000000 AND 2000000;


--tra cứu đơn hàng theo tên khách hàng-- (cả shipper và khách hàng đều dùng được)
SELECT ORDERS.ORDER_ID, ORDERS.TIME, ORDERS.TOTAL_PRICE, ORDERS.ADDRESS, ORDERS.STATUS
FROM ORDERS 
JOIN CUSTOMERS ON ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID 
WHERE CUSTOMERS.FULL_NAME = 'Tên Khách Hàng';


--tra cứu tất cả sản phẩm theo tên brand nhập vào--
SELECT PRODUCTS.PRODUCT_NAME, PRODUCTS.UNIT_PRICE, products_brand.BRAND_NAME, PRODUCTS.DESCRIPTION
FROM PRODUCTS 
JOIN products_brand ON PRODUCTS.BRAND_ID = products_brand.BRAND_ID 
WHERE products_brand.BRAND_NAME = 'Yonex';

--tra cứu theo loại sản phẩm--
SELECT PRODUCTS.PRODUCT_NAME, PRODUCTS.UNIT_PRICE, PRODUCTS.AMOUNT, products_brand.BRAND_NAME, PRODUCTS.DESCRIPTION
FROM PRODUCTS 
JOIN products_brand ON PRODUCTS.BRAND_ID = products_brand.BRAND_ID
WHERE PRODUCTS.TYPE = 1;



--tra cứu thông tin khách hàng của 1 đơn hàng cụ thể--
SELECT CUSTOMERS.FULL_NAME, CUSTOMERS.PHONE, CUSTOMERS.ADDRESS
FROM ORDERS
JOIN CUSTOMERS ON ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID
WHERE ORDERS.ORDER_ID = 4;

--tạo 1 vouchers mới--
INSERT INTO VOUCHERS (NAME, DAY_START, DAY_OFF, PERCENT_OFF, AMOUNT, PRODUCT_ID)
VALUES ('Tên Voucher', '1/6/2024', '5/6/2024', '30', '100','267');
       
--tra cứu các voucher có thể sử dụng cho 1 đơn hàng cụ thể
SELECT v.name,v.percent_off,v.product_id
FROM LIST l 
JOIN VOUCHERS v ON l.product_id = v.product_id
WHERE l.order_id = 5

--tìm BEST-SELLER theo loại sản phẩm
SELECT p.product_name, SUM(quantity) AS total_quantity
FROM ORDERS o 
JOIN LIST l ON o.order_id = l.order_id
JOIN PRODUCTS p ON p.product_id = l.product_id
WHERE o.status = 3 AND p.type = 0 
GROUP BY p.product_id
ORDER BY total_quantity DESC
LIMIT 1;

--tìm khách hàng thân thiết tháng (số đơn hàng trong tháng nhiều hơn 3 lần)
SELECT c.customer_id, c.full_name
FROM CUSTOMERS c
JOIN ORDERS o ON c.customer_id = o.customer_id
WHERE o.time >= date_trunc('month', CURRENT_DATE)
  AND o.time < (date_trunc('month', CURRENT_DATE) + INTERVAL '1 MONTH')
  AND o.status = 3
GROUP BY c.customer_id, c.full_name
HAVING COUNT(o.order_id) > 3;


