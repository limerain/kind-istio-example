import express from 'express';
import { v4 } from 'uuid';
import { Low } from 'lowdb';
import { JSONFile } from 'lowdb/node';

// // File path
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import cors from 'cors';

const __dirname = dirname(fileURLToPath(import.meta.url));
const file = join(__dirname, 'db.json');
const adapter = new JSONFile(file);
const db = new Low(adapter);

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.use(cors());

app.get('/user', async (req, res) => {
  await db.read();
  res.json({
    user: db.data.user,
  });
});

app.get('/user/:id', async (req, res) => {
  await db.read();
  const filteredUser = db.data.user.filter((data) => {
    return data.id === req.params.id;
  });

  res.json(filteredUser[0]);
});

app.post('/user/', async (req, res) => {
  if (!req.body.name) {
    res.status(500);
    return;
  }
  await db.read();
  const uuid = v4();

  db.data.user.push({
    id: uuid,
    name: req.body.name,
  });
  await db.write();

  res.json({ id: uuid, name: req.body?.name });
});

app.listen(port, () => {
  console.log(`server is listening at localhost:${port}`);
});
