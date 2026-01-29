function validateVitals(data) {
  const {
    device_id,
    timestamp,
    thermal_value,
    battery_level,
    memory_usage,
  } = data;

  if (
    !device_id ||
    !timestamp ||
    thermal_value === undefined ||
    battery_level === undefined ||
    memory_usage === undefined
  ) {
    return { valid: false, error: 'Missing required fields' };
  }

  if (thermal_value < 0 || thermal_value > 3) {
    return { valid: false, error: 'Invalid thermal value' };
  }

  if (battery_level < 0 || battery_level > 100) {
    return { valid: false, error: 'Invalid battery level' };
  }

  if (memory_usage < 0 || memory_usage > 100) {
    return { valid: false, error: 'Invalid memory usage' };
  }

  const now = new Date();
  const receivedTime = new Date(timestamp);

  if (receivedTime > now) {
    return { valid: false, error: 'Timestamp cannot be in the future' };
  }

  return { valid: true };
}

function calculateAnalytics(rows) {
  if (!rows || rows.length === 0) {
    return {
      count: 0,
      rolling_average: null,
      min: null,
      max: null,
    };
  }

  const totals = { thermal: 0, battery: 0, memory: 0 };

  let min = {
    thermal: rows[0].thermal_value,
    battery: rows[0].battery_level,
    memory: rows[0].memory_usage,
  };

  let max = { ...min };

  rows.forEach((row) => {
    totals.thermal += row.thermal_value;
    totals.battery += row.battery_level;
    totals.memory += row.memory_usage;

    min.thermal = Math.min(min.thermal, row.thermal_value);
    min.battery = Math.min(min.battery, row.battery_level);
    min.memory = Math.min(min.memory, row.memory_usage);

    max.thermal = Math.max(max.thermal, row.thermal_value);
    max.battery = Math.max(max.battery, row.battery_level);
    max.memory = Math.max(max.memory, row.memory_usage);
  });

  return {
    count: rows.length,
    rolling_average: {
      thermal: totals.thermal / rows.length,
      battery: totals.battery / rows.length,
      memory: totals.memory / rows.length,
    },
    min,
    max,
  };
}

module.exports = {
  validateVitals,
  calculateAnalytics,
};
