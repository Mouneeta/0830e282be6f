const { validateVitals, calculateAnalytics } = require('./logic');

describe('validateVitals', () => {
  const baseData = {
    device_id: 'device123',
    timestamp: new Date().toISOString(),
    thermal_value: 1,
    battery_level: 50,
    memory_usage: 50,
  };

  test('passes valid data', () => {
    const result = validateVitals(baseData);
    expect(result.valid).toBe(true);
  });

  test('fails missing device_id', () => {
    const result = validateVitals({ ...baseData, device_id: undefined });
    expect(result.valid).toBe(false);
    expect(result.error).toBe('Missing required fields');
  });

  test('fails invalid thermal_value', () => {
    const result = validateVitals({ ...baseData, thermal_value: 5 });
    expect(result.valid).toBe(false);
    expect(result.error).toBe('Invalid thermal value');
  });

  test('fails invalid battery_level', () => {
    const result = validateVitals({ ...baseData, battery_level: -1 });
    expect(result.valid).toBe(false);
    expect(result.error).toBe('Invalid battery level');
  });

  test('fails invalid memory_usage', () => {
    const result = validateVitals({ ...baseData, memory_usage: 120 });
    expect(result.valid).toBe(false);
    expect(result.error).toBe('Invalid memory usage');
  });

  test('fails future timestamp', () => {
    const futureDate = new Date(Date.now() + 1000000).toISOString();
    const result = validateVitals({ ...baseData, timestamp: futureDate });
    expect(result.valid).toBe(false);
    expect(result.error).toBe('Timestamp cannot be in the future');
  });
});

describe('calculateAnalytics', () => {
  test('returns nulls for empty rows', () => {
    const result = calculateAnalytics([]);
    expect(result.count).toBe(0);
    expect(result.rolling_average).toBeNull();
    expect(result.min).toBeNull();
    expect(result.max).toBeNull();
  });

  test('calculates correctly', () => {
    const rows = [
      { thermal_value: 1, battery_level: 50, memory_usage: 40 },
      { thermal_value: 3, battery_level: 70, memory_usage: 60 },
    ];

    const result = calculateAnalytics(rows);
    expect(result.count).toBe(2);
    expect(result.rolling_average.thermal).toBe(2);
    expect(result.rolling_average.battery).toBe(60);
    expect(result.rolling_average.memory).toBe(50);
    expect(result.min).toEqual({ thermal: 1, battery: 50, memory: 40 });
    expect(result.max).toEqual({ thermal: 3, battery: 70, memory: 60 });
  });
});
