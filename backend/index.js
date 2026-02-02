const express = require('express');
const db = require('./db');
const { validateVitals, calculateAnalytics } = require('./logic');

const app = express();
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

/* ------------------ POST vitals ------------------ */
app.post('/api/vitals', (req, res) => {
  const validation = validateVitals(req.body);

  if (!validation.valid) {
    return res.status(400).json({ error: validation.error });
  }

  const {
    device_id,
    timestamp,
    thermal_value,
    battery_level,
    memory_usage,
  } = req.body;

  // 1. Check for missing required fields
  const requiredFields = { device_id, timestamp, thermal_value, battery_level, memory_usage };
  for (const [field, value] of Object.entries(requiredFields)) {
    if (value === undefined || value === null) {
      return res.status(400).json({ error: `${field} is required` });
    }
  }

  // 2. Reject future timestamps
  const ts = new Date(timestamp);
  const now = new Date();
  if (ts > now) {
    return res.status(400).json({ error: 'Timestamp cannot be in the future' });
  }

  // 3. Validate ranges
  if (thermal_value < 0 || thermal_value > 3) {
    return res.status(400).json({ error: 'Thermal value must be between 0 and 3' });
  }

  if (battery_level < 0 || battery_level > 100) {
    return res.status(400).json({ error: 'Battery level must be between 0 and 100' });
  }

  if (memory_usage < 0 || memory_usage > 100) {
    return res.status(400).json({ error: 'Memory usage must be between 0 and 100' });
  }

  // 4. Insert into database
  const query = `
    INSERT INTO vitals
    (device_id, timestamp, thermal_value, battery_level, memory_usage)
    VALUES (?, ?, ?, ?, ?)
  `;

  db.run(
    query,
    [device_id, timestamp, thermal_value, battery_level, memory_usage],
    function (err) {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }

      return res.status(201).json({
        success: true,
        id: this.lastID,
      });
    }
  );
});

/* ------------------ GET vitals ------------------ */
app.get('/api/vitals', (req, res) => {
  // Get page and limit from query params, set defaults
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 100;

  if (limit > 100) limit = 100;
  const offset = (page - 1) * limit;

  const query = `
    SELECT device_id, timestamp, thermal_value, battery_level, memory_usage
    FROM vitals
    ORDER BY datetime(timestamp) DESC
    LIMIT ? OFFSET ?
  `;

  db.all(query, [limit, offset], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    // Optionally, get total count for pagination info
    db.get(`SELECT COUNT(*) as total FROM vitals`, (err, countResult) => {
      if (err) {
        return res.status(500).json({ error: 'Database error' });
      }

      return res.json({
        page,
        limit,
        total: countResult.total,
        totalPages: Math.ceil(countResult.total / limit),
        data: rows,
      });
    });
  });
});


/* ------------------ Analytics ------------------ */
app.get('/api/vitals/analytics', (req, res) => {
  const query = `
    SELECT thermal_value, battery_level, memory_usage
    FROM vitals
    ORDER BY datetime(timestamp) DESC
  `;

  db.all(query, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    const analytics = calculateAnalytics(rows);
    return res.json(analytics);
  });
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
