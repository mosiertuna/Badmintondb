CREATE TABLE SHIPPERS
(
  SHIPPER_ID SERIAL PRIMARY KEY,
  FULL_NAME VARCHAR(30) NOT NULL,
  PHONE_NUMBER VARCHAR(10) NOT NULL,
  STATUS INT NOT NULL,
  EMAIL VARCHAR(50) NOT NULL,
  CHECK(STATUS >= 0 AND STATUS <= 3)
);




CREATE TABLE CITIES
(
  CITY_ID SERIAL PRIMARY KEY,
  CITY_NAME VARCHAR(30) NOT NULL
);

CREATE TABLE ADDRESSES
(
  ADDRESS_ID SERIAL PRIMARY KEY,
  ADDRESS VARCHAR(50) NOT NULL,
  DISTRICT VARCHAR(30) NOT NULL,
  CITY_ID INT,
  FOREIGN KEY (CITY_ID) REFERENCES CITIES(CITY_ID),
  POSTAL_CODE VARCHAR(10) NOT NULL
);

CREATE TABLE CUSTOMERS
(
  CUSTOMER_ID SERIAL PRIMARY KEY,
  FULL_NAME VARCHAR(40) ,
  PHONE VARCHAR(10) ,
  EMAIL VARCHAR(100) ,
  ADDRESS_ID INT,
  FOREIGN KEY (ADDRESS_ID) REFERENCES ADDRESSES(ADDRESS_ID)
);

CREATE TABLE PRODUCTS
(
  PRODUCT_ID SERIAL PRIMARY KEY,
  PRODUCT_NAME VARCHAR(10000) NOT NULL,
  UNIT_PRICE MONEY NOT NULL,
  AMOUNT INT NOT NULL,
  TYPE INT NOT NULL,
  BRAND_ID INT NOT NULL,
  DESCRIPTION VARCHAR(10000000) NOT NULL,
  CHECK(AMOUNT >= 0 AND TYPE >= 0 AND TYPE <= 5)
);

CREATE TABLE VOUCHERS
(
  VOUCHER_ID SERIAL PRIMARY KEY,
  NAME VARCHAR(30) NOT NULL,
  DAY_START DATE NOT NULL,
  DAY_OFF DATE NOT NULL,
  PERCENT_OFF INT NOT NULL,
  AMOUNT INT NOT NULL,
  PRODUCT_ID INT NOT NULL,
  FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID),
  CHECK(PERCENT_OFF <= 70 AND PERCENT_OFF >= 10 AND AMOUNT >= 0)
);

CREATE TABLE ORDERS
(
  ORDER_ID SERIAL PRIMARY KEY,
  TIME DATE,
  TOTAL_PRICE MONEY,
  ADDRESS VARCHAR(50),
  STATUS INT NOT NULL,
  CUSTOMER_ID INT, 
  SHIPPER_ID INT,
  FOREIGN KEY (CUSTOMER_ID) REFERENCES CUSTOMERS(CUSTOMER_ID),
  FOREIGN KEY (SHIPPER_ID) REFERENCES SHIPPERS(SHIPPER_ID),
  CHECK( STATUS >= 0 AND STATUS <= 3)
);

CREATE TABLE LIST
(
  QUANTITY INT NOT NULL,
  PRODUCT_ID INT NOT NULL,
  ORDER_ID INT NOT NULL,
  FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID),
  FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID),
  CHECK(QUANTITY >= 0)
);

CREATE TABLE DISCOUNT
(
  ORDER_ID INT NOT NULL,
  VOUCHER_ID INT NOT NULL,
  PRIMARY KEY (ORDER_ID, VOUCHER_ID),
  FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID),
  FOREIGN KEY (VOUCHER_ID) REFERENCES VOUCHERS(VOUCHER_ID)
);

CREATE TABLE PRODUCTS_BRAND
(
  BRAND_ID SERIAL PRIMARY KEY,
  BRAND_NAME VARCHAR(30) NOT NULL
);

CREATE TABLE customer_vouchers (
    customer_id INT NOT NULL,
    voucher_id INT NOT NULL,
    PRIMARY KEY (customer_id, voucher_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (voucher_id) REFERENCES vouchers(voucher_id),
    issue_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO PRODUCTS_BRAND (BRAND_NAME)
VALUES
  ('Yonex'),
  ('Victor'),
  ('Lining'),
  ('Mizuno'),
  ('Apacs'),
  ('VNB'),
  ('Proace'),
  ('Kumpoo'),
  ('Kawasaki'),
  ('Adidas');

-- Tạo dữ liệu mẫu cho bảng PRODUCTS
INSERT INTO PRODUCTS (PRODUCT_NAME, UNIT_PRICE, AMOUNT, TYPE, BRAND_ID, DESCRIPTION)
VALUES
  -- Vợt Cầu Lông 
  ('Vợt Cầu Lông Yonex Astrox 88D', 3500.00, 20, 0, 10, 'Vợt cầu lông cao cấp, chất lượng tốt, phù hợp cho người chơi trình độ cao.'),
  ('Vợt Cầu Lông Victor Brave Sword 12', 2800.00, 15, 0, 8, 'Vợt cầu lông với thiết kế hiện đại, độ ổn định và kiểm soát tốt.'),
  ('Vợt Cầu Lông Lining Windstorm X90', 3000.00, 18, 0, 5, 'Vợt cầu lông với công nghệ hiện đại, tăng khả năng tấn công và phòng ngự.'),
  ('Vợt Cầu Lông Mizuno Fortius 900', 2500.00, 22, 0, 6, 'Vợt cầu lông với trọng lượng vừa phải, tạo cảm giác thoải mái khi cầm nắm.'),
  ('Vợt Cầu Lông Apacs Virtuoso 99', 2200.00, 25, 0, 2, 'Vợt cầu lông với khung đan chắc chắn, giúp tăng lực bật bóng.'),

  -- Giày Cầu Lông
  ('Giày Cầu Lông Yonex SHB-65Z2M', 1800.00, 30, 1, 10, 'Giày cầu lông chất lượng, êm chân, độ bám tốt, phù hợp cho người chơi cầu lông.'),
  ('Giày Cầu Lông Victor SH-A960', 1600.00, 28, 1, 8, 'Giày cầu lông với thiết kế thoáng khí, hỗ trợ di chuyển linh hoạt.'),
  ('Giày Cầu Lông Lining AYTJ005-4', 1700.00, 32, 1, 5, 'Giày cầu lông với đế cao su chống trượt, tăng độ bám sân.'),
  ('Giày Cầu Lông Mizuno Wave Exceed Tour 4 CC', 1900.00, 26, 1, 6, 'Giày cầu lông với thiết kế nhẹ và thoáng, giúp người chơi thoải mái.'),
  ('Giày Cầu Lông Apacs Jetspeed X2', 1500.00, 35, 1, 2, 'Giày cầu lông với công nghệ đế giúp tăng độ bám và ổn định khi di chuyển.'),

  -- Quần Áo Cầu Lông
  ('Áo Cầu Lông Yonex 10283EX', 500.00, 40, 2, 10, 'Áo cầu lông chất liệu thoáng mát, co giãn tốt, tạo cảm giác thoải mái khi chơi.'),
  ('Quần Cầu Lông Victor R-09000', 450.00, 38, 2, 8, 'Quần cầu lông với thiết kế thoáng khí, giúp người chơi di chuyển dễ dàng.'),
  ('Áo Quần Cầu Lông Lining AAYM013-1', 600.00, 42, 2, 5, 'Bộ quần áo chơi cầu lông, chất liệu co giãn, thoáng mát.'),
  ('Áo Cầu Lông Mizuno 73CL8A0109', 550.00, 36, 2, 6, 'Áo cầu lông thiết kế thoáng khí, giúp người chơi luôn cảm thấy thoải mái.'),
  ('Quần Cầu Lông Apacs AP-301', 480.00, 44, 2, 2, 'Quần cầu lông với chất liệu co giãn, phù hợp cho mọi hoạt động.');

-- Tạo dữ liệu mẫu cho bảng PRODUCTS
INSERT INTO PRODUCTS (PRODUCT_NAME, UNIT_PRICE, AMOUNT, TYPE, BRAND_ID, DESCRIPTION)
VALUES
  -- Vợt Cầu Lông (tiếp tục)
  ('Vợt Cầu Lông VNB Supreme 1000', 2900.00, 17, 0, 9, 'Vợt cầu lông với thiết kế đẹp mắt, độ bền và hiệu suất tốt.'),
  ('Vợt Cầu Lông Adidas Adizero 8.0', 3000.00, 19, 0, 1, 'Vợt cầu lông với trọng lượng nhẹ, giúp người chơi linh hoạt.'),
  ('Vợt Cầu Lông Victor Jetspeed S 12', 3100.00, 14, 0, 8, 'Vợt cầu lông với công nghệ tiên tiến, tăng tốc độ và sức mạnh.'),
  ('Vợt Cầu Lông Lining Turbo X90', 2900.00, 16, 0, 5, 'Vợt cầu lông với thiết kế cân bằng, mang lại cảm giác tuyệt vời.'),
  ('Vợt Cầu Lông Mizuno Fortius 800', 2700.00, 21, 0, 6, 'Vợt cầu lông với chất lượng cao, phù hợp cho các cấp độ chơi.'),

  -- Giày Cầu Lông (tiếp tục)
  ('Giày Cầu Lông Kawasaki KS-600', 1650.00, 29, 1, 3, 'Giày cầu lông với thiết kế thoáng khí, tăng độ bám và hỗ trợ di chuyển.'),
  ('Giày Cầu Lông Kumpoo KS-800', 1800.00, 27, 1, 4, 'Giày cầu lông với công nghệ đệm êm ái, giúp giảm tải trọng cho bàn chân.'),
  ('Giày Cầu Lông Proace Ace 1000', 1700.00, 31, 1, 7, 'Giày cầu lông với độ ổn định cao, phù hợp cho các hoạt động cầu lông.'),
  ('Giày Cầu Lông VNB Champion 500', 1550.00, 33, 1, 9, 'Giày cầu lông với thiết kế hiện đại, thoáng khí và có độ bám tốt.'),
  ('Giày Cầu Lông Adidas Barricade 2023', 1850.00, 24, 1, 1, 'Giày cầu lông với công nghệ tối ưu hóa, giúp người chơi di chuyển linh hoạt.'),
  ('Giày Cầu Lông Victor SH-P9200', 1750.00, 26, 1, 8, 'Giày cầu lông với thiết kế thoáng khí, êm ái và bền bỉ.'),
  ('Giày Cầu Lông Lining AYTM005-2', 1600.00, 30, 1, 5, 'Giày cầu lông với công nghệ đế chống trượt, tăng độ bám sân.'),
  ('Giày Cầu Lông Mizuno Wave Stealth V', 1900.00, 23, 1, 6, 'Giày cầu lông với thiết kế nhẹ và linh hoạt, mang lại cảm giác thoải mái.'),
  ('Giày Cầu Lông Apacs Jetspeed X3', 1600.00, 28, 1, 2, 'Giày cầu lông với công nghệ đệm cao cấp, hỗ trợ di chuyển tối ưu.'),

  -- Quần Áo Cầu Lông (tiếp tục)
  ('Áo Cầu Lông Yonex 10283EX', 500.00, 40, 2, 10, 'Áo cầu lông chất liệu thoáng mát, co giãn tốt, tạo cảm giác thoải mái khi chơi.'),
  ('Quần Cầu Lông Victor R-09000', 450.00, 38, 2, 8, 'Quần cầu lông với thiết kế thoáng khí, giúp người chơi di chuyển dễ dàng.'),
  ('Áo Quần Cầu Lông Lining AAYM013-1', 600.00, 42, 2, 5, 'Bộ quần áo chơi cầu lông, chất liệu co giãn, thoáng mát.'),
  ('Áo Cầu Lông Mizuno 73CL8A0109', 550.00, 36, 2, 6, 'Áo cầu lông thiết kế thoáng khí, giúp người chơi luôn cảm thấy thoải mái.'),
  ('Quần Cầu Lông Apacs AP-301', 480.00, 44, 2, 2, 'Quần cầu lông với chất liệu co giãn, phù hợp cho mọi hoạt động.'),
  ('Áo Cầu Lông Kawasaki KS-5100', 520.00, 37, 2, 3, 'Áo cầu lông với chất liệu thoáng khí, tạo cảm giác thoải mái khi chơi.'),
  ('Quần Cầu Lông Kumpoo KP-7000', 490.00, 41, 2, 4, 'Quần cầu lông với thiết kế linh hoạt, giúp người chơi di chuyển dễ dàng.'),
  ('Áo Quần Cầu Lông Proace S-2000', 580.00, 35, 2, 7, 'Bộ quần áo cầu lông chất lượng cao, phù hợp cho cả tập luyện và thi đấu.'),
  ('Áo Cầu Lông VNB Ace 300', 500.00, 39, 2, 9, 'Áo cầu lông với thiết kế hiện đại, chất liệu thoáng mát.'),
  ('Bộ Quần Áo Cầu Lông Adidas A100', 620.00, 33, 2, 1, 'Bộ quần áo cầu lông với công nghệ hiện đại, tăng hiệu suất vận động.');

-- Tạo dữ liệu mẫu cho bảng PRODUCTS
INSERT INTO PRODUCTS (PRODUCT_NAME, UNIT_PRICE, AMOUNT, TYPE, BRAND_ID, DESCRIPTION)
VALUES
  -- Phụ Kiện Cầu Lông
  ('Bao Tay Cầu Lông Yonex AC133', 150.00, 60, 3, 10, 'Bao tay cầu lông chất lượng, giúp tăng độ ma sát khi cầm vợt.'),
  ('Băng Cổ Tay Cầu Lông Victor VT-0120', 80.00, 80, 3, 8, 'Băng cổ tay hỗ trợ và bảo vệ cổ tay khi chơi cầu lông.'),
  ('Tất Cầu Lông Lining ASTC002-1', 50.00, 90, 3, 5, 'Tất cầu lông có độ thấm hút tốt, giúp chân thoải mái khi chơi.'),
  ('Khăn Quấn Tay Cầu Lông Mizuno 73WR8A0109', 40.00, 100, 3, 6, 'Khăn quấn tay giúp hấp thụ mồ hôi, tăng độ bám tay khi cầm vợt.'),
  ('Dây Cầu Lông Apacs AP-DY01', 120.00, 70, 3, 2, 'Dây cầu lông chất lượng, độ bền cao, dễ dàng thay thế.'),
  ('Bao Tay Cầu Lông Kawasaki KG-201', 160.00, 55, 3, 3, 'Bao tay cầu lông với chất liệu cao cấp, tăng độ ma sát khi cầm vợt.'), 
  ('Băng Cổ Tay Cầu Lông Kumpoo KW-001', 90.00, 75, 3, 4, 'Băng cổ tay hỗ trợ và bảo vệ cổ tay, giúp người chơi thoải mái.'),
  ('Tất Cầu Lông Proace ST-100', 60.00, 85, 3, 7, 'Tất cầu lông thoáng khí, hút ẩm tốt, mang lại cảm giác thoải mái.'),
  ('Khăn Quấn Tay Cầu Lông VNB TX-01', 45.00, 95, 3, 9, 'Khăn quấn tay giúp người chơi tăng độ bám tay, giảm mệt mỏi.'),
  ('Bao Tay Cầu Lông Adidas AD-BT01', 170.00, 50, 3, 1, 'Bao tay cầu lông cao cấp, tăng độ ma sát và hỗ trợ cầm vợt.'),

  -- Túi Đựng Vợt Cầu Lông
  ('Túi Đựng Vợt Cầu Lông Yonex BAG2012EX', 650.00, 40, 4, 10, 'Túi đựng vợt chất lượng, có nhiều ngăn tiện dụng, dễ mang theo.'),
  ('Túi Đựng Vợt Cầu Lông Victor BR9208', 580.00, 35, 4, 8, 'Túi đựng vợt với thiết kế nhẹ, có dây đeo vai thoải mái.'),
  ('Túi Đựng Vợt Cầu Lông Lining ABJK002-1', 620.00, 38, 4, 5, 'Túi đựng vợt với nhiều ngăn chứa, bảo vệ vợt an toàn.'),
  ('Túi Đựng Vợt Cầu Lông Mizuno 73TB8A0109', 600.00, 42, 4, 6, 'Túi đựng vợt thiết kế thời trang, gọn nhẹ, dễ mang theo.'),
  ('Túi Đựng Vợt Cầu Lông Apacs AP-TB01', 550.00, 45, 4, 2, 'Túi đựng vợt chất lượng cao, có nhiều ngăn để đựng các phụ kiện.'),
  ('Túi Đựng Vợt Cầu Lông Kawasaki KT-301', 600.00, 37, 4, 3, 'Túi đựng vợt với thiết kế tiện lợi, dễ mang theo khi di chuyển.'),
  ('Túi Đựng Vợt Cầu Lông Kumpoo KBG-100', 630.00, 33, 4, 4, 'Túi đựng vợt với chất liệu bền đẹp, bảo vệ vợt an toàn.'),
  ('Túi Đựng Vợt Cầu Lông Proace TB-2000', 580.00, 39, 4, 7, 'Túi đựng vợt thiết kế sang trọng, có nhiều ngăn chứa tiện dụng.'),
  ('Túi Đựng Vợt Cầu Lông VNB TV-01', 560.00, 43, 4, 9, 'Túi đựng vợt chất lượng cao, kiểu dáng hiện đại, dễ mang theo.'),
  ('Túi Đựng Vợt Cầu Lông Adidas AD-TB01', 650.00, 35, 4, 1, 'Túi đựng vợt với chất liệu cao cấp, bảo vệ vợt tốt, tiện mang theo.'),

  -- Bóng Cầu Lông
  ('Bóng Cầu Lông Yonex 5000', 120.00, 200, 5, 10, 'Bóng cầu lông chất lượng cao, độ bật tốt, phù hợp cho tập luyện và thi đấu.'),
  ('Bóng Cầu Lông Victor Future 1000', 110.00, 180, 5, 8, 'Bóng cầu lông có độ bền cao, tạo cảm giác tốt khi chơi.'),
  ('Bóng Cầu Lông Lining A++', 130.00, 190, 5, 5, 'Bóng cầu lông với độ đàn hồi tốt, phù hợp cho mọi người.'),
  ('Bóng Cầu Lông Mizuno 73BL8A0109', 140.00, 210, 5, 6, 'Bóng cầu lông chất lượng cao, độ bền cao, giúp tăng hiệu suất chơi.'),
  ('Bóng Cầu Lông Apacs AP-BL01', 100.00, 220, 5, 2, 'Bóng cầu lông với độ bền cao, giúp tăng khả năng tập luyện.'),
  ('Bóng Cầu Lông Kawasaki KB-100', 150.00, 195, 5, 3, 'Bóng cầu lông chất lượng cao, độ bền cao, giúp tăng hiệu suất chơi.'),
  ('Bóng Cầu Lông Kumpoo KB-200', 125.00, 205, 5, 4, 'Bóng cầu lông với độ bền cao, giúp tăng khả năng tập luyện.'),
  ('Bóng Cầu Lông Proace PB-1000', 135.00, 185, 5, 7, 'Bóng cầu lông chất lượng cao, độ bền cao, giúp tăng hiệu suất chơi.'),
  ('Bóng Cầu Lông VNB VB-01', 115.00, 195, 5, 9, 'Bóng cầu lông với độ bền cao, giúp tăng khả năng tập luyện.'),
  ('Bóng Cầu Lông Adidas AD-BL01', 145.00, 210, 5, 1, 'Bóng cầu lông chất lượng cao, độ bền cao, giúp tăng hiệu suất chơi.');

-- Tạo dữ liệu mẫu cho bảng PRODUCTS

INSERT INTO PRODUCTS (PRODUCT_NAME, UNIT_PRICE, AMOUNT, TYPE, BRAND_ID, DESCRIPTION)
VALUES
  -- Vợt Cầu Lông
  ('Vợt Cầu Lông Yonex Astrox 88D', 3500.00, 20, 0, 10, 'Vợt cầu lông cao cấp, chất lượng tốt, phù hợp cho người chơi trình độ cao.'),
  ('Vợt Cầu Lông Victor Brave Sword 12', 2800.00, 15, 0, 8, 'Vợt cầu lông với thiết kế hiện đại, độ ổn định và kiểm soát tốt.'),
  ('Vợt Cầu Lông Lining Windstorm X90', 3000.00, 18, 0, 5, 'Vợt cầu lông với công nghệ hiện đại, tăng khả năng tấn công và phòng ngự.'),
  ('Vợt Cầu Lông Mizuno Fortius 900', 2500.00, 22, 0, 6, 'Vợt cầu lông với trọng lượng vừa phải, tạo cảm giác thoải mái khi cầm nắm.'),
  ('Vợt Cầu Lông Apacs Virtuoso 99', 2200.00, 25, 0, 2, 'Vợt cầu lông với khung đan chắc chắn, giúp tăng lực bật bóng.'),
  ('Vợt Cầu Lông Kawasaki Rexel 7000', 2800.00, 18, 0, 3, 'Vợt cầu lông với thiết kế hiện đại, tăng cường sức mạnh và độ bền.'),
  ('Vợt Cầu Lông Kumpoo KR-V12', 3200.00, 16, 0, 4, 'Vợt cầu lông với công nghệ hiện đại, tối ưu hóa lực tấn công.'),
  ('Vợt Cầu Lông Proace Power 999', 2600.00, 20, 0, 7, 'Vợt cầu lông với kiểm soát tốt, phù hợp cho người chơi trình độ cao.'),
  ('Vợt Cầu Lông VNB Supreme 1000', 2900.00, 17, 0, 9, 'Vợt cầu lông với thiết kế đẹp mắt, độ bền và hiệu suất tốt.'),
  ('Vợt Cầu Lông Adidas Adizero 8.0', 3000.00, 19, 0, 1, 'Vợt cầu lông với trọng lượng nhẹ, giúp người chơi linh hoạt.'),
  ('Vợt Cầu Lông Victor Jetspeed S 12', 3100.00, 14, 0, 8, 'Vợt cầu lông với công nghệ tiên tiến, tăng tốc độ và sức mạnh.'),
  ('Vợt Cầu Lông Lining Turbo X90', 2900.00, 16, 0, 5, 'Vợt cầu lông với thiết kế cân bằng, mang lại cảm giác tuyệt vời.'),
  ('Vợt Cầu Lông Mizuno Fortius 800', 2700.00, 21, 0, 6, 'Vợt cầu lông với chất lượng cao, phù hợp cho các cấp độ chơi.'),
  ('Vợt Cầu Lông Yonex Nanoray 800', 3300.00, 15, 0, 10, 'Vợt cầu lông với công nghệ hiện đại, mang lại hiệu suất tối ưu.'),
  ('Vợt Cầu Lông Victor Thruster K 9000', 2900.00, 18, 0, 8, 'Vợt cầu lông với thiết kế cân bằng, độ chính xác và kiểm soát tốt.'),
  ('Vợt Cầu Lông Lining Windstorm X80', 2800.00, 17, 0, 5, 'Vợt cầu lông với công nghệ hiện đại, tăng khả năng phòng ngự và tấn công.'),
  ('Vợt Cầu Lông Mizuno Fortius 700', 2600.00, 20, 0, 6, 'Vợt cầu lông với trọng lượng nhẹ, mang lại cảm giác thoải mái khi cầm.'),
  ('Vợt Cầu Lông Apacs Virtuoso 88', 2300.00, 22, 0, 2, 'Vợt cầu lông với thiết kế hiện đại, độ bền và hiệu suất ổn định.'),
  ('Vợt Cầu Lông Kawasaki Rexel 6000', 2700.00, 16, 0, 3, 'Vợt cầu lông với công nghệ tiên tiến, giúp tối ưu hóa lực tấn công.'),
  ('Vợt Cầu Lông Kumpoo KR-V10', 3000.00, 14, 0, 4, 'Vợt cầu lông với thiết kế cân bằng, mang lại cảm giác chắc tay.'),

  -- Giày Cầu Lông
  ('Giày Cầu Lông Yonex SHB-65Z2M', 1800.00, 30, 1, 10, 'Giày cầu lông chất lượng, êm chân, độ bám tốt, phù hợp cho người chơi cầu lông.'),
  ('Giày Cầu Lông Victor SH-A960', 1600.00, 28, 1, 8, 'Giày cầu lông với thiết kế thoáng khí, hỗ trợ di chuyển linh hoạt.'),
  ('Giày Cầu Lông Lining AYTJ005-4', 1700.00, 32, 1, 5, 'Giày cầu lông với đế cao su chống trượt, tăng độ bám sân.'),
  ('Giày Cầu Lông Apacs Jetspeed X2', 1500.00, 35, 1, 2, 'Giày cầu lông với công nghệ đế giúp tăng độ bám và ổn định khi di chuyển.'),
  ('Giày Cầu Lông Kawasaki KS-600', 1650.00, 29, 1, 3, 'Giày cầu lông với thiết kế thoáng khí, tăng độ bám và hỗ trợ di chuyển.'),
  ('Giày Cầu Lông Kumpoo KS-800', 1800.00, 27, 1, 4, 'Giày cầu lông với công nghệ đệm êm ái, giúp giảm tải trọng cho bàn chân.'),
  ('Giày Cầu Lông Proace Ace 1000', 1700.00, 31, 1, 7, 'Giày cầu lông với độ ổn định cao, phù hợp cho các hoạt động cầu lông.'),
  ('Giày Cầu Lông VNB Champion 500', 1550.00, 33, 1, 9, 'Giày cầu lông với thiết kế hiện đại, thoáng khí và có độ bám tốt.'),
  ('Giày Cầu Lông Adidas Barricade 2023', 1850.00, 24, 1, 1, 'Giày cầu lông với công nghệ tối ưu hóa, giúp người chơi di chuyển linh hoạt.'),
  ('Giày Cầu Lông Victor SH-P9200', 1750.00, 26, 1, 8, 'Giày cầu lông với thiết kế thoáng khí, êm ái và bền bỉ.'),
  ('Giày Cầu Lông Lining AYTM005-2', 1600.00, 30, 1, 5, 'Giày cầu lông với công nghệ đế chống trượt, tăng độ bám sân.'),
  ('Giày Cầu Lông Mizuno Wave Stealth V', 1900.00, 23, 1, 6, 'Giày cầu lông với thiết kế nhẹ và linh hoạt, mang lại cảm giác thoải mái.'),
  ('Giày Cầu Lông Apacs Jetspeed X3', 1600.00, 28, 1, 2, 'Giày cầu lông với công nghệ đệm cao cấp, hỗ trợ di chuyển tối ưu.'),
  ('Giày Cầu Lông Yonex SHB-65Z3M', 1850.00, 25, 1, 10, 'Giày cầu lông với độ bám tốt, thoáng khí và êm ái, phù hợp cho người chơi cấp cao.'),
  ('Giày Cầu Lông Victor SH-A970', 1680.00, 27, 1, 8, 'Giày cầu lông có thiết kế linh hoạt, hỗ trợ di chuyển tối ưu.'),
  ('Giày Cầu Lông Lining AYTJ007-2', 1750.00, 29, 1, 5, 'Giày cầu lông với công nghệ đế chống trượt, tăng độ bám sân và ổn định.'),
  ('Giày Cầu Lông Mizuno Wave Medal 5', 1920.00, 22, 1, 6, 'Giày cầu lông với thiết kế tối ưu, mang lại cảm giác thoải mái khi chơi.'),
  ('Giày Cầu Lông Apacs Jetspeed X4', 1650.00, 26, 1, 2, 'Giày cầu lông với công nghệ đệm cao cấp, giúp giảm tải trọng cho bàn chân.'),

  -- Quần Áo Cầu Lông
  ('Áo Cầu Lông Yonex 10283EX', 500.00, 40, 2, 10, 'Áo cầu lông chất liệu thoáng mát, co giãn tốt, tạo cảm giác thoải mái khi chơi.'),
  ('Quần Cầu Lông Victor R-09000', 450.00, 38, 2, 8, 'Quần cầu lông với thiết kế thoáng khí, giúp người chơi di chuyển dễ dàng.'),
  ('Áo Quần Cầu Lông Lining AAYM013-1', 600.00, 42, 2, 5, 'Bộ quần áo chơi cầu lông, chất liệu co giãn, thoáng mát.'),
  ('Áo Cầu Lông Mizuno 73CL8A0109', 550.00, 36, 2, 6, 'Áo cầu lông thiết kế thoáng khí, giúp người chơi luôn cảm thấy thoải mái.'),
  ('Quần Cầu Lông Apacs AP-301', 480.00, 44, 2, 2, 'Quần cầu lông với chất liệu co giãn, phù hợp cho mọi hoạt động.'),
  ('Áo Cầu Lông Kawasaki KS-5100', 520.00, 37, 2, 3, 'Áo cầu lông với chất liệu thoáng khí, tạo cảm giác thoải mái khi chơi.'),
  ('Quần Cầu Lông Kumpoo KP-7000', 490.00, 41, 2, 4, 'Quần cầu lông với thiết kế linh hoạt, giúp người chơi di chuyển dễ dàng.'),
  ('Áo Quần Cầu Lông Proace S-2000', 580.00, 35, 2, 7, 'Bộ quần áo cầu lông chất lượng cao, phù hợp cho cả tập luyện và thi đấu.'),
  ('Áo Cầu Lông VNB Ace 300', 500.00, 39, 2, 9, 'Áo cầu lông với thiết kế hiện đại, chất liệu thoáng mát.'),
  ('Bộ Quần Áo Cầu Lông Adidas A100', 620.00, 33, 2, 1, 'Bộ quần áo cầu lông với công nghệ hiện đại, tăng hiệu suất vận động.'),
  ('Áo Cầu Lông Yonex 10283EX', 500.00, 40, 2, 10, 'Áo cầu lông chất liệu thoáng mát, co giãn tốt, tạo cảm giác thoải mái khi chơi.'),
  ('Quần Cầu Lông Victor R-09000', 450.00, 38, 2, 8, 'Quần cầu lông với thiết kế thoáng khí, giúp người chơi di chuyển dễ dàng.'),
  ('Áo Quần Cầu Lông Lining AAYM013-1', 600.00, 42, 2, 5, 'Bộ quần áo chơi cầu lông, chất liệu co giãn, thoáng mát.'),
  ('Áo Cầu Lông Mizuno 73CL8A0109', 550.00, 36, 2, 6, 'Áo cầu lông thiết kế thoáng khí, giúp người chơi luôn cảm thấy thoải mái.'),
  ('Quần Cầu Lông Apacs AP-301', 480.00, 44, 2, 2, 'Quần cầu lông với chất liệu co giãn, phù hợp cho mọi hoạt động.'),
  ('Áo Cầu Lông Kawasaki KS-5100', 520.00, 37, 2, 3, 'Áo cầu lông với chất liệu thoáng khí, tạo cảm giác thoải mái khi chơi.'),
  ('Quần Cầu Lông Kumpoo KP-7000', 490.00, 41, 2, 4, 'Quần cầu lông với thiết kế linh hoạt, giúp người chơi di chuyển dễ dàng.'),
  ('Áo Quần Cầu Lông Proace S-2000', 580.00, 35, 2, 7, 'Bộ quần áo cầu lông chất lượng cao, phù hợp cho cả tập luyện và thi đấu.'),
  ('Áo Cầu Lông VNB Ace 300', 500.00, 39, 2, 9, 'Áo cầu lông với thiết kế hiện đại, chất liệu thoáng mát.'),
  ('Bộ Quần Áo Cầu Lông Adidas A100', 620.00, 33, 2, 1, 'Bộ quần áo cầu lông với công nghệ hiện đại, tăng hiệu suất vận động.'),
  ('Áo Cầu Lông Yonex 10283EX', 500.00, 40, 2, 10, 'Áo cầu lông chất liệu thoáng mát, co giãn tốt, tạo cảm giác thoải mái khi chơi.'),
  ('Quần Cầu Lông Victor R-09000', 450.00, 38, 2, 8, 'Quần cầu lông với thiết kế thoáng khí, giúp người chơi di chuyển dễ dàng.'),
  ('Áo Quần Cầu Lông Lining AAYM013-1', 600.00, 42, 2, 5, 'Bộ quần áo chơi cầu lông, chất liệu co giãn, thoáng mát.'),
  ('Bộ Quần Áo Cầu Lông Adidas A100', 620.00, 33, 2, 1, 'Bộ quần áo cầu lông với công nghệ hiện đại, tăng hiệu suất vận động.'),
  ('Áo Cầu Lông Yonex 10383EX', 550.00, 35, 2, 10, 'Áo cầu lông với chất liệu thoáng khí, co giãn tốt, mang lại thoải mái khi chơi.'),
  ('Quần Cầu Lông Victor R-11000', 480.00, 40, 2, 8, 'Quần cầu lông với thiết kế linh hoạt, giúp người chơi di chuyển dễ dàng.'),
  ('Áo Quần Cầu Lông Lining AAYM015-2', 630.00, 38, 2, 5, 'Bộ quần áo chơi cầu lông chất lượng cao, thoáng mát và co giãn tốt.'),
  ('Áo Cầu Lông Mizuno 73CL8A0112', 580.00, 32, 2, 6, 'Áo cầu lông với thiết kế tối ưu, giúp người chơi luôn cảm thấy thoải mái.'),
  ('Quần Cầu Lông Apacs AP-302', 500.00, 42, 2, 2, 'Quần cầu lông chất liệu co giãn, phù hợp cho mọi hoạt động.'),
  ('Áo Cầu Lông Kawasaki KS-5200', 540.00, 35, 2, 3, 'Áo cầu lông với chất liệu thoáng khí, mang lại cảm giác thoải mái khi chơi.'),
  ('Quần Cầu Lông Kumpoo KP-7100', 510.00, 39, 2, 4, 'Quần cầu lông với thiết kế linh hoạt, hỗ trợ di chuyển tốt.'),
  ('Áo Quần Cầu Lông Proace S-2500', 600.00, 30, 2, 7, 'Bộ quần áo cầu lông chất lượng cao, phù hợp cho cả tập luyện và thi đấu.'),
  ('Áo Cầu Lông VNB Ace 400', 520.00, 37, 2, 9, 'Áo cầu lông với thiết kế hiện đại, chất liệu thoáng mát.'),

  -- Phụ Kiện Cầu Lông
  ('Bao Tay Cầu Lông Yonex AC133', 150.00, 60, 3, 10, 'Bao tay cầu lông chất lượng, giúp tăng độ ma sát khi cầm vợt.'),
  ('Băng Cổ Tay Cầu Lông Victor VT-0120', 80.00, 80, 3, 8, 'Băng cổ tay hỗ trợ và bảo vệ cổ tay khi chơi cầu lông.'),
  ('Tất Cầu Lông Lining ASTC002-1', 50.00, 90, 3, 5, 'Tất cầu lông có độ thấm hút tốt, giúp chân thoải mái khi chơi.'),
  ('Khăn Quấn Tay Cầu Lông Mizuno 73WR8A0109', 40.00, 100, 3, 6, 'Khăn quấn tay giúp hấp thụ mồ hôi, tăng độ bám tay khi cầm vợt.'),
  ('Dây Cầu Lông Apacs AP-DY01', 120.00, 70, 3, 2, 'Dây cầu lông chất lượng, độ bền cao, dễ dàng thay thế.'),
  ('Bao Tay Cầu Lông Kawasaki KG-201', 160.00, 55, 3, 3, 'Bao tay cầu lông với chất liệu cao cấp, tăng độ ma sát khi cầm vợt.'),
  ('Băng Cổ Tay Cầu Lông Kumpoo KW-001', 90.00, 75, 3, 4, 'Băng cổ tay hỗ trợ và bảo vệ cổ tay, giúp người chơi thoải mái.'),
  ('Tất Cầu Lông Proace ST-100', 60.00, 85, 3, 7, 'Tất cầu lông thoáng khí, hút ẩm tốt, mang lại cảm giác thoải mái.'),
  ('Khăn Quấn Tay Cầu Lông VNB TX-01', 45.00, 95, 3, 9, 'Khăn quấn tay giúp người chơi tăng độ bám tay, giảm mệt mỏi.'),
  ('Bao Tay Cầu Lông Adidas AD-BT01', 170.00, 50, 3, 1, 'Bao tay cầu lông cao cấp, tăng độ ma sát và hỗ trợ cầm vợt.'),
  ('Bao Tay Cầu Lông Yonex AC135', 160.00, 55, 3, 10, 'Bao tay cầu lông chất lượng cao, giúp tăng độ bám khi cầm vợt.'),
  ('Băng Cổ Tay Cầu Lông Victor VT-0130', 85.00, 75, 3, 8, 'Băng cổ tay hỗ trợ và bảo vệ cổ tay, tăng độ thoải mái khi chơi cầu lông.'),
  ('Tất Cầu Lông Lining ASTC003-2', 55.00, 85, 3, 5, 'Tất cầu lông với chất liệu thoáng khí, giúp chân luôn khô ráo.'),
   -- Phụ Kiện Cầu Lông (tiếp tục)
  ('Khăn Quấn Tay Cầu Lông Apacs AP-TW01', 50.00, 90, 3, 2, 'Khăn quấn tay cầu lông giúp hấp thụ mồ hôi, tăng độ bám tay khi cầm vợt.'),
  ('Khăn Quấn Tay Cầu Lông Kawasaki KG-101', 45.00, 100, 3, 3, 'Khăn quấn tay cầu lông chất lượng, giúp người chơi thoải mái khi thi đấu.'),
  ('Khăn Quấn Tay Cầu Lông Kumpoo KW-002', 55.00, 85, 3, 4, 'Khăn quấn tay cầu lông với độ thấm hút tốt, giúp tăng độ bám tay.'),
  ('Khăn Quấn Tay Cầu Lông Proace TX-2000', 40.00, 95, 3, 7, 'Khăn quấn tay cầu lông chất lượng, tạo cảm giác thoải mái khi chơi.'),
  ('Khăn Quấn Tay Cầu Lông VNB TX-02', 50.00, 90, 3, 9, 'Khăn quấn tay cầu lông với thiết kế tiện dụng, hỗ trợ người chơi tốt.'),
  ('Khăn Quấn Tay Cầu Lông Adidas AD-TW01', 60.00, 80, 3, 1, 'Khăn quấn tay cầu lông cao cấp, giúp tăng độ bám và hấp thụ mồ hôi.'),
  ('Khăn Quấn Tay Cầu Lông Yonex AC137', 55.00, 85, 3, 10, 'Khăn quấn tay cầu lông chất lượng, tạo cảm giác thoải mái khi chơi.'),
  ('Khăn Quấn Tay Cầu Lông Victor VT-0140', 45.00, 90, 3, 8, 'Khăn quấn tay cầu lông với độ thấm hút tốt, giúp người chơi thoải mái.'),
  ('Khăn Quấn Tay Cầu Lông Lining AWTC001-3', 50.00, 87, 3, 5, 'Khăn quấn tay cầu lông chất lượng, tăng độ bám khi cầm vợt.'),
  ('Khăn Quấn Tay Cầu Lông Mizuno 73WR8A0112', 48.00, 92, 3, 6, 'Khăn quấn tay cầu lông với thiết kế tối ưu, giúp hấp thụ mồ hôi.'),

  -- Túi Đựng Vợt Cầu Lông
  ('Túi Đựng Vợt Cầu Lông Yonex BAG2012EX', 650.00, 40, 4, 10, 'Túi đựng vợt chất lượng, có nhiều ngăn tiện dụng, dễ mang theo.'),
  ('Túi Đựng Vợt Cầu Lông Victor BR9208', 580.00, 35, 4, 8, 'Túi đựng vợt với thiết kế nhẹ, có dây đeo vai thoải mái.'),
  ('Túi Đựng Vợt Cầu Lông Lining ABJK002-1', 620.00, 38, 4, 5, 'Túi đựng vợt với nhiều ngăn chứa, bảo vệ vợt an toàn.'),
  ('Túi Đựng Vợt Cầu Lông Mizuno 73TB8A0109', 600.00, 42, 4, 6, 'Túi đựng vợt thiết kế thời trang, gọn nhẹ, dễ mang theo.'),
  ('Túi Đựng Vợt Cầu Lông Apacs AP-TB01', 550.00, 45, 4, 2, 'Túi đựng vợt chất lượng cao, có nhiều ngăn để đựng các phụ kiện.'),
  ('Túi Đựng Vợt Cầu Lông Kawasaki KT-301', 600.00, 37, 4, 3, 'Túi đựng vợt với thiết kế tiện lợi, dễ mang theo khi di chuyển.'),
  ('Túi Đựng Vợt Cầu Lông Kumpoo KBG-100', 630.00, 33, 4, 4, 'Túi đựng vợt với chất liệu bền đẹp, bảo vệ vợt an toàn.'),
  ('Túi Đựng Vợt Cầu Lông Proace TB-2000', 580.00, 39, 4, 7, 'Túi đựng vợt thiết kế sang trọng, có nhiều ngăn chứa tiện dụng.'),
  ('Túi Đựng Vợt Cầu Lông VNB TV-01', 560.00, 43, 4, 9, 'Túi đựng vợt chất lượng cao, kiểu dáng hiện đại, dễ mang theo.'),
  ('Túi Đựng Vợt Cầu Lông Adidas AD-TB01', 650.00, 35, 4, 1, 'Túi đựng vợt với chất liệu cao cấp, bảo vệ vợt tốt, tiện mang theo.');


  -- Tạo dữ liệu mẫu cho bảng PRODUCTS

INSERT INTO PRODUCTS (PRODUCT_NAME, UNIT_PRICE, AMOUNT, TYPE, BRAND_ID, DESCRIPTION)
VALUES
  -- Vợt Cầu Lông
  ('Vợt Cầu Lông Yonex Astrox 100ZZ', 3800.00, 22, 0, 10, 'Vợt cầu lông cao cấp, công nghệ hiện đại, độ bền và hiệu suất tối ưu.'),
  ('Vợt Cầu Lông Victor Jetspeed S 13', 3300.00, 18, 0, 8, 'Vợt cầu lông với thiết kế cân bằng, tăng tốc độ và lực tấn công.'),
  ('Vợt Cầu Lông Lining Windstorm X99', 3200.00, 20, 0, 5, 'Vợt cầu lông với công nghệ hiện đại, tối ưu hóa khả năng phòng ngự và tấn công.'),
  ('Vợt Cầu Lông Mizuno Fortius 850', 2900.00, 24, 0, 6, 'Vợt cầu lông với trọng lượng vừa phải, tạo cảm giác thoải mái khi cầm nắm.'),
  ('Vợt Cầu Lông Apacs Virtuoso 99X', 2400.00, 27, 0, 2, 'Vợt cầu lông với thiết kế hiện đại, tăng cường khả năng tấn công.'),
  ('Vợt Cầu Lông Kawasaki Rexel 7500', 3000.00, 20, 0, 3, 'Vợt cầu lông với công nghệ tiên tiến, độ bền và hiệu suất tốt.'),
  ('Vợt Cầu Lông Kumpoo KR-V15', 3400.00, 16, 0, 4, 'Vợt cầu lông với thiết kế cân bằng, tăng khả năng kiểm soát bóng.'),
  ('Vợt Cầu Lông Proace Power 1099', 2800.00, 22, 0, 7, 'Vợt cầu lông với độ ổn định cao, phù hợp cho cả người chơi trình độ cao.'),
  ('Vợt Cầu Lông VNB Supreme 1500', 3100.00, 18, 0, 9, 'Vợt cầu lông với thiết kế hiện đại, chất lượng tốt và độ bền cao.'),
  ('Vợt Cầu Lông Adidas Adizero 9.0', 3200.00, 21, 0, 1, 'Vợt cầu lông với trọng lượng nhẹ, giúp người chơi di chuyển nhanh nhẹn.'),
  ('Vợt Cầu Lông Victor Jetspeed S 14', 3400.00, 16, 0, 8, 'Vợt cầu lông với công nghệ tiên tiến, tăng tốc độ và lực tấn công.'),
  ('Vợt Cầu Lông Lining Turbo X99', 3100.00, 18, 0, 5, 'Vợt cầu lông với thiết kế cân bằng, mang lại cảm giác tuyệt vời khi chơi.'),
  ('Vợt Cầu Lông Mizuno Fortius 750', 2900.00, 23, 0, 6, 'Vợt cầu lông với chất lượng cao, phù hợp cho các cấp độ chơi.'),
  ('Vợt Cầu Lông Yonex Nanoray 900', 3500.00, 17, 0, 10, 'Vợt cầu lông với công nghệ hiện đại, mang lại hiệu suất tối ưu.'),
  ('Vợt Cầu Lông Victor Thruster K 9500', 3100.00, 20, 0, 8, 'Vợt cầu lông với thiết kế cân bằng, độ chính xác và kiểm soát tốt.'),
  ('Vợt Cầu Lông Lining Windstorm X90X', 3000.00, 19, 0, 5, 'Vợt cầu lông với công nghệ hiện đại, tăng khả năng phòng ngự và tấn công.'),
  ('Vợt Cầu Lông Mizuno Fortius 650', 2800.00, 22, 0, 6, 'Vợt cầu lông với trọng lượng nhẹ, mang lại cảm giác thoải mái khi cầm.'),
  ('Vợt Cầu Lông Apacs Virtuoso 88X', 2500.00, 24, 0, 2, 'Vợt cầu lông với thiết kế hiện đại, độ bền và hiệu suất ổn định.'),
  ('Vợt Cầu Lông Kawasaki Rexel 6500', 2900.00, 18, 0, 3, 'Vợt cầu lông với công nghệ tiên tiến, giúp tối ưu hóa lực tấn công.'),
  ('Vợt Cầu Lông Kumpoo KR-V12X', 3200.00, 16, 0, 4, 'Vợt cầu lông với thiết kế cân bằng, mang lại cảm giác chắc tay.'),

  -- Giày Cầu Lông
  ('Giày Cầu Lông Yonex SHB-65Z3L', 1900.00, 32, 1, 10, 'Giày cầu lông chất lượng cao, êm chân, độ bám tốt, phù hợp cho người chơi cầu lông.'),
  ('Giày Cầu Lông Victor SH-A980', 1700.00, 30, 1, 8, 'Giày cầu lông với thiết kế thoáng khí, hỗ trợ di chuyển linh hoạt.'),
  ('Giày Cầu Lông Lining AYTJ007-4', 1800.00, 34, 1, 5, 'Giày cầu lông với đế cao su chống trượt, tăng độ bám sân.'),
   ('Giày Cầu Lông Apacs Jetspeed X5', 1700.00, 29, 1, 2, 'Giày cầu lông với công nghệ đế êm ái, giúp giảm tải trọng cho bàn chân.'),
  ('Giày Cầu Lông Kawasaki KS-650', 1800.00, 26, 1, 3, 'Giày cầu lông với thiết kế thoáng khí, tăng độ bám và ổn định khi di chuyển.'),
  ('Giày Cầu Lông Kumpoo KS-850', 1850.00, 23, 1, 4, 'Giày cầu lông với công nghệ tối ưu, mang lại sự thoải mái khi chơi.'),
  ('Giày Cầu Lông Proace Ace 2000', 1750.00, 27, 1, 7, 'Giày cầu lông với độ ổn định và bám sân cao, phù hợp cho mọi hoạt động.'),
  ('Giày Cầu Lông VNB Champion 700', 1600.00, 31, 1, 9, 'Giày cầu lông với thiết kế thoáng khí, tạo cảm giác thoải mái khi di chuyển.'),
  ('Giày Cầu Lông Adidas Barricade 2024', 1900.00, 22, 1, 1, 'Giày cầu lông với công nghệ hiện đại, giúp người chơi di chuyển nhanh nhẹn.'),
  ('Giày Cầu Lông Victor SH-P9300', 1800.00, 24, 1, 8, 'Giày cầu lông với chất lượng vượt trội, độ bền cao và thoải mái khi sử dụng.'),
  ('Giày Cầu Lông Lining AYTJ007-6', 1650.00, 28, 1, 5, 'Giày cầu lông với đệm cao cấp, giúp giảm tải trọng cho bàn chân.'),
  ('Giày Cầu Lông Mizuno Wave Stealth VI', 2050.00, 20, 1, 6, 'Giày cầu lông với thiết kế hiện đại, mang lại sự ổn định và thoải mái khi chơi.'),
  ('Giày Cầu Lông Apacs Jetspeed X6', 1750.00, 25, 1, 2, 'Giày cầu lông với công nghệ đế chống trượt, tăng độ bám sân.'),
  ('Giày Cầu Lông Yonex SHB-65Z3N', 1900.00, 21, 1, 10, 'Giày cầu lông chất lượng cao, phù hợp cho các cấp độ chơi.'),
  ('Giày Cầu Lông Victor SH-A990', 1750.00, 23, 1, 8, 'Giày cầu lông với thiết kế tối ưu, giúp người chơi di chuyển linh hoạt.'),
  ('Giày Cầu Lông Lining AYTJ007-8', 1700.00, 26, 1, 5, 'Giày cầu lông với công nghệ đế chống trơn trượt, tăng độ bám sân.'),
  ('Giày Cầu Lông Mizuno Wave Stealth VII', 2100.00, 19, 1, 6, 'Giày cầu lông với thiết kế hiện đại, mang lại cảm giác thoải mái khi chơi.'),
  ('Giày Cầu Lông Apacs Jetspeed X7', 1800.00, 22, 1, 2, 'Giày cầu lông với công nghệ đệm cao cấp, giúp giảm tải trọng cho bàn chân.'),
  ('Giày Cầu Lông Yonex SHB-35Z3P', 1950.00, 20, 1, 10, 'Giày cầu lông với thiết kế hiện đại, thoáng khí và có độ bám tốt.'),
  ('Giày Cầu Lông Victor SH-A9610', 1700.00, 24, 1, 8, 'Giày cầu lông với thiết kế thoáng khí, êm ái và bền bỉ.'),
  ('Giày Cầu Lông Lining AYTJ0071', 1750.00, 27, 1, 5, 'Giày cầu lông với công nghệ đế chống trượt, tăng độ bám sân.'),
  ('Giày Cầu Lông Mizuno Wave Stea1th VI', 2000.00, 22, 1, 6, 'Giày cầu lông với thiết kế nhẹ và linh hoạt, mang lại cảm giác thoải mái.'),
  ('Giày Cầu Lông Apacs Jetspeed X1', 1700.00, 25, 1, 2, 'Giày cầu lông với công nghệ đệm cao cấp, hỗ trợ di chuyển tối ưu.'),
   -- Quần Áo Cầu Lông (tiếp tục)
  ('Bộ Quần Áo Cầu Lông Adidas A200', 640.00, 32, 2, 1, 'Bộ quần áo cầu lông với công nghệ hiện đại, tăng hiệu suất vận động.'),
  ('Áo Cầu Lông Yonex 10385EX', 580.00, 34, 2, 10, 'Áo cầu lông với chất liệu thoáng khí, co giãn tốt, mang lại cảm giác thoải mái.'),
  ('Quần Cầu Lông Victor R-12000', 500.00, 38, 2, 8, 'Quần cầu lông với thiết kế linh hoạt, giúp người chơi di chuyển dễ dàng.'),
  ('Áo Quần Cầu Lông Lining AAYM015-6', 660.00, 36, 2, 5, 'Bộ quần áo chơi cầu lông chất lượng cao, thoáng mát và co giãn tốt.'),
  ('Áo Cầu Lông Mizuno 73CL8A0116', 620.00, 29, 2, 6, 'Áo cầu lông với thiết kế tối ưu, giúp người chơi luôn cảm thấy thoải mái.'),
  ('Quần Cầu Lông Apacs AP-304', 540.00, 40, 2, 2, 'Quần cầu lông với chất liệu co giãn, phù hợp cho mọi hoạt động.'),
  ('Áo Cầu Lông Kawasaki KS-5400', 580.00, 32, 2, 3, 'Áo cầu lông với chất liệu thoáng khí, tạo cảm giác thoải mái khi chơi.'),
  ('Quần Cầu Lông Kumpoo KP-7300', 550.00, 36, 2, 4, 'Quần cầu lông với thiết kế linh hoạt, hỗ trợ di chuyển tốt.'),
  ('Áo Quần Cầu Lông Proace S-3000', 630.00, 27, 2, 7, 'Bộ quần áo cầu lông chất lượng cao, phù hợp cho cả tập luyện và thi đấu.'),
  ('Áo Cầu Lông VNB Ace 600', 560.00, 33, 2, 9, 'Áo cầu lông với thiết kế hiện đại, chất liệu thoáng mát.'),
  ('Bộ Quần Áo Cầu Lông Adidas A300', 660.00, 31, 2, 1, 'Bộ quần áo cầu lông với công nghệ hiện đại, tăng hiệu suất vận động.'),
  ('Áo Cầu Lông Yonex 10387EZ', 590.00, 35, 2, 10, 'Áo cầu lông với chất liệu thoáng khí, co giãn tốt, mang lại cảm giác thoải mái.'),
  ('Quần Cầu Lông Victor R-12100', 520.00, 37, 2, 8, 'Quần cầu lông với thiết kế linh hoạt, giúp người chơi di chuyển dễ dàng.'),
  ('Áo Quần Cầu Lông Lining AAYM015-8', 670.00, 34, 2, 5, 'Bộ quần áo chơi cầu lông chất lượng cao, thoáng mát và co giãn tốt.'),
  ('Áo Cầu Lông Mizuno 73CL8A0118', 630.00, 28, 2, 6, 'Áo cầu lông với thiết kế tối ưu, giúp người chơi luôn cảm thấy thoải mái.'),

  -- Phụ Kiện Cầu Lông
  ('Bao Tay Cầu Lông Yonex AC134', 160.00, 58, 3, 10, 'Bao tay cầu lông chất lượng, giúp tăng độ ma sát khi cầm vợt.'),
  ('Băng Cổ Tay Cầu Lông Victor VT-0121', 85.00, 75, 3, 8, 'Băng cổ tay hỗ trợ và bảo vệ cổ tay khi chơi cầu lông.'),
  ('Tất Cầu Lông Lining ASTC002-2', 55.00, 85, 3, 5, 'Tất cầu lông có độ thấm hút tốt, giúp chân thoải mái khi chơi.'),
  ('Khăn Quấn Tay Cầu Lông Mizuno 73WR8A0110', 42.00, 95, 3, 6, 'Khăn quấn tay giúp hấp thụ mồ hôi, tăng độ bám tay khi cầm vợt.'),
  ('Dây Cầu Lông Apacs AP-DY02', 130.00, 65, 3, 2, 'Dây cầu lông chất lượng, độ bền cao, dễ dàng thay thế.'),
  ('Bao Tay Cầu Lông Kawasaki KG-202', 170.00, 52, 3, 3, 'Bao tay cầu lông với chất liệu cao cấp, tăng độ ma sát khi cầm vợt.'),
  ('Băng Cổ Tay Cầu Lông Kumpoo KW-002', 95.00, 70, 3, 4, 'Băng cổ tay hỗ trợ và bảo vệ cổ tay, giúp người chơi thoải mái.'),
  ('Tất Cầu Lông Proace ST-101', 65.00, 80, 3, 7, 'Tất cầu lông thoáng khí, hút ẩm tốt, mang lại cảm giác thoải mái.');

--vouchers
INSERT INTO VOUCHERS (PRODUCT_NAME, DAY_START, DAY_OFF, PERCENT_OFF, AMOUNT, PRODUCT_ID) VALUES
('Voucher A', '2024-01-01', '2024-01-31', 20, 100, 2),
('Voucher B', '2024-02-01', '2024-02-28', 15, 200, 5),
('Voucher C', '2024-03-01', '2024-03-31', 25, 150, 10),
('Voucher D', '2024-04-01', '2024-04-30', 30, 300, 12),
('Voucher E', '2024-05-01', '2024-05-31', 35, 250, 20),
('Voucher F', '2024-06-01', '2024-06-30', 40, 400, 22),
('Voucher G', '2024-07-01', '2024-07-31', 45, 350, 30),
('Voucher H', '2024-08-01', '2024-08-31', 50, 500, 35),
('Voucher I', '2024-09-01', '2024-09-30', 55, 450, 40),
('Voucher J', '2024-10-01', '2024-10-31', 60, 600, 50),
('Voucher K', '2024-11-01', '2024-11-30', 20, 100, 60),
('Voucher L', '2024-12-01', '2024-12-31', 25, 200, 70),
('Voucher M', '2024-01-01', '2024-01-31', 30, 150, 80),
('Voucher N', '2024-02-01', '2024-02-28', 35, 250, 90),
('Voucher O', '2024-03-01', '2024-03-31', 40, 300, 100),
('Voucher P', '2024-04-01', '2024-04-30', 45, 350, 110),
('Voucher Q', '2024-05-01', '2024-05-31', 50, 400, 120),
('Voucher R', '2024-06-01', '2024-06-30', 55, 450, 130),
('Voucher S', '2024-07-01', '2024-07-31', 60, 500, 140),
('Voucher T', '2024-08-01', '2024-08-31', 65, 550, 150),
('Voucher U', '2024-09-01', '2024-09-30', 20, 100, 160),
('Voucher V', '2024-10-01', '2024-10-31', 25, 200, 170),
('Voucher W', '2024-11-01', '2024-11-30', 30, 150, 180),
('Voucher X', '2024-12-01', '2024-12-31', 35, 250, 190),
('Voucher Y', '2024-01-01', '2024-01-31', 40, 300, 200),
('Voucher Z', '2024-02-01', '2024-02-28', 45, 350, 2),
('Voucher AA', '2024-03-01', '2024-03-31', 50, 400, 5),
('Voucher BB', '2024-04-01', '2024-04-30', 55, 450, 10),
('Voucher CC', '2024-05-01', '2024-05-31', 60, 500, 12),
('Voucher DD', '2024-06-01', '2024-06-30', 20, 100, 20),
('Voucher EE', '2024-07-01', '2024-07-31', 25, 200, 22),
('Voucher FF', '2024-08-01', '2024-08-31', 30, 150, 30),
('Voucher GG', '2024-09-01', '2024-09-30', 35, 250, 35),
('Voucher HH', '2024-10-01', '2024-10-31', 40, 300, 40),
('Voucher II', '2024-11-01', '2024-11-30', 45, 350, 50),
('Voucher JJ', '2024-12-01', '2024-12-31', 50, 400, 60),
('Voucher KK', '2024-01-01', '2024-01-31', 55, 450, 70),
('Voucher LL', '2024-02-01', '2024-02-28', 60, 500, 80),
('Voucher MM', '2024-03-01', '2024-03-31', 20, 100, 90),
('Voucher NN', '2024-04-01', '2024-04-30', 25, 200, 100),
('Voucher OO', '2024-05-01', '2024-05-31', 30, 150, 110),
('Voucher PP', '2024-06-01', '2024-06-30', 35, 250, 120),
('Voucher QQ', '2024-07-01', '2024-07-31', 40, 300, 130),
('Voucher RR', '2024-08-01', '2024-08-31', 45, 350, 140),
('Voucher SS', '2024-09-01', '2024-09-30', 50, 400, 150),
('Voucher TT', '2024-10-01', '2024-10-31', 55, 450, 160),
('Voucher UU', '2024-11-01', '2024-11-30', 60, 500, 170),
('Voucher VV', '2024-12-01', '2024-12-31', 20, 100, 180),
('Voucher WW', '2024-01-01', '2024-01-31', 25, 200, 190),
('Voucher XX', '2024-02-01', '2024-02-28', 30, 150, 200),
('Voucher YY', '2024-03-01', '2024-03-31', 35, 250, 2),
('Voucher ZZ', '2024-04-01', '2024-04-30', 40, 300, 5),
('Voucher AAA', '2024-05-01', '2024-05-31', 45, 350, 10),
('Voucher BBB', '2024-06-01', '2024-06-30', 50, 400, 12),
('Voucher CCC', '2024-07-01', '2024-07-31', 55, 450, 20),
('Voucher DDD', '2024-08-01', '2024-08-31', 60, 500, 22),
('Voucher EEE', '2024-09-01', '2024-09-30', 20, 100, 30),
('Voucher FFF', '2024-10-01', '2024-10-31', 25, 200, 35),
('Voucher GGG', '2024-11-01', '2024-11-30', 30, 150, 40),
('Voucher HHH', '2024-12-01', '2024-12-31', 35, 250, 50);

UPDATE public."products" SET unit_price = unit_price * 1000;

INSERT INTO CITIES (CITY_NAME) VALUES 
('Hanoi'),
('Ho Chi Minh City'),
('Da Nang'),
('Haiphong'),
('Can Tho'),
('Nha Trang'),
('Hue'),
('Bien Hoa'),
('Buon Ma Thuot'),
('Da Lat'),
('Vung Tau'),
('Quy Nhon'),
('Rach Gia'),
('Thai Nguyen'),
('Nam Dinh'),
('Phan Thiet'),
('Thanh Hoa'),
('Vinh'),
('My Tho'),
('Cam Ranh'),
('Pleiku'),
('Long Xuyen'),
('Bac Lieu'),
('Ca Mau'),
('Cao Lanh'),
('Hai Duong'),
('Hai Phong'),
('Hoa Binh'),
('Hung Yen'),
('Kon Tum'),
('Lai Chau'),
('Lang Son'),
('Lao Cai'),
('Phan Rang-Thap Cham'),
('Quang Ngai'),
('Soc Trang'),
('Son La'),
('Tam Ky'),
('Tan An'),
('Tuy Hoa'),
('Uong Bi'),
('Vi Thanh'),
('Yen Bai'),
('Bac Giang'),
('Bac Kan'),
('Bac Ninh'),
('Ben Tre'),
('Binh Dinh'),
('Binh Phuoc'),
('Binh Thuan'),
('Ca Mau'),
('Cao Bang'),
('Dak Lak'),
('Dak Nong'),
('Dien Bien Phu'),
('Dong Hoi'),
('Dong Ha'),
('Gia Nghia'),
('Ha Giang'),
('Ha Nam'),
('Ha Tinh'),
('Hoa Binh'),
('Hung Yen'),
('Kien Giang'),
('Lai Chau'),
('Lam Dong'),
('Lang Son'),
('Lao Cai'),
('Nam Dinh'),
('Nghe An'),
('Ninh Binh'),
('Ninh Thuan'),
('Phu Tho'),
('Phu Yen'),
('Quang Binh'),
('Quang Nam'),
('Quang Ninh'),
('Quang Tri'),
('Soc Trang'),
('Son La'),
('Tay Ninh'),
('Thai Binh'),
('Thai Nguyen'),
('Thanh Hoa'),
('Thua Thien Hue'),
('Tien Giang'),
('Tra Vinh'),
('Tuyen Quang'),
('Vinh Long'),
('Vinh Phuc'),
('Yen Bai');
