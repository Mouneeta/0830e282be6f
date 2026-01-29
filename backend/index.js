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
  const query = `
    SELECT device_id, timestamp, thermal_value, battery_level, memory_usage
    FROM vitals
    ORDER BY datetime(timestamp) DESC
    LIMIT 100
  `;

  db.all(query, [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: 'Database error' });
    }

    return res.json({
      count: rows.length,
      data: rows,
    });
  });
});

/* ------------------ Analytics ------------------ */
app.get('/api/vitals/analytics', (req, res) => {
  const query = `
    SELECT thermal_value, battery_level, memory_usage
    FROM vitals
    ORDER BY datetime(timestamp) DESC
    LIMIT 10
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
