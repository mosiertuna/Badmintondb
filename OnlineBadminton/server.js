const express = require('express');
const path = require('path');
const app = express();
const port = 8081;
const { Client, Query } = require('pg');
const { query, validationResult } = require('express-validator');

const client = new Client({
	user: 'postgres',
	password: '1',
	host: 'localhost',
	port: '5432',
	database: 'Store',
});
var small_url = "";

client.connect();

app.use(express.static(__dirname));

app.get('/getItemList', (req, res) => {
//TO_DO: VALIDATE INPUT, DATA LAYER PROTECTION
    var query = `SELECT * FROM public."products" WHERE 1=1`;
    const search_name = req.query.search_query;
    const price_range = req.query.Price_range;
    const product_type = req.query.Product_type;
    const brand = req.query.Brand_name;
    console.log(price_range);
    console.log(product_type);
    console.log(brand);
    let min = 0;
    let max = 0;
    if (price_range != null && price_range != '') {
            min = 500000*(1 + (price_range >=2)) *(price_range - (price_range >=2));
            max = min + 500000*(1 + (price_range >=2));
    } 
    query = `${query} AND product_name ~* '${search_name}' AND unit_price >= ${min}::money`;
    if(min < 3000000 && max > min) query = `${query} AND unit_price < ${max}::money`;
    if (product_type != null && product_type!= ''){
        query = `${query} AND type = ${product_type}`;
    }
    if (brand != null && brand != ''){
        query = `${query} AND brand_id = ${brand}`;
    }
    console.log(query);
    client.query(query, (err, result) => {
        if(err) console.log("error!");
        res.status(200).json({info: result.rows, maxpage: result.rowCount}); 
    })
})


app.get('/updateCart', (req, res) => {
    const user_id = req.query.customer_id;
    const oid = req.query.order_id;
    const pid = req.query.product_id;
    const q = req.query.quantity;
    client.query(`SELECT * FROM UPDATE_CART(${user_id}, ${oid}, ${pid}, ${q},1)`, (err, result) => {
        if (err) {
            console.log("error!");
            res.status(500).json({ error: "Database query failed" });
        } else {
            console.log(result.rows);
            res.status(200).json({ info: result.rows });
        }
    });
});

app.get('/cart.html/getCart', async (req, res) => {
    //TO_DO: VALIDATE INPUT, DATA LAYER PROTECTION
    const user_id = req.query.customer_id;
    const oid = req.query.order_id;

    try {
        // Execute both queries and wait for their completion
        const listResult = await client.query(`SELECT p.*, l.quantity, l.quantity * p.unit_price AS total FROM public."list" l JOIN public."products" p ON l.product_id = p.product_id WHERE l.order_id = ${oid}`);
        const currentDiscountResult =  await client.query(`SELECT voucher_id FROM public."discount" WHERE order_id = ${oid}`);
        const updateResult = await client.query(`UPDATE public.orders
        SET total_price = (
        SELECT SUM(p.unit_price * l.quantity) as t
        FROM public."orders" o
        JOIN public."list" l  ON o.order_id = l.order_id 
        JOIN public."products" p ON p.product_id = l.product_id
        WHERE o.order_id = ${oid} GROUP BY o.order_id 
    ) - 
        (
            SELECT COALESCE(SUM(L.quantity * P.unit_price * (V.percent_off / 100.0)), 0::money)
            FROM public.discount D
            JOIN public.vouchers V ON D.voucher_id = V.voucher_id
            JOIN public.list L ON L.order_id = D.order_id AND L.product_id = V.product_id
            JOIN public.products P ON P.product_id = L.product_id
            WHERE D.order_id = ${oid}
        )
        WHERE order_id = ${oid};`);
        const totalResult = await client.query(`SELECT total_price FROM public."orders" WHERE order_id = ${oid}`);

        const list = listResult.rows;
        const total = totalResult.rows;
        const currentDiscount = currentDiscountResult.rows;
        res.status(200).json({ info: list, Selected : currentDiscount, total_price: total });
    } catch (err) {
        console.error("Database query error:", err);
        res.status(500).json({ error: "Internal Server Error" });
    }
});


app.get('/cart.html/updateCart', (req, res) =>{
    const user_id = req.query.customer_id;
    const oid = req.query.order_id;
    const pid = req.query.product_id;
    const q = req.query.quantity;
    client.query(`SELECT * FROM UPDATE_CART(${user_id}, ${oid}, ${pid}, ${q},0)`, (err, result) => {
        if (err) {
            console.log("error!");
            res.status(500).json({ error: "Database query failed" });
        } else {
            console.log(result.rows);
            res.status(200).json({ info: result.rows });
        }
    });
})
app.listen(port, () => {
    console.log(`Server started on port : ${port}`);
})

app.get('/cart.html/getVouchers', (req, res) => {
    const user_id = req.query.customer_id;
    const oid = req.query.order_id;
    client.query(`SELECT 
    v.voucher_id,
    v.name,
    v.percent_off,
    p.product_name
FROM 
    public."vouchers" v 
JOIN 
    public."customer_vouchers" cv ON cv.voucher_id = v.voucher_id
JOIN 
    public."products" p ON p.product_id = v.product_id
JOIN 
    public."list" l ON l.product_id = v.product_id 
LEFT JOIN 
    public."discount" d ON d.voucher_id = v.voucher_id
LEFT JOIN 
    public."orders" o ON d.order_id = o.order_id AND o.customer_id = 1
WHERE 
    cv.customer_id = ${user_id}
    AND l.order_id = ${oid} 
    AND (o.order_id IS NULL OR o.status <= 0);
`, (err, result) => {
        if (err) {
            console.log("error!");
            res.status(500).json({ error: "Database query failed" });
        } else {
            console.log(result.rows);
            res.status(200).json({ info: result.rows });
        }
    });
});

app.get('/cart.html/selectVouchers', async(req, res) =>{
    const user_id = req.query.customer_id;
    const oid = req.query.order_id;
    const vid = req.query.voucher_id;
    const a = req.query.action;

    try {
        // Execute both queries and wait for their completion
        const selectResult = await client.query(`SELECT SELECT_VOUCHER(${oid}, ${vid}, ${a})`);
        const updateResult = await client.query(`UPDATE public.orders
        SET total_price = (
        SELECT SUM(p.unit_price * l.quantity) as t
        FROM public."orders" o
        JOIN public."list" l  ON o.order_id = l.order_id 
        JOIN public."products" p ON p.product_id = l.product_id
        WHERE o.order_id = ${oid} GROUP BY o.order_id 
    ) - 
        (
            SELECT COALESCE(SUM(L.quantity * P.unit_price * (V.percent_off / 100.0)), 0::money)
            FROM public.discount D
            JOIN public.vouchers V ON D.voucher_id = V.voucher_id
            JOIN public.list L ON L.order_id = D.order_id AND L.product_id = V.product_id
            JOIN public.products P ON P.product_id = L.product_id
            WHERE D.order_id = ${oid}
        )
        WHERE order_id = ${oid};`);
        const totalResult = await client.query(`SELECT total_price FROM public."orders" WHERE order_id = ${oid}`);
        const total = totalResult.rows;

        res.status(200).json({ total_price: total });
    } catch (err) {
        console.error("Database query error:", err);
        res.status(500).json({ error: "Internal Server Error" });
    }
    
})

app.get('/cart.html/getCities', (req, res) => {
    client.query(`SELECT * FROM public."cities"`, (err, result) => {
        if (err) {
            console.log("error!");
            res.status(500).json({ error: "Database query failed" });
        } else {
            console.log(result.rows);
            res.status(200).json({ info: result.rows });
        }
    });
});

app.get('/cart.html/confirmOrder', [
    query('customer_id').isInt().withMessage('Customer ID must be an integer'),
    query('full_name').isLength({ max: 40 }).withMessage('Full name must be at most 40 characters long'),
    query('phone').matches(/^[0-9]{10}$/).withMessage('Phone number must be 10 digits'),
    query('email').isEmail().isLength({ max: 100 }).withMessage('Email must be valid and at most 100 characters long'),
    query('address').isLength({ max: 50 }).withMessage('Address must be at most 50 characters long'),
    query('district').isLength({ max: 30 }).withMessage('District must be at most 30 characters long'),
    query('city_id').isInt().withMessage('City must be a valid integer'),
    query('postal_code').matches(/^[A-Za-z0-9]{5,10}$/).withMessage('Postal code must be 5 to 10 alphanumeric characters'),
    query('order_id').isInt().withMessage('Order ID must be an integer')
], async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
    }

    const {
        customer_id, full_name, phone, email, 
        address, district, city_id, postal_code, 
        order_id
    } = req.query;

    const queryText = `
        CALL confirm_order(
            $1, $2, $3, $4, $5, $6, $7, $8, $9
        )
    `;

    const values = [
        customer_id, full_name, phone, email, 
        address, district, city_id, postal_code, 
        order_id
    ];

    try {
        await client.query('BEGIN');
        await client.query(queryText, values);
        await client.query('COMMIT');
        res.status(200).json({ success: true, message: 'Order confirmed successfully' });
    } catch (error) {
        await client.query('ROLLBACK');
        console.error('Error confirming order:', error);
        res.status(500).json({ success: false, message: 'Error confirming order' });
    }
});

app.get('/orders.html/getOrders', async (req, res) => {
    const user_id = req.query.customer_id;
    client.query(`SELECT * FROM public."orders" o JOIN public."cities" c ON o.city_id = c.city_id WHERE customer_id = ${user_id}`, (err, result) => {
        if (err) {
            console.log("error!");
            res.status(500).json({ error: "Database query failed" });
        } else {
            console.log(result.rows);
            res.status(200).json({ info: result.rows });
        }
    });
});

app.get('/orders.html/cancelOrder', async (req, res) => {
    const oid = req.query.order_id;
    console.log(oid)
    try {
        // Execute both queries and wait for their completion
        await client.query(`UPDATE public."products" SET STATUS = 4 WHERE l.order_id = ${oid}`);
        await client.query(`DELETE FROM public."discount" d WHERE d.order_id IN (SELECT o.order_id FROM public."orders" o WHERE status = 4 AND o.order_id = ${oid})`);

    
    
        res.status(200).json({ info: '' });
    } catch (err) {
        console.error("Database query error:", err);
        res.status(500).json({ error: "Internal Server Error" });
    }
});


app.get('/orders.html/getCart', async (req, res) => {
    //TO_DO: VALIDATE INPUT, DATA LAYER PROTECTION
    const oid = req.query.order_id;

    try {
        // Execute both queries and wait for their completion
        const listResult = await client.query(`SELECT p.*, l.quantity, l.quantity * p.unit_price AS total FROM public."list" l JOIN public."products" p ON l.product_id = p.product_id WHERE l.order_id = ${oid}`);
        const totalResult = await client.query(`SELECT total_price FROM public."orders" WHERE order_id = ${oid}`);

        const list = listResult.rows;
        const total = totalResult.rows;
    
        res.status(200).json({ info: list, total_price: total });
    } catch (err) {
        console.error("Database query error:", err);
        res.status(500).json({ error: "Internal Server Error" });
    }
});