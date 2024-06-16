--cau 1--
--hàm tìm sản phẩm theo tên--
CREATE OR REPLACE FUNCTION search_product(p_name VARCHAR)
RETURNS TABLE (
  PRODUCT_ID INT,
  PRODUCT_NAME VARCHAR(10000),
  UNIT_PRICE MONEY,
  AMOUNT INT,
  TYPE  INT,
  BRAND_NAME VARCHAR(30),
  DESCRIPTION VARCHAR(10000000)
) AS $$
BEGIN
  RETURN QUERY EXECUTE format('
    SELECT 
      PRODUCTS.PRODUCT_ID, 
      PRODUCTS.PRODUCT_NAME, 
      PRODUCTS.UNIT_PRICE, 
      PRODUCTS.AMOUNT, 
      PRODUCTS.TYPE, 
      PRODUCTS_BRAND.BRAND_NAME, 
      PRODUCTS.DESCRIPTION 
    FROM PRODUCTS 
    JOIN PRODUCTS_BRAND ON PRODUCTS.BRAND_ID = PRODUCTS_BRAND.BRAND_ID
    WHERE PRODUCTS.PRODUCT_NAME LIKE ''%%%s%%''', p_name);
END;
$$ LANGUAGE plpgsql;
--cau lenh tìm sản phẩm theo tên--
SELECT * FROM search_product('Yonex');


--cau 2--
--tìm sản phẩm theo giá--
SELECT * FROM PRODUCTS WHERE UNIT_PRICE BETWEEN 1000::MONEY AND 2000::MONEY;
--vi dụ tìm sản phẩm có giá từ 1000 đến 2000--


--cau 3--
--tra cứu đơn hàng theo tên khách hàng-- (cả shipper và khách hàng đều dùng được)
SELECT ORDERS.ORDER_ID, ORDERS.TIME, ORDERS.TOTAL_PRICE, ORDERS.ADDRESS, ORDERS.STATUS
FROM ORDERS 
JOIN CUSTOMERS ON ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID 
WHERE CUSTOMERS.FULL_NAME = 'Tên Khách Hàng';

--cau 4--
--tra cứu tất cả sản phẩm theo tên brand nhập vào--
DROP FUNCTION IF EXISTS select_product_brand;

CREATE OR REPLACE FUNCTION select_product_brand(p_brand_name VARCHAR)
RETURNS TABLE (
  PRODUCT_NAME VARCHAR(10000),
  amount INT,
  UNIT_PRICE MONEY,
  BRAND_NAME VARCHAR(30),
  DESCRIPTION VARCHAR(10000000)
) AS $$
BEGIN
  RETURN QUERY 
  SELECT PRODUCTS.PRODUCT_NAME,PRODUCTS.AMOUNT, PRODUCTS.UNIT_PRICE, products_brand.BRAND_NAME, PRODUCTS.DESCRIPTION
  FROM PRODUCTS 
  JOIN products_brand ON PRODUCTS.BRAND_ID = products_brand.BRAND_ID 
  WHERE products_brand.BRAND_NAME = p_brand_name;
END;
$$ LANGUAGE plpgsql;
--câu lệnh ví dụ--
SELECT * FROM select_product_brand('Yonex');



--cau 5--
--tra cứu theo loại sản phẩm--
CREATE OR REPLACE FUNCTION search_product_type(p_type INT)
RETURNS TABLE (
  PRODUCT_NAME VARCHAR(10000),
  UNIT_PRICE MONEY,
  AMOUNT INT,
  BRAND_NAME VARCHAR(30),
  DESCRIPTION VARCHAR(10000000)
) AS $$
BEGIN
  RETURN QUERY 
  SELECT PRODUCTS.PRODUCT_NAME, PRODUCTS.UNIT_PRICE, PRODUCTS.AMOUNT, products_brand.BRAND_NAME, PRODUCTS.DESCRIPTION
  FROM PRODUCTS 
  JOIN products_brand ON PRODUCTS.BRAND_ID = products_brand.BRAND_ID 
  WHERE PRODUCTS.TYPE = p_type;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM search_product_type(2);



--cau 6--
--tra cứu thông tin khách hàng của 1 đơn hàng cụ thể--
SELECT CUSTOMERS.FULL_NAME, CUSTOMERS.PHONE, ADDRESSES.ADDRESS, ADDRESSES.DISTRICT, CITIES.CITY_NAME
FROM ORDERS
JOIN CUSTOMERS ON ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID
JOIN ADDRESSES ON CUSTOMERS.ADDRESS_ID = ADDRESSES.ADDRESS_ID
JOIN CITIES ON ADDRESSES.CITY_ID = CITIES.CITY_ID
WHERE ORDERS.ORDER_ID = 26261616;



--cau 7--
--tra cứu thông tin sản phẩm của 1 đơn hàng cụ thể--
SELECT PRODUCTS.PRODUCT_NAME, PRODUCTS.UNIT_PRICE, LIST.QUANTITY, 
       (PRODUCTS.UNIT_PRICE * LIST.QUANTITY) AS TOTAL_PRICE
FROM LIST
JOIN PRODUCTS ON LIST.PRODUCT_ID = PRODUCTS.PRODUCT_ID
WHERE LIST.ORDER_ID = 24325232;

--cau 8--
--và tính ra tổng tiền của đơn hàng đó--
SELECT SUM(PRODUCTS.UNIT_PRICE * LIST.QUANTITY) AS ORDER_TOTAL
FROM LIST
JOIN PRODUCTS ON LIST.PRODUCT_ID = PRODUCTS.PRODUCT_ID
WHERE LIST.ORDER_ID = 24325232;


--cau 9--
--giá trị được giảm--
SELECT LIST.PRODUCT_ID, PRODUCTS.PRODUCT_NAME, 
       (VOUCHERS.PERCENT_OFF * PRODUCTS.UNIT_PRICE * LIST.QUANTITY / 100) AS DISCOUNT_AMOUNT
FROM LIST
JOIN PRODUCTS ON LIST.PRODUCT_ID = PRODUCTS.PRODUCT_ID
LEFT JOIN VOUCHERS ON PRODUCTS.PRODUCT_ID = VOUCHERS.PRODUCT_ID
WHERE LIST.ORDER_ID = 24325232 AND CURRENT_DATE BETWEEN VOUCHERS.DAY_START AND VOUCHERS.DAY_OFF;


--cau 10--
--tính tổng tiền cuối cùng của đơn hàng--
SELECT (SUM(CAST(PRODUCTS.UNIT_PRICE AS numeric) * LIST.QUANTITY) - 
        COALESCE(SUM(CAST(VOUCHERS.PERCENT_OFF AS numeric) * CAST(PRODUCTS.UNIT_PRICE AS numeric) * LIST.QUANTITY / 100), 0)) AS FINAL_TOTAL
FROM LIST
JOIN PRODUCTS ON LIST.PRODUCT_ID = PRODUCTS.PRODUCT_ID
LEFT JOIN VOUCHERS ON PRODUCTS.PRODUCT_ID = VOUCHERS.PRODUCT_ID AND CURRENT_DATE BETWEEN VOUCHERS.DAY_START AND VOUCHERS.DAY_OFF
WHERE LIST.ORDER_ID = 24325232;


--cau 11--
--duyệt các sản phẩm trong list đã sử dụng voucher và tự động -1 amount của voucher--
CREATE OR REPLACE FUNCTION decrease_voucher_amount() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM VOUCHERS WHERE PRODUCT_ID = NEW.PRODUCT_ID) THEN
    UPDATE VOUCHERS
    SET AMOUNT = AMOUNT - 1
    WHERE PRODUCT_ID = NEW.PRODUCT_ID;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER decrease_voucher_amount_after_order
AFTER INSERT ON LIST
FOR EACH ROW EXECUTE PROCEDURE decrease_voucher_amount();


--cau 12--
--tạo 1 khách hàng mới--   
CREATE OR REPLACE FUNCTION add_customer(
    p_full_name VARCHAR(40),
    p_phone VARCHAR(10),
    p_pass_word VARCHAR(9),
    p_email VARCHAR(100),
    p_address VARCHAR(50),
    p_district VARCHAR(30),
    p_city_id INT,
    p_postal_code VARCHAR(10)
) RETURNS VOID AS $$
DECLARE
    new_address_id INT;
BEGIN
    -- Thêm một địa chỉ mới
    INSERT INTO ADDRESSES (ADDRESS, DISTRICT, CITY_ID, POSTAL_CODE)
    VALUES (p_address, p_district, p_city_id, p_postal_code)
    RETURNING ADDRESS_ID INTO new_address_id;

    -- Thêm một khách hàng mới với ADDRESS_ID mới nhất
    INSERT INTO CUSTOMERS (FULL_NAME, PHONE, PASS_WORD, EMAIL, ADDRESS_ID)
    VALUES (p_full_name, p_phone, p_pass_word, p_email, new_address_id);
END;
$$ LANGUAGE plpgsql;

select * from add_customer('Nguyễn Văn A', '0123456789', 'password', 'maiojsnd@gmail.com', '123 Đường 1', 'Quận 1', 1, '700000');


--cau13--
--xóa 1 khách hàng theo id--
CREATE OR REPLACE FUNCTION delete_customer(
    p_customer_id INT
) RETURNS VOID AS $$
BEGIN
    -- Xóa tất cả các mục trong danh sách đơn hàng liên quan đến khách hàng
    DELETE FROM LIST WHERE ORDER_ID IN (SELECT ORDER_ID FROM ORDERS WHERE CUSTOMER_ID = p_customer_id);

    -- Xóa tất cả đơn hàng của khách hàng
    DELETE FROM ORDERS WHERE CUSTOMER_ID = p_customer_id;

    -- Xóa khách hàng
    DELETE FROM CUSTOMERS WHERE CUSTOMER_ID = p_customer_id;

    -- Xóa địa chỉ của khách hàng
    DELETE FROM ADDRESSES WHERE ADDRESS_ID NOT IN (SELECT ADDRESS_ID FROM CUSTOMERS);
END;
$$ LANGUAGE plpgsql;

select * from  delete_customer(15);


--cau 14--
--tạo 1 vouchers mới--
CREATE OR REPLACE FUNCTION insert_voucher(
    p_name VARCHAR,
    p_day_start DATE,
    p_day_off DATE,
    p_percent_off INT,
    p_amount INT,
    p_product_id INT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO VOUCHERS (NAME, DAY_START, DAY_OFF, PERCENT_OFF, AMOUNT, PRODUCT_ID)
    VALUES (p_name, p_day_start, p_day_off, p_percent_off, p_amount, p_product_id);
END;
$$ LANGUAGE plpgsql;

SELECT insert_voucher('Tên Voucher', '2024-06-01', '2024-06-05', 30, 100, 17);

--cau15--
--tra cứu các voucher có thể sử dụng cho 1 đơn hàng cụ thể
SELECT v.name,v.percent_off,v.product_id
FROM LIST l 
JOIN VOUCHERS v ON l.product_id = v.product_id
WHERE l.order_id = 5

--cau16--
--tìm BEST-SELLER theo loại sản phẩm
SELECT p.product_name, SUM(quantity) AS total_quantity
FROM ORDERS o 
JOIN LIST l ON o.order_id = l.order_id
JOIN PRODUCTS p ON p.product_id = l.product_id
WHERE o.status = 3 AND p.type = 0                   -- trạng thái 3 nghĩa là đã giao hàng thành công/ type = 0 là loại sản phẩm--
GROUP BY p.product_id
ORDER BY total_quantity DESC
LIMIT 10;


--cau17--
--tìm khách hàng thân thiết tháng (số đơn hàng trong tháng nhiều hơn 3 lần)
SELECT c.customer_id, c.full_name, c.phone, c.email, a.address, a.district, ci.city_name, a.postal_code
FROM CUSTOMERS c
JOIN ORDERS o ON c.customer_id = o.customer_id
JOIN ADDRESSES a ON o.address = a.address
JOIN CITIES ci ON a.city_id = ci.city_id
WHERE o.time >= date_trunc('month', CURRENT_DATE)
  AND o.time < (date_trunc('month', CURRENT_DATE) + INTERVAL '1 MONTH')
  AND o.status = 3
GROUP BY c.customer_id, c.full_name, c.phone, c.email, a.address, a.district, ci.city_name, a.postal_code
HAVING COUNT(o.order_id) > 3;

--cau18--
--Tìm khách hàng chi nhiều tiền nhất trong thời gian cụ thể, trông khu vực cụ thể( tri ân)--
SELECT c.customer_id, c.full_name, c.phone, a.address, a.district, ci.city_name, a.postal_code, SUM(o.total_price) AS total_price
FROM CUSTOMERS c
JOIN ORDERS o ON c.customer_id = o.customer_id
JOIN ADDRESSES a ON o.address = a.address
JOIN CITIES ci ON a.city_id = ci.city_id
WHERE o.time >= date_trunc('month', CURRENT_DATE - INTERVAL '1 MONTH')
  AND o.time < date_trunc('month', CURRENT_DATE)
  AND o.status = 3
GROUP BY c.customer_id, c.full_name, c.phone, a.address, a.district, ci.city_name, a.postal_code
ORDER BY total_price DESC
LIMIT 3;


--cau20--
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
  




--đặt hàng 1 sản phẩm--
INSERT INTO ORDERS (PRODUCT_ID, QUANTITY, CUSTOMER_ID)
VALUES 
  (1, 2, 123), -- Sản phẩm 1 với số lượng 2 cho khách hàng 123
  (2, 1, 123), -- Sản phẩm 2 với số lượng 1 cho khách hàng 123
  (3, 5, 123); -- Sản phẩm 3 với số lượng 5 cho khách hàng 123


--Tìm shippers có tổng số đơn giao hoàn thành trong mỗi tháng(khen thưởng)--
--Lấy danh sách của sản phẩm mà số lượng tồn kho nhiều hơn, ít hơn 10 ,...--
--Tính tổng số sản phẩm còn tồn kho, giá trị tồn kho theo từng loại--
--Lấy thông tin danh sách voucher mà khách hàng đã sử dụng--
--Top 10 voucher được sư dụng nhiều nhất--
--Tính tổng gía trị các voucher giảm giá trong chương trình--