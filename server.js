const express = require('express');
const redis = require('redis');

const app = express();

// Ajaibnya Docker: Kita tidak perlu menulis IP, cukup sebut nama containernya!
const client = redis.createClient({
    url: 'redis://database-redis:6379'
});

client.on('error', (err) => console.log('Ada eror di database Redis', err));
client.connect();

app.get('/', async (req, res) => {
    // Mengambil dan menambah data kunjungan dari database
    let kunjungan = await client.get('kunjungan');
    if (!kunjungan) kunjungan = 0;
    kunjungan = parseInt(kunjungan) + 1;
    await client.set('kunjungan', kunjungan);
    
    res.send(`<h1>Halo Bos Zuhri! Aplikasi Web + Database Berhasil Tersambung. Total kunjungan: ${kunjungan} kali. 🔥</h1>`);
});

app.listen(8080, () => {
    console.log('Web menyala di port 8080!');
});
