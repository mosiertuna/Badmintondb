--tìm sản phẩm theo tên--
DO
$$
DECLARE ProductName VARCHAR(10000);
BEGIN
  ProductName := 'Tên sản phẩm cần tìm';
  EXECUTE format('SELECT * FROM PRODUCTS WHERE NAME LIKE ''%%%s%%''', ProductName);
END
$$

--tìm sản phẩm theo giá--
SELECT * FROM PRODUCTS WHERE PRICE BETWEEN 1000000 AND 2000000;

--đặt hàng 1 sản phẩm--
INSERT INTO ORDERS (PRODUCT_ID, QUANTITY, CUSTOMER_ID)
VALUES 
  (1, 2, 123), -- Sản phẩm 1 với số lượng 2 cho khách hàng 123
  (2, 1, 123), -- Sản phẩm 2 với số lượng 1 cho khách hàng 123
  (3, 5, 123); -- Sản phẩm 3 với số lượng 5 cho khách hàng 123


--tra cứu đơn hàng theo tên khách hàng-- (cả shipper và khách hàng đều dùng được)
SELECT ORDERS.ORDER_ID, ORDERS.TIME, ORDERS.TOTAL_PRICE, ORDERS.ADDRESS, ORDERS.STATUS
FROM ORDERS 
JOIN CUSTOMERS ON ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID 
WHERE CUSTOMERS.FULL_NAME = 'Tên Khách Hàng';


--tra cứu tất cả sản phẩm theo tên brand nhập vào--
SELECT PRODUCTS.NAME, PRODUCTS.UNIT_PRICE, products_brand.BRAND_NAME, PRODUCTS.DESCRIPTION
FROM PRODUCTS 
JOIN products_brand ON PRODUCTS.BRAND_ID = products_brand.BRAND_ID 
WHERE products_brand.BRAND_NAME = 'Yonex';

--tra cứu theo loại sản phẩm--
SELECT PRODUCTS.NAME, PRODUCTS.UNIT_PRICE, PRODUCTS.AMOUNT, products_brand.BRAND_NAME, PRODUCTS.DESCRIPTION
FROM PRODUCTS 
JOIN products_brand ON PRODUCTS.BRAND_ID = products_brand.BRAND_ID
WHERE PRODUCTS.TYPE = 1;


--tra cứu thông tin khách hàng của 1 đơn hàng cụ thể--
SELECT CUSTOMERS.FULL_NAME, CUSTOMERS.PHONE, CUSTOMERS.ADDRESS
FROM ORDERS
JOIN CUSTOMERS ON ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID
WHERE ORDERS.ORDER_ID = '26261616';

--tạo 1 khách hàng mới--   
INSERT INTO CUSTOMERS (FULL_NAME, PHONE, EMAIL, ADDRESS)
VALUES ('Tên Khách Hàng', '020161', 'Email', 'Địa Chỉ');

--tạo 1 vouchers mới--
INSERT INTO VOUCHERS (NAME, DAY_START, DAY_OFF, PERCENT_OFF, AMOUNT, PRODUCT_ID)
VALUES ('Tên Voucher', '1/6/2024', '5/6/2024', '30', '100','267');
