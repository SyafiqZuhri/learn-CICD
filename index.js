const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Aplikasi Logistik Zuhri Berjalan dengan Lancar!');
});

// Tambahkan '0.0.0.0' di sini agar bisa diakses dari Windows
app.listen(port, '0.0.0.0', () => {
  console.log(`Server aplikasi logistik sedang berjalan di port ${port}`);
});
