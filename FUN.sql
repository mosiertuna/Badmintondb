CREATE OR REPLACE FUNCTION UPDATE_CART(
    CUS_ID IN INT,
    ORD_ID IN INT,
    PRD_ID IN INT, 
    QTT INT,
    T INT
)
RETURNS TABLE (
    NEW_CUSTOMER_ID INT,
    NEW_ORDER_ID INT,
    PRODUCT_ID INT
)
AS $$
BEGIN
    IF QTT > 0 AND QTT <= (SELECT amount FROM public."products" p WHERE p.product_id = PRD_ID) THEN
    -- Check if CUS_ID is NULL
    IF CUS_ID IS NULL OR NOT EXISTS (SELECT 1 FROM public."customers" c WHERE c.customer_id = CUS_ID)  THEN
        -- Insert a new customer with empty fields
        INSERT INTO public."customers" (full_name, phone, email) VALUES ('','','');
        -- Retrieve the generated CUS_ID
        SELECT currval(pg_get_serial_sequence('public."customers"', 'customer_id')) INTO CUS_ID;
    END IF;

    -- Check if ORD_ID is NULL
    IF ORD_ID IS NULL OR NOT EXISTS (SELECT 1 FROM public."orders" c WHERE c.order_id = ORD_ID) THEN
        -- Insert a new order with initial state
        INSERT INTO public."orders" (total_price,status,customer_id) VALUES (0,0,CUS_ID);
        -- Retrieve the generated ORD_ID
        SELECT currval(pg_get_serial_sequence('public."orders"', 'order_id')) INTO ORD_ID;
    END IF;

    -- Check if an entry in the list exists for the given order and customer
    IF EXISTS (SELECT 1 FROM public."list" l WHERE l.order_id = ORD_ID AND l.product_id = PRD_ID) THEN
        -- Update the quantity for the existing entry
        UPDATE public."list" l
        SET quantity = quantity*T + QTT
        WHERE l.order_id = ORD_ID AND l.product_id = PRD_ID;
    ELSE
        -- Insert a new entry into the list
        INSERT INTO public."list"(order_id, product_id, quantity) 
        VALUES (ORD_ID, PRD_ID, QTT);
    END IF;
    -- Return the customer and order IDs
    RETURN QUERY SELECT CUS_ID as cid, ORD_ID as oid, PRD_ID as pid;
    ELSIF QTT <= 0 THEN
       IF T = 0 THEN 
	   DELETE FROM public.discount
        WHERE order_id = ORD_ID
        AND voucher_id IN (
            SELECT v.voucher_id
            FROM public.vouchers v
            WHERE v.product_id = PRD_ID
        );
       DELETE FROM public."list" l WHERE l.product_id = PRD_ID;
	   
       END IF;
    
    END IF;
END;

$$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION SELECT_VOUCHER(
    ORD_ID INT,
    V_ID INT, 
    T INT
)
RETURNS VOID
AS $$
BEGIN
    IF T = 1 AND NOT EXISTS (SELECT 1 FROM public.discount WHERE order_id = ORD_ID AND voucher_id = V_ID) THEN
        INSERT INTO public."discount"(order_id, voucher_id) VALUES(ORD_ID, V_ID);
    ELSIF T = 0 THEN
        DELETE FROM public."discount" WHERE order_id = ORD_ID AND voucher_id = V_ID;
    END IF;
    
   
END;
$$
LANGUAGE plpgsql;
