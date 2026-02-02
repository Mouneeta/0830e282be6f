# Design Decisions & Handling Ambiguity

This document outlines the ambiguities identified during development, the design decisions made, and the reasoning behind them.

---

## Ambiguity 1: Device Identifier Source

**Question**:  
How should a unique `device_id` be generated when the assignment does not specify how to obtain it?

**Options Considered**:
- **Option A**: Generate a random UUID inside the Flutter app.
- **Option B**: Create a device ID by concatenating current date and time.
- **Option C**: Retrieve a platform-specific unique device identifier via MethodChannel.

**Decision**:  
I chose **Option C** by retrieving `ANDROID_ID` via a native Android MethodChannel.

private fun getUniqueDeviceId(): String {
return Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID) ?: "unknown"
}


**Reasoning**:  
The assignment already requires native MethodChannel implementation. Using a platform-provided identifier ensures consistency across sessions and app restarts, which is important for meaningful historical analytics.

**Trade-offs**:
- `ANDROID_ID` may reset on factory reset.
- Platform-specific implementation (Android-only).

**Assumptions**:
- A stable per-device identifier is more valuable than a randomly generated one.
- This assignment prioritizes correctness and clarity over cross-platform uniformity.

---

## Ambiguity 2: Historical Data Fetching Strategy

**Question**:  
How should the History screen fetch up to 100 records efficiently?

**Options Considered**:
- **Option A**: Fetch all 100 records in a single API call.
- **Option B**: Implement pagination using page and limit parameters.
- **Option C**: Implement server-side streaming.

**Decision**:  
I chose **Option B**, implementing pagination on the backend API.

**Reasoning**:  
While fetching 100 records is acceptable for a small dataset, pagination scales better and reduces server load. This approach aligns with real-world production practices.

**Trade-offs**:
- Slightly increased API complexity.
- Requires additional client-side logic to manage pages.

**Assumptions**:
- Historical logs can grow over time.
- Pagination improves performance and user experience in production environments.

---

## Ambiguity 3: Analytics Time Window

**Question**:  
What time range should analytics (rolling average, min, max) be calculated over?

**Options Considered**:
- **Option A**: Calculate analytics over all historical records.
- **Option B**: Calculate analytics over the latest N records.
- **Option C**: Provide time-based analytics (hour/day/week).

**Decision**:  
I chose **Option B**, calculating analytics over the most recent records.

**Reasoning**:  
Recent device vitals are more relevant for understanding current device health. This approach also limits query size and improves performance.

**Trade-offs**:
- Older data does not influence analytics.
- Less historical trend visibility.

**Assumptions**:
- Users are more interested in recent device behavior.
- Simplicity and clarity are preferred over complex time-based analytics for this assignment.

---

## Questions I Would Ask a Product Manager

If clarification were available, I would ask:

1. Should analytics be calculated over a fixed time window or record count?
2. Is device identity expected to persist across app reinstalls?
3. Should historical logs be deletable or retained indefinitely?
4. What is the expected growth rate of vitals data per device?

These questions would help refine scalability, data retention, and analytics accuracy.

## Ambiguity 4: Platform Selection for Native Integration

**Question**:  
Which platform should be targeted for implementing native MethodChannel functionality?

**Options Considered**:
- **Option A**: Implement MethodChannel for both Android and iOS.
- **Option B**: Implement MethodChannel for Android only.
- **Option C**: Avoid native code and mock device-level data.

**Decision**:  
I chose **Option B**, implementing native functionality on Android only.

**Reasoning**:  
The assignment requires demonstrating native integration rather than cross-platform completeness. Android allows easier access to system-level identifiers such as `ANDROID_ID` without additional entitlements or permissions, making it suitable for a focused implementation within the assignment scope.

**Trade-offs**:
- iOS platform is not supported.
- Platform-specific code reduces cross-platform parity.

**Assumptions**:
- Demonstrating correct native integration is more valuable than partial implementations across platforms.
- The evaluation prioritizes technical correctness and clarity over platform coverage.


---

## Ambiguity 5: Backend Data Storage Selection

**Question**:  
What database should be used to persist device vitals data on the backend?

**Options Considered**:
- **Option A**: In-memory storage.
- **Option B**: SQLite.
- **Option C**: External database (PostgreSQL / MongoDB).

**Decision**:  
I chose **Option B**, using SQLite for data persistence.

**Reasoning**:  
SQLite provides lightweight, file-based persistence without requiring additional infrastructure. It ensures data survives server restarts while keeping the backend simple and easy to run locally, which aligns with assignment constraints.

**Trade-offs**:
- Limited scalability compared to external databases.
- Not suitable for high-concurrency production systems.

**Assumptions**:
- The backend will be run locally for evaluation.
- Simplicity and reproducibility are more important than horizontal scalability for this assignment.


## Summary

Where requirements were unclear, I made independent decisions guided by:
- Real-world mobile development practices
- Backend scalability considerations
- Assignment constraints and clarity

All trade-offs were intentional and documented.
