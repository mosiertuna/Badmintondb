const express = require('express');
const path = require('path');
const app = express();
const port = 8081;
const { Client } = require('pg');
const client = new Client({
	user: 'postgres',
	password: '12345',
	host: 'localhost',
	port: '5432',
	database: 'Badmintondb',
});

client.connect();

app.use(express.static(__dirname));

app.get('/info', (req, res) => {
//TO_DO: VALIDATE INPUT, DATA LAYER PROTECTION

    client.query(`SELECT * FROM public."products" `, (err, result) => {
        if(err) console.log("error!");
        else console.log(result.rows);
        res.status(200).json({info: result.rows, maxpage: result.rowCount}); 
    })
})



app.get('/', (req, res) =>{
    const {parcel} = req.body;
    console.log(parcel);
    if(!parcel) return res.status(400).send("Status: Failed");
    res.status(200).send("Received");
})
app.listen(port, () => {
    console.log(`Server started on port : ${port}`);
})
