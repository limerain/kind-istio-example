import express from 'express';
import axios from 'axios';
import cors from 'cors';

const app = express();
const port = process.env.PORT || 3002;

app.use(express.json());

app.use(cors());

const userServer = process.env.userServer || 'localhost';
const scoreServer = process.env.scoreServer || 'localhost';
app.get('/ranking', async (req, res) => {
  const userRes = await axios.get(`http://${userServer}:3000/user/`);
  const scoreRes = await axios.get(`http://${scoreServer}:3001/score/`);

  const userInfo = userRes.data.user;
  const scoreInfo = scoreRes.data.score;

  const mapData = scoreInfo.map((eachScore) => {
    const user = userInfo.filter((eachUser) => {
      return eachUser.id === eachScore.id;
    })[0];
    return {
      name: user.name,
      score: eachScore.score,
    };
  });
  const ranking = mapData.sort((a, b) => {
    return b.score - a.score;
  });

  res.json({
    ranking: ranking,
  });
});

app.get('/ranking/:id', async (req, res) => {
  const userRes = await axios.get(`http://${userServer}:3000/user/`);
  const scoreRes = await axios.get(`http://${scoreServer}:3001/score/`);

  const userInfo = userRes.data.user;
  const scoreInfo = scoreRes.data.score;

  const mapData = scoreInfo.map((eachScore) => {
    const user = userInfo.filter((eachUser) => {
      return eachUser.id === eachScore.id;
    })[0];
    return {
      id: eachScore.id,
      name: user.name,
      score: eachScore.score,
    };
  });
  const ranking = mapData.sort((a, b) => {
    return b.score - a.score;
  });
  const myRanking =
    ranking.findIndex((eachRanking) => {
      return eachRanking.id === req.params.id;
    }) + 1;

  res.json({
    myRanking: myRanking,
  });
});

app.listen(port, () => {
  console.log(`server is listening at localhost:${port}`);
});
