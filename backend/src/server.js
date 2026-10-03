const express = require("express");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 4002;

const reels = new Map([
  ["REEL001", {
    id: "REEL001",
    title: "Demo Reel",
    likes: 0,
    comments: 0,
    activity: []
  }]
]);

const comments = [
  "Nice reel!",
  "Great video!",
  "Very informative!",
  "Amazing!",
  "Good content!"
];

app.get("/", (req, res) => {
  res.json({
    name: "Reel Engagement Lab",
    mode: "Educational Dummy Simulator",
    status: "running",
    port: PORT
  });
});

app.get("/api/reels/:id", (req, res) => {
  const reel = reels.get(req.params.id);
  if (!reel) return res.status(404).json({ error: "Dummy reel not found" });
  res.json(reel);
});

app.post("/api/reels/:id/like", (req, res) => {
  const reel = reels.get(req.params.id);
  if (!reel) return res.status(404).json({ error: "Dummy reel not found" });

  const userId = req.body.userId || "DUMMY_USER";
  reel.likes += 1;
  reel.activity.unshift({
    type: "like",
    userId,
    at: new Date().toISOString()
  });
  reel.activity = reel.activity.slice(0, 100);

  res.json({ success: true, likes: reel.likes });
});

app.post("/api/reels/:id/comment", (req, res) => {
  const reel = reels.get(req.params.id);
  if (!reel) return res.status(404).json({ error: "Dummy reel not found" });

  const userId = req.body.userId || "DUMMY_USER";
  const text = req.body.text ||
    comments[Math.floor(Math.random() * comments.length)];

  reel.comments += 1;
  reel.activity.unshift({
    type: "comment",
    userId,
    text,
    at: new Date().toISOString()
  });
  reel.activity = reel.activity.slice(0, 100);

  res.json({ success: true, comments: reel.comments, text });
});

app.post("/api/simulator/run", (req, res) => {
  const { reelId = "REEL001", users = 10 } = req.body;
  const reel = reels.get(reelId);

  if (!reel) return res.status(404).json({ error: "Dummy reel not found" });

  const count = Math.max(1, Math.min(Number(users) || 1, 100));

  for (let i = 1; i <= count; i++) {
    const userId = `BOT_USER_${String(i).padStart(3, "0")}`;
    reel.likes += 1;
    reel.activity.unshift({
      type: "like",
      userId,
      at: new Date().toISOString()
    });
  }

  reel.activity = reel.activity.slice(0, 100);

  res.json({
    success: true,
    mode: "dummy-only",
    simulatedUsers: count,
    likes: reel.likes,
    comments: reel.comments
  });
});

app.post("/api/simulator/comments", (req, res) => {
  const { reelId = "REEL001", users = 5 } = req.body;
  const reel = reels.get(reelId);

  if (!reel) return res.status(404).json({ error: "Dummy reel not found" });

  const count = Math.max(1, Math.min(Number(users) || 1, 50));

  for (let i = 1; i <= count; i++) {
    const userId = `BOT_USER_${String(i).padStart(3, "0")}`;
    const text = comments[(i - 1) % comments.length];

    reel.comments += 1;
    reel.activity.unshift({
      type: "comment",
      userId,
      text,
      at: new Date().toISOString()
    });
  }

  reel.activity = reel.activity.slice(0, 100);

  res.json({
    success: true,
    mode: "dummy-only",
    simulatedUsers: count,
    likes: reel.likes,
    comments: reel.comments
  });
});

app.listen(PORT, () => {
  console.log(`Reel Engagement Lab running on port ${PORT}`);
});
