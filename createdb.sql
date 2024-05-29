CREATE TABLE SHIPPERS
(
  SHIPPER_ID SERIAL PRIMARY KEY,
  FULL_NAME VARCHAR(30) NOT NULL,
  PHONE_NUMBER VARCHAR(10) NOT NULL,
  STATUS INT NOT NULL,
  EMAIL VARCHAR(50) NOT NULL,
  CHECK(STATUS >= 0 AND STATUS <= 3)
);

CREATE TABLE CUSTOMERS
(
  CUSTOMER_ID SERIAL PRIMARY KEY,
  FULL_NAME VARCHAR(30) NOT NULL,
  PHONE VARCHAR(10) NOT NULL,
  EMAIL VARCHAR(100) NOT NULL
);

CREATE TABLE PRODUCTS
(
  PRODUCT_ID SERIAL PRIMARY KEY,
  NAME VARCHAR(30) NOT NULL,
  UNIT_PRICE MONEY NOT NULL,
  AMOUNT INT NOT NULL,
  TYPE INT NOT NULL,
  DESCRIPTION VARCHAR(1000) NOT NULL,
  CHECK(AMOUNT >= 0 AND TYPE >= 0 AND TYPE <= 5)
);

CREATE TABLE VOUCHERS
(
  VOUCHER_ID SERIAL PRIMARY KEY,
  VALID_UNTIL DATE NOT NULL,
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
  PRIMARY KEY (PRODUCT_ID, ORDER_ID),
  FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID),
  FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID),
  CHECK(QUANTITY >= 0)
);

CREATE TABLE DISCOUNT
(
  ORDER_ID INT NOT NULL,
  VOUCHER_ID INT NOT NULL,
  FOREIGN KEY (ORDER_ID) REFERENCES ORDERS(ORDER_ID),
  FOREIGN KEY (VOUCHER_ID) REFERENCES VOUCHERS(VOUCHER_ID)
);

CREATE TABLE PRODUCTS_BRAND
(
  BRAND INT NOT NULL,
  PRODUCT_ID INT NOT NULL,
  PRIMARY KEY (BRAND, PRODUCT_ID),
  FOREIGN KEY (PRODUCT_ID) REFERENCES PRODUCTS(PRODUCT_ID)
);
