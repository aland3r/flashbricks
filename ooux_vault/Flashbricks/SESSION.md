# SESSION

## Overview

The `SESSION` represents a dialogue session with AI Agent and Human, where they interact with vocabulary blocks to practice and review their collected bricks. Sessions track activity time, which influences memory rate calculations for vocabulary blocks reviewed during the session. Sessions

## Definition

### Name
**SESSION**

### Other Labels
**MEETING; Learning Session; Study Session; Practice Session**

### Purpose
Represents a discrete period of learning activity where a user (or learner with a tutor) engages with vocabulary blocks. Sessions track engagement metrics that feed into the spaced repetition algorithm.

## Attributes

### Core Content

| Attribute | Type | Description |
|-----------|------|-------------|
| `SESSION ID` | `bigint` | Unique identifier for each session instance. Primary key. |
| `activity_time` | `int` | Duration of active learning in seconds. Must be > 0. Used in memory_rate calculations for vocabulary blocks reviewed during this session. |

### Metadata

| Attribute | Type | Description |
|-----------|------|-------------|
| `HUMAN ID` | `bigint` | Foreign key to the Human (learner) who conducted this session. Required. |
| `tutor_id` | `bigint` | Foreign key to Human (tutor type) conducting the session. Optional - only present for tutor-led sessions. |
| `type` | `enum` | Session type classification. Values: `{remote, on_site}`. Determines whether session is conducted remotely or in-person. |
| `started_at` | `timestamp` | When the session began. Defaults to CURRENT_TIMESTAMP. |
| `ended_at` | `timestamp` | When the session ended. Nullable - set when session completes. |
| `created_at` | `timestamp` | System timestamp when session record was created. |
| `updated_at` | `timestamp` | System timestamp when session record was last updated. Auto-updated via trigger. |
| `deleted_at` | `timestamp` | Soft delete timestamp. Nullable - set when session is deleted. |

## Relationships

### HUMAN → SESSION
- **Type:** Directed Association
- **Label:** `conducts`
- **Multiplicity:** HUMAN (1) → SESSION (*)
- **Description:** A human (learner) can conduct multiple learning sessions. Each session belongs to one human.

### HUMAN (Tutor) → SESSION
- **Type:** Directed Association  
- **Label:** `tutors`
- **Multiplicity:** HUMAN[Tutor] (0..1) → SESSION (*)
- **Description:** Optional tutor relationship. A tutor can conduct multiple sessions. Sessions can be self-directed (no tutor) or tutor-led.

### SESSION → VOCABULARY
- **Type:** Association
- **Label:** `reviews`
- **Multiplicity:** SESSION (1) → VOCABULARY (*)
- **Description:** Sessions involve reviewing multiple vocabulary blocks. The `activity_time` from sessions influences the memory_rate calculation of vocabulary blocks reviewed during that session.

## Business Rules

### Constraints
- `activity_time` must be greater than 0
- `tutor_id` must reference a HUMAN with `human_type = 'tutor'` (if provided)
- `ended_at` must be >= `started_at` (if both are set)

### Session Types
- **Self-Directed**: `tutor_id` is NULL - learner conducts session independently
- **Tutor-Led**: `tutor_id` references a Tutor - structured learning session

### Session Location Types
- **Remote**: Session conducted online/virtually
- **On Site**: Session conducted in-person at a physical location

## Design Considerations

### Activity Time Tracking
- `activity_time` represents active engagement, not just session duration
- Used as engagement factor in vocabulary block memory_rate calculations
- Should reflect actual learning time, excluding breaks or idle time

### Session Duration
- Can be calculated as `ended_at - started_at` if both timestamps are set
- `activity_time` may differ from duration if session includes breaks
- `activity_time` focuses on productive learning time

### Tutor Relationship
- Optional - allows for both self-directed and guided learning
- Tutor validation ensures only tutor-type humans can be assigned
- Supports flexible learning models (independent study vs. structured tutoring)

## Related Documentation

- [VOCABULARY.md](./FLASHBRICK.md) - Vocabulary blocks reviewed in sessions
- [HUMAN.md](./HUMAN.md) - Learners and tutors who conduct sessions

