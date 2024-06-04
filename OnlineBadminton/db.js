const { Client } = require('pg');

    const client = new Client({
        user: 'postgres',
        password: '12345',
        host: 'localhost',
        port: '5432',
        database: 'test',
    });

    client.connect().then(() => {
            console.log('Connected to PostgreSQL database');
            client.query('SELECT * FROM public."CUSTOMER"', (err, result) => {
                if (err) {
                    console.error('Error executing query', err);
                    client.end()
                    .then(() => {
                    console.log('Connection to PostgreSQL closed');
                    })
                    .catch((err) => {
                     console.error('Error closing connection', err);
                    });
                } else {
                    console.log('Query result:', result.rows);
                    client.end()
                    .then(() => {
                    console.log('Connection to PostgreSQL closed');
                    })
                    .catch((err) => {
                     console.error('Error closing connection', err);
                    });
                }
            });
        })
        .catch((err) => {
            console.error('Error connecting to PostgreSQL database', err);
            
        });
    
    
    