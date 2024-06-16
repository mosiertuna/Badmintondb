
--nếu khách hàng chưa có thì tạo mới, nếu đơn hàng chưa có thì tạo mới, nếu sản phẩm chưa có thì tạo mới--

CREATE OR REPLACE FUNCTION UPDATE_CART(
    CUS_ID IN INT,
    ORD_ID IN INT,
    PRD_ID IN INT, 
    QTT INT
)
RETURNS TABLE (
    NEW_CUSTOMER_ID INT,
    NEW_ORDER_ID INT,
    PRODUCT_ID INT
)
AS $$
BEGIN
    IF QTT > 0 THEN
    -- Check if CUS_ID is NULL
    IF CUS_ID IS NULL THEN
        -- Insert a new customer with empty fields
        INSERT INTO public."customers" (full_name, phone, email) VALUES ('','','');
        -- Retrieve the generated CUS_ID
        SELECT currval(pg_get_serial_sequence('public."customers"', 'customer_id')) INTO CUS_ID;
    END IF;

    -- Check if ORD_ID is NULL
    IF ORD_ID IS NULL THEN
        -- Insert a new order with initial state
        INSERT INTO public."orders" (status,customer_id) VALUES (0,CUS_ID);
        -- Retrieve the generated ORD_ID
        SELECT currval(pg_get_serial_sequence('public."orders"', 'order_id')) INTO ORD_ID;
    END IF;

    -- Check if an entry in the list exists for the given order and customer
    IF EXISTS (SELECT 1 FROM public."list" l WHERE l.order_id = ORD_ID AND l.product_id = PRD_ID) THEN
        -- Update the quantity for the existing entry
        UPDATE public."list" l
        SET quantity = QTT
        WHERE l.order_id = ORD_ID AND l.product_id = PRD_ID;
    ELSE
        -- Insert a new entry into the list
        INSERT INTO public."list"(order_id, product_id, quantity) 
        VALUES (ORD_ID, PRD_ID, QTT);
    END IF;
    -- Return the customer and order IDs
    RETURN QUERY SELECT CUS_ID, ORD_ID , PRD_ID ;

    END IF;
END;
$$
LANGUAGE 'plpgsql';


