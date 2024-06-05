const express = require('express');
const path = require('path');
const app = express();
const port = 8081;
const { Client, Query } = require('pg');
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

app.get('/info', (req, res) => {
//TO_DO: VALIDATE INPUT, DATA LAYER PROTECTION

    client.query(`SELECT * FROM public."products"`, (err, result) => {
        if(err) console.log("error!");
        else console.log(result.rows);
        res.status(200).json({info: result.rows, maxpage: result.rowCount}); 
    })
})

app.get('/cart.html/info', (req, res) => {
    //TO_DO: VALIDATE INPUT, DATA LAYER PROTECTION
    
        client.query(`SELECT l.*, l.quantity * p.unit_price AS total FROM public."list" l JOIN public."products" p ON l.product_id = p.product_id`, (err, result) => {
            if(err) console.log("error!");
            else console.log(result.rows);
            res.status(200).json({info: result.rows, maxpage: result.rowCount}); 
        })
    })
/*    
app.get('/update_cart', (req, res) => {
        //TO_DO: VALIDATE INPUT, DATA LAYER PROTECTION
        
            client.query(query, (err, result) => {
                if(err) console.log("error!");
                else console.log("UPDATE SUCCESS");
                res.status(200).json({info: result}); 
            })
        })
*/
app.get('/', (req, res) =>{
    const {parcel} = req.body;
    console.log(parcel);
    if(!parcel) return res.status(400).send("Status: Failed");
    res.status(200).send("Received");
})
app.listen(port, () => {
    console.log(`Server started on port : ${port}`);
})
