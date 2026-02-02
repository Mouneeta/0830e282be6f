# AI Collaboration Log

This document describes how AI tools were used during this assignment, following a transparent and responsible workflow.

---

## Prompt 1: Backend API Structure

**Prompt**:
"How can I build a simple Node.js Express API using SQLite that accepts POST requests and persists data after restart?"

**Result**:
AI suggested a basic Express server setup with SQLite integration and example CRUD operations.

**My Changes**:
- Adapted the structure to include only the required endpoints (`/api/vitals`, `/api/vitals/analytics`).
- Added strict validation rules according to the assignment (range checks, future timestamp rejection).
- Ensured persistence by initializing SQLite tables manually.

**Why it works**:
Express handles HTTP routing while SQLite provides lightweight persistent storage. This setup survives server restarts and keeps the backend simple and testable.

---

## Prompt 2: Rolling Average & Analytics Logic

**Prompt**:
"How should I calculate rolling average, min, and max values from sensor data in JavaScript?"

**Result**:
AI provided a basic loop-based calculation approach.

**My Changes**:
- Refactored the logic into a pure function (`calculateAnalytics`) inside `logic.js`.
- Added handling for empty datasets.
- Returned a structured analytics response including count, rolling average, min, and max values.

**Why it works**:
Using a pure function allows the analytics logic to be unit-tested independently from Express, improving reliability and maintainability.

---

## Prompt 3: Backend Validation & Testing

**Prompt**:
"How can I write Jest unit tests for backend validation and analytics logic in Node.js?"

**Result**:
AI suggested Jest-based unit tests covering valid and invalid input cases.

**My Changes**:
- Expanded test coverage to include edge cases such as future timestamps and missing fields.
- Ensured tests validate business logic instead of HTTP routes.

**Why it works**:
Testing pure logic functions ensures correctness without relying on network or database state.

---

