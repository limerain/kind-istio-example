import express from 'express';
import { Low } from 'lowdb';
import { JSONFile } from 'lowdb/node';
import cors from 'cors';

// // File path
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
const __dirname = dirname(fileURLToPath(import.meta.url));
const file = join(__dirname, 'db.json');
const adapter = new JSONFile(file);
const db = new Low(adapter);
await db.read();

const app = express();
const port = process.env.PORT || 3001;

app.use(express.json());
app.use(cors());

app.get('/score', async (req, res) => {
  await db.read();
  res.json({
    score: db.data.score,
  });
});

app.get('/score/:id', async (req, res) => {
  await db.read();
  const filteredScore = db.data.score.filter((data) => {
    return data.id === req.params.id;
  });

  res.json({
    success: true,
    score: filteredScore,
  });
});

app.post('/score/:id', async (req, res) => {
  await db.read();
  db.data.score.push({ id: req.params.id, score: req.body?.score });
  await db.write();

  res.json({ id: req.params.id, score: req.body?.score });
});

app.listen(port, () => {
  console.log(`server is listening at localhost:${port}`);
});
