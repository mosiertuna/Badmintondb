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


--cau 2--tick
--tìm sản phẩm theo giá--
SELECT * FROM PRODUCTS WHERE UNIT_PRICE BETWEEN '1000' AND '20000';



--cau 3--tick
--tra cứu đơn hàng theo tên khách hàng-- (cả shipper và khách hàng đều dùng được)
SELECT ORDERS.ORDER_ID, ORDERS.TIME, ORDERS.TOTAL_PRICE, ORDERS.ADDRESS, ORDERS.STATUS
FROM ORDERS 
JOIN CUSTOMERS ON ORDERS.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID 
WHERE CUSTOMERS.FULL_NAME = 'Tên Khách Hàng';

--cau 4--tick
--tra cứu tất cả sản phẩm theo tên brand nhập vào--
SELECT PRODUCTS.PRODUCT_NAME, PRODUCTS.UNIT_PRICE, products_brand.BRAND_NAME, PRODUCTS.DESCRIPTION
FROM PRODUCTS 
JOIN products_brand ON PRODUCTS.BRAND_ID = products_brand.BRAND_ID 
WHERE products_brand.BRAND_NAME = 'Yonex';

--4.2--
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
WHERE LIST.ORDER_ID = 200;

--cau 7.2--tick
CREATE OR REPLACE FUNCTION get_product_info_by_order(p_order_id INT)
RETURNS TABLE (
  product_name VARCHAR,
  unit_price MONEY,
  quantity INT,
  total_price MONEY
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    PRODUCTS.PRODUCT_NAME,
    PRODUCTS.UNIT_PRICE,
    LIST.QUANTITY,
    (PRODUCTS.UNIT_PRICE * LIST.QUANTITY) AS total_price
  FROM LIST
  JOIN PRODUCTS ON LIST.PRODUCT_ID = PRODUCTS.PRODUCT_ID
  WHERE LIST.ORDER_ID = p_order_id;
END;
$$ LANGUAGE plpgsql;

-- Execute the function
SELECT * FROM get_product_info_by_order(200);

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
CREATE OR REPLACE FUNCTION delete_voucher_amount() RETURNS TRIGGER AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM VOUCHERS WHERE PRODUCT_ID = NEW.PRODUCT_ID) THEN
    UPDATE VOUCHERS
    SET AMOUNT = AMOUNT - 1
    WHERE PRODUCT_ID = NEW.PRODUCT_ID;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER delete_voucher
AFTER INSERT ON LIST
FOR EACH ROW EXECUTE PROCEDURE delete_voucher_amount();


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

SELECT add_customer('Nguyễn Văn A', '0123456789', 'password', 'maiojsnd@gmail.com', '123 Đường 1', 'Quận 1', 1, '700000');

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
SELECT  v.product_id,v.name, v.percent_off, p.unit_price
FROM LIST l 
JOIN VOUCHERS v ON l.product_id = v.product_id
JOIN PRODUCTS p ON l.product_id = p.product_id
WHERE l.order_id = 1;

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



--cau21--
--Tìm nhãn hàng cung cấp nhiều sản phẩm nhất trong thời gian cụ thể--
SELECT c.customer_id AS brand_name, COUNT(o.order_id) AS total_product
FROM ORDERS o
JOIN CUSTOMERS c ON o.customer_id = c.customer_id
WHERE o.time >= '2024-06-01' AND o.time < '2024-07-01'
GROUP BY c.customer_id
ORDER BY total_product DESC
LIMIT 1;




--cau22--
--Tìm sản phẩm được yêu thích nhất trong thời gian cụ thể, trong nhãn hàng cụ thể, trong từng loại sản phẩm--
SELECT p.product_name, SUM(l.quantity) AS total_quantity
FROM LIST l
JOIN PRODUCTS p ON l.product_id = p.product_id
JOIN PRODUCTS_BRAND pb ON p.brand_id = pb.brand_id
JOIN ORDERS o ON l.order_id = o.order_id
WHERE o.time >= '2024-06-01' AND o.time < '2024-06-30'
  AND pb.brand_name = 'Yonex'
  AND p.type = 0
GROUP BY p.product_id
ORDER BY total_quantity DESC
LIMIT 1;

--cau23--
--Tính tổng doanh thu trong khoảng thời gian cụ thể--
SELECT SUM(total_price) AS total_revenue
FROM ORDERS
WHERE time >= '2024-06-01' AND time < '2024-06-30';


--cau24--
--Tính tổng số đơn giao thành công trong thời gian cụ thể--
SELECT COUNT(order_id) AS total_order
FROM ORDERS
WHERE status = 3
AND time >= '2024-06-01' AND time < '2024-06-30';
  



--cau25--
--đặt hàng 1 sản phẩm--
CREATE OR REPLACE FUNCTION place_order(_customer_id INT, _status INT, _products INT[], _quantities INT[])
RETURNS VOID AS $$
DECLARE 
  _order_id INT;
  _i INT;
BEGIN
  -- Insert a new order into the ORDERS table
  INSERT INTO ORDERS(TIME, TOTAL_PRICE, STATUS, CUSTOMER_ID)
  VALUES (CURRENT_DATE, 0, _status, _customer_id)
  RETURNING ORDER_ID INTO _order_id;

  -- Loop through the products array and insert a new line item into the LIST table for each product in the order
  FOR _i IN array_lower(_products, 1) .. array_upper(_products, 1)
  LOOP
    INSERT INTO LIST(QUANTITY, PRODUCT_ID, ORDER_ID)
    VALUES (_quantities[_i], _products[_i], _order_id);
  END LOOP;
  
  -- Update the total price in the ORDERS table
  UPDATE ORDERS
  SET TOTAL_PRICE = (SELECT SUM(QUANTITY * UNIT_PRICE) FROM LIST JOIN PRODUCTS ON LIST.PRODUCT_ID = PRODUCTS.PRODUCT_ID WHERE ORDER_ID = _order_id)
  WHERE ORDER_ID = _order_id;

END;
$$ LANGUAGE plpgsql;
SELECT place_order(_customer_id := 1, _status := 0, _products := ARRAY[1, 2, 3], _quantities := ARRAY[10, 20, 30]);




--cau26--
--trigger tự cập nhật trạng thái của đơn hàng--
CREATE OR REPLACE FUNCTION update_order_status_orders()
RETURNS TRIGGER AS $$
BEGIN
  -- If the order has a shipper_id, set the order status to 2
  IF NEW.SHIPPER_ID IS NOT NULL THEN
    NEW.STATUS := 2;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER order_status_update
BEFORE INSERT OR UPDATE ON ORDERS
FOR EACH ROW
EXECUTE FUNCTION update_order_status_orders();

--cau27--
--Tìm shippers có tổng số đơn giao hoàn thành trong mỗi tháng(khen thưởng)--
SELECT SHIPPERS.SHIPPER_ID, SHIPPERS.FULL_NAME, COUNT(*)
FROM ORDERS
JOIN SHIPPERS ON ORDERS.SHIPPER_ID = SHIPPERS.SHIPPER_ID
WHERE EXTRACT(MONTH FROM ORDERS.TIME) = 4
  AND EXTRACT(YEAR FROM ORDERS.TIME) = 2022 
  AND ORDERS.STATUS = 3
GROUP BY SHIPPERS.SHIPPER_ID, SHIPPERS.FULL_NAME;



--cau28--
--Lấy danh sách của sản phẩm mà số lượng tồn kho nhiều hơn, ít hơn 10 ,...--
SELECT PRODUCT_NAME, AMOUNT
FROM PRODUCTS
ORDER BY AMOUNT DESC
LIMIT 10;

SELECT PRODUCT_NAME, AMOUNT
FROM PRODUCTS
ORDER BY AMOUNT asc
LIMIT 10;

--cau29-- 
--viet trigger tự cập nhập số lượng sản phẩm còn lại trong bảng customer sau khi khách hàng đặt hàng--
CREATE OR REPLACE FUNCTION update_product_amount() RETURNS TRIGGER AS $$
BEGIN
  UPDATE PRODUCTS
  SET AMOUNT = AMOUNT - NEW.QUANTITY
  WHERE PRODUCT_ID = NEW.PRODUCT_ID;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_amount_after_order
AFTER INSERT ON LIST
FOR EACH ROW
EXECUTE FUNCTION update_product_amount();

--cau30--
--viết trigger tự cập nhật total_price sau khi khách hàng đặt hàng--
--total_price = quantity * unit_price - discount_amount( được lấy từ voucher cho từng sản phẩm trong list)--
CREATE OR REPLACE FUNCTION update_total_price() RETURNS TRIGGER AS $$
BEGIN
  DECLARE
    final_total MONEY;
  BEGIN
    SELECT (SUM(CAST(PRODUCTS.UNIT_PRICE AS numeric) * NEW.QUANTITY) - 
            COALESCE(SUM(CAST(VOUCHERS.PERCENT_OFF AS numeric) * CAST(PRODUCTS.UNIT_PRICE AS numeric) * NEW.QUANTITY / 100), 0)) 
    INTO final_total
    FROM PRODUCTS
    LEFT JOIN VOUCHERS ON PRODUCTS.PRODUCT_ID = VOUCHERS.PRODUCT_ID AND CURRENT_DATE BETWEEN VOUCHERS.DAY_START AND VOUCHERS.DAY_OFF
    WHERE PRODUCTS.PRODUCT_ID = NEW.PRODUCT_ID;

    UPDATE ORDERS
    SET TOTAL_PRICE = TOTAL_PRICE + final_total
    WHERE ORDER_ID = NEW.ORDER_ID;

    RETURN NEW;
  END;
END; $$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER update_total_after_insert
AFTER INSERT ON LIST
FOR EACH ROW
EXECUTE FUNCTION update_total_price();


--Tính tổng số sản phẩm còn tồn kho, giá trị tồn kho theo từng loại--
--Lấy thông tin danh sách voucher mà khách hàng đã sử dụng--
--Top 10 voucher được sư dụng nhiều nhất--
--Tính tổng gía trị các voucher giảm giá trong chương trình--

--Tìm khách hàng mua nhiều sản phẩm nhất trong thành phố cụ thể--
CREATE OR REPLACE FUNCTION get_top_customer_by_city(p_city_name VARCHAR)
RETURNS TABLE (
  customer_id INT,
  full_name VARCHAR,
  phone VARCHAR,
  email VARCHAR,
  total_orders BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.customer_id,
    c.full_name,
    c.phone,
    c.email,
    COUNT(o.order_id) AS total_orders
  FROM 
    CUSTOMERS c
  JOIN 
    ORDERS o ON c.customer_id = o.customer_id
  JOIN 
    ADDRESSES a ON o.address = a.address
  JOIN 
    CITIES ci ON a.city_id = ci.city_id
  WHERE 
    ci.city_name = p_city_name
    AND o.status = 3
  GROUP BY 
    c.customer_id, c.full_name, c.phone, c.email
  ORDER BY 
    total_orders DESC;
END;
$$ LANGUAGE plpgsql;

--top 10 khách hàng mua nhiều nhất trong ngày--
CREATE OR REPLACE FUNCTION get_top_customers_by_day(day_val DATE)
RETURNS TABLE (
  customer_id INT,
  full_name VARCHAR,
  phone VARCHAR,
  email VARCHAR,
  address VARCHAR,
  district VARCHAR,
  city_name VARCHAR,
  postal_code VARCHAR,
  order_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.customer_id,
    c.full_name,
    c.phone,
    c.email,
    a.address,
    a.district,
    ci.city_name,
    a.postal_code,
    COUNT(o.order_id) AS order_count
  FROM 
    CUSTOMERS c
  JOIN 
    ORDERS o ON c.customer_id = o.customer_id
  JOIN 
    ADDRESSES a ON o.address = a.address
  JOIN 
    CITIES ci ON a.city_id = ci.city_id
  WHERE 
    o.time >= day_val
    AND o.time < day_val + INTERVAL '1 DAY'
    AND o.status = 3
  GROUP BY 
    c.customer_id, c.full_name, c.phone, c.email, a.address, a.district, ci.city_name, a.postal_code
  ORDER BY 
    order_count DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql;

 --top 10 khách hàng mua nhiều nhất trong năm--
CREATE OR REPLACE FUNCTION get_top_customers_by_year(year_val INT)
RETURNS TABLE (
  customer_id INT,
  full_name VARCHAR,
  phone VARCHAR,
  email VARCHAR,
  address VARCHAR,
  district VARCHAR,
  city_name VARCHAR,
  postal_code VARCHAR,
  order_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.customer_id,
    c.full_name,
    c.phone,
    c.email,
    a.address,
    a.district,
    ci.city_name,
    a.postal_code,
    COUNT(o.order_id) AS order_count
  FROM 
    CUSTOMERS c
  JOIN 
    ORDERS o ON c.customer_id = o.customer_id
  JOIN 
    ADDRESSES a ON o.address = a.address
  JOIN 
    CITIES ci ON a.city_id = ci.city_id
  WHERE 
    EXTRACT(YEAR FROM o.time) = year_val
    AND o.status = 3
  GROUP BY 
    c.customer_id, c.full_name, c.phone, c.email, a.address, a.district, ci.city_name, a.postal_code
  ORDER BY 
    order_count DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql;

--Tìm top 10 khách hàng mua  nhiều nhất trong tháng, năm cụ thể--
CREATE OR REPLACE FUNCTION get_top_customers_by_month_year(month_val INT, year_val INT)
RETURNS TABLE (
  customer_id INT,
  full_name VARCHAR,
  phone VARCHAR,
  email VARCHAR,
  address VARCHAR,
  district VARCHAR,
  city_name VARCHAR,
  postal_code VARCHAR,
  order_count BIGINT 
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    c.customer_id,
    c.full_name,
    c.phone,
    c.email,
    a.address,
    a.district,
    ci.city_name,
    a.postal_code,
    COUNT(o.order_id) AS order_count
  FROM 
    CUSTOMERS c
  JOIN 
    ORDERS o ON c.customer_id = o.customer_id
  JOIN 
    ADDRESSES a ON o.address = a.address
  JOIN 
    CITIES ci ON a.city_id = ci.city_id
  WHERE 
    EXTRACT(MONTH FROM o.time) = month_val
    AND EXTRACT(YEAR FROM o.time) = year_val
    AND o.status = 3
  GROUP BY 
    c.customer_id, c.full_name, c.phone, c.email, a.address, a.district, ci.city_name, a.postal_code
  ORDER BY 
    order_count DESC
  LIMIT 10;
END;
$$ LANGUAGE plpgsql;

--Tính số tổng số lần mua hàng của mỗi khách hàng--
CREATE OR REPLACE FUNCTION get_order_count_per_customer()
RETURNS TABLE (
  customer_id INT,
  full_name VARCHAR,
  order_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    C.CUSTOMER_ID,
    C.FULL_NAME,
    COUNT(O.ORDER_ID) AS order_count
  FROM 
    CUSTOMERS C
  LEFT JOIN 
    ORDERS O ON C.CUSTOMER_ID = O.CUSTOMER_ID
  GROUP BY 
    C.CUSTOMER_ID, C.FULL_NAME
  ORDER BY 
    order_count DESC;
END;
$$ LANGUAGE plpgsql;

-- Execute the function
SELECT * FROM get_order_count_per_customer();

--Hiển thị thông tin sản phẩm có số lượng tồn kho trong khoảng mong muốn--
CREATE OR REPLACE FUNCTION get_products_by_amount_range(min_amount INT, max_amount INT)
RETURNS TABLE (
  product_id INT,
  product_name VARCHAR,
  unit_price MONEY,
  amount INT,
  type INT,
  brand_id INT,
  description VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    PRODUCTS.PRODUCT_ID,
    PRODUCTS.PRODUCT_NAME,
    PRODUCTS.UNIT_PRICE,
    PRODUCTS.AMOUNT,
    PRODUCTS.TYPE,
    PRODUCTS.BRAND_ID,
    PRODUCTS.DESCRIPTION
  FROM PRODUCTS
  WHERE PRODUCTS.AMOUNT BETWEEN min_amount AND max_amount;
END;
$$ LANGUAGE plpgsql;

-- Execute the function
SELECT * FROM get_products_by_amount_range(10, 50);

--Sắp xếp các nhãn hàng có số lượng tồn kho giảm dần ( hoặc tăng dần)-- 
CREATE OR REPLACE FUNCTION get_sorted_brand_inventory()
RETURNS TABLE (
  brand_id INT,
  brand_name VARCHAR,
  total_amount BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pb.BRAND_ID,
    pb.BRAND_NAME,
    SUM(p.AMOUNT) AS total_amount
  FROM 
    PRODUCTS p
  JOIN 
    PRODUCTS_BRAND pb ON p.BRAND_ID = pb.BRAND_ID
  GROUP BY 
    pb.BRAND_ID, pb.BRAND_NAME
  ORDER BY 
    total_amount DESC;
END;
$$ LANGUAGE plpgsql;

-- Execute the function
SELECT * FROM get_sorted_brand_inventory();