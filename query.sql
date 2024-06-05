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


--Tìm khách hàng chi nhiều tiền nhất trong thời gian cụ thể, trông khu vực cụ thể( tri ân)--
SELECT c.customer_id, c.full_name, c.phone, c.address, SUM(o.total_price) AS total_price
FROM CUSTOMERS c
JOIN ORDERS o ON c.customer_id = o.customer_id
WHERE o.time >= '2024-06-01' AND o.time < '2024-06-30'
  AND c.address = 'Khu Vực'
GROUP BY c.customer_id, c.full_name, c.phone, c.address
ORDER BY total_price DESC
LIMIT 1;

--Tính tổng tiền của một khách hàng--
SELECT SUM(total_price) AS total_price
FROM ORDERS
WHERE customer_id = 1;

--Tìm nhãn hàng cung cấp nhiều sản phẩm nhất trong thời gian cụ thể--
SELECT pb.brand_name, COUNT(p.product_id) AS total_product
FROM PRODUCTS p
JOIN PRODUCTS_BRAND pb ON p.brand_id = pb.brand_id
WHERE p.time >= '2024-06-01' AND p.time < '2024-06-30'
GROUP BY pb.brand_name
ORDER BY total_product DESC
LIMIT 1;




--Tìm sản phẩm được yêu thích nhất trong thời gian cụ thể, trong nhãn hàng cụ thể, trong từng loại sản phẩm--
SELECT p.product_name, SUM(l.quantity) AS total_quantity
FROM LIST l
JOIN PRODUCTS p ON l.product_id = p.product_id
JOIN PRODUCTS_BRAND pb ON p.brand_id = pb.brand_id
WHERE l.time >= '2024-06-01' AND l.time < '2024-06-30'
  AND pb.brand_name = 'Yonex'
  AND p.type = 0
GROUP BY p.product_id
ORDER BY total_quantity DESC
LIMIT 1;




--Tính tổng doanh thu trong khoảng thời gian cụ thể--
SELECT SUM(total_price) AS total_revenue
FROM ORDERS
WHERE time >= '2024-06-01' AND time < '2024-06-30';




--Lấy danh sách nhân viên theo chức vụ--
SELECT e.employee_id, e.full_name, e.phone, e.email, e.address, e.position
FROM EMPLOYEES e
WHERE e.position = 'Shipper';




--Tính tổng số đơn giao thành công trong thời gian cụ thể--
SELECT COUNT(order_id) AS total_order
FROM ORDERS
WHERE status = 3
  AND time >= '2024-06-01' AND time < '2024-06-30';
  



--Tìm shippers có tổng số đơn giao hoàn thành trong mỗi tháng(khen thưởng)--
--Lấy danh sách của sản phẩm mà số lượng tồn kho nhiều hơn, ít hơn 10 ,...--
--Tính tổng số sản phẩm còn tồn kho, giá trị tồn kho theo từng loại--
--Lấy thông tin danh sách voucher mà khách hàng đã sử dụng--
--Top 10 voucher được sư dụng nhiều nhất--
--Tính tổng gía trị các voucher giảm giá trong chương trình--