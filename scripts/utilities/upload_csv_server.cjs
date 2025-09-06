const express = require('express');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = 3000;

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const dir = path.join(__dirname, 'data');
    if (!fs.existsSync(dir)) fs.mkdirSync(dir);
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    cb(null, 'afl_fantasy_2025_full.csv');
  }
});

const upload = multer({ storage });

app.post('/upload', upload.single('file'), (req, res) => {
  console.log('[UPLOAD] CSV received.');
  res.send({ status: 'success' });
});

app.listen(PORT, () => {
  console.log(`🚀 Upload server running on http://localhost:${PORT}`);
});
