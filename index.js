const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
  res.send('Aplikasi Logistik Zuhri Berjalan dengan Lancar!');
});

app.listen(port, () => {
  console.log(`Server aplikasi logistik sedang berjalan di http://localhost:${port}`);
});
