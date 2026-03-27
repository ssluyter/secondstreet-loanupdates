require('dotenv').config({ path: require('path').join(__dirname, '..', '.env') });
const express = require('express');
const cors = require('cors');
const path = require('path');
const { getApplicationByToken } = require('./digifi');

const app = express();
const PORT = process.env.PORT || 3001;
const CLIENT_URL = process.env.CLIENT_URL || 'http://localhost:5173';

// ── Middleware ──
app.use(cors({ origin: CLIENT_URL }));
app.use(express.json());

// ── Rate limiting (simple in-memory) ──
const rateLimitMap = new Map();
const RATE_LIMIT_WINDOW = 60 * 1000; // 1 minute
const RATE_LIMIT_MAX = 30; // requests per window

function rateLimit(req, res, next) {
  const ip = req.ip || req.connection.remoteAddress;
  const now = Date.now();
  const entry = rateLimitMap.get(ip);

  if (!entry || now - entry.start > RATE_LIMIT_WINDOW) {
    rateLimitMap.set(ip, { start: now, count: 1 });
    return next();
  }

  entry.count++;
  if (entry.count > RATE_LIMIT_MAX) {
    return res.status(429).json({ error: 'Too many requests. Please try again later.' });
  }
  next();
}

// ── API Routes ──

// GET /api/track/:token — fetch loan status by tracking token
app.get('/api/track/:token', rateLimit, async (req, res) => {
  const { token } = req.params;

  // Basic validation
  if (!token || token.length < 6 || token.length > 64) {
    return res.status(400).json({ error: 'Invalid tracking code.' });
  }

  // Sanitize — alphanumeric + hyphens only
  if (!/^[a-zA-Z0-9\-_]+$/.test(token)) {
    return res.status(400).json({ error: 'Invalid tracking code format.' });
  }

  try {
    const result = await getApplicationByToken(token);

    if (!result.success) {
      if (result.error === 'not_found') {
        return res.status(404).json({
          error: 'No loan found for this tracking code. The link may have expired or been revoked.',
        });
      }
      return res.status(502).json({
        error: 'Unable to retrieve loan status. Please try again later.',
      });
    }

    return res.json(result.data);
  } catch (err) {
    console.error('Track endpoint error:', err);
    return res.status(500).json({ error: 'An unexpected error occurred.' });
  }
});

// ── Health check ──
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// ── Serve React frontend in production ──
if (process.env.NODE_ENV === 'production') {
  const clientBuild = path.join(__dirname, '..', 'client', 'dist');
  app.use(express.static(clientBuild));

  // All non-API routes serve the React app (client-side routing)
  app.get('*', (req, res) => {
    if (!req.path.startsWith('/api')) {
      res.sendFile(path.join(clientBuild, 'index.html'));
    }
  });
}

// ── Start ──
app.listen(PORT, () => {
  console.log(`\n  ╔══════════════════════════════════════════╗`);
  console.log(`  ║  Second Street Status Tracker             ║`);
  console.log(`  ║  Server running on port ${PORT}              ║`);
  console.log(`  ║  API: http://localhost:${PORT}/api/track/:token  ║`);
  console.log(`  ╚══════════════════════════════════════════╝\n`);

  if (!process.env.DIGIFI_API_KEY || process.env.DIGIFI_API_KEY === 'your_digifi_api_key_here') {
    console.log('  ⚠  No Digifi API key configured — using mock data');
    console.log('  ⚠  Test with: /api/track/demo or /api/track/test\n');
  }
});
