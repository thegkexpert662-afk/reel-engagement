# Reel Engagement Lab

Educational project for learning API design, automation simulation, activity logs and rate limiting.

**This project uses only dummy reels and dummy users. It does not connect to Instagram or automate real social-media engagement.**

## Backend

```bash
cd backend
npm install
npm start
```

Server: `http://localhost:4000`

### API

- `GET /api/reels/REEL001` — view the dummy reel
- `POST /api/reels/REEL001/like` — add one dummy like
- `POST /api/reels/REEL001/comment` — add one dummy comment
- `POST /api/simulator/run` — simulate dummy users

Example:

```json
{
  "reelId": "REEL001",
  "users": 10
}
```
