## Overview

The `Flashbrick` class is the core learning unit in the Flashbricks language learning system. It represents a digital flashcard with multiple variants that implements a spaced repetition algorithm to optimize vocabulary retention and learning efficiency.

## Definition

### Name
**Flashbrick**

### Other Labels
**Flashbrick; Block; Language Unit; Phrase; Word; Idiom**

### Purpose
Represents a single vocabulary item (word or phrase) extracted from content contexts (videos, books, series, films) that learners review using spaced repetition to improve retention and mastery.

## Attributes

### Identity Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `flashbrick_id` | `int` | Unique identifier for each flashbrick instance. Primary key. |
| `label` | `int` | Numerical label for categorization, ordering, or grouping purposes. |

### Spaced Repetition Core Attributes

| Attribute          | Type       | Description                                                                                                                                                                             |
| ------------------ | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `memory_rate`      | `float`    | Calculated retention probability (0.0-1.0). Represents the likelihood that the learner will remember this flashbrick. Updated by `calculateMemoryRate()` operation.                   |
| `status`           | `enum`     | Current state in the learning cycle. Values: `{new, asleep, picked, learning, review, relearning, forgotten, retained}`. See [Status State Machine](#status-state-machine) for details. |
| `ease_factor`      | `float`    | Multiplier for interval calculation (default: ~2.5, Anki-inspired). Higher values indicate easier cards, resulting in longer intervals between reviews. Adjusts based on performance.   |
| `interval`         | `int`      | Days until next scheduled review. Calculated based on ease_factor, repetitions, and performance history.                                                                                |
| `repetitions`      | `int`      | Number of successful consecutive reviews. Increments with each successful review, resets on failure.                                                                                    |
| `difficulty`       | `float`    | Card difficulty rating (0.0-1.0). Lower values indicate easier cards. Influences ease_factor adjustments and initial interval calculations.                                             |
| `next_review_date` | `datetime` | Timestamp indicating when this flashbrick should be reviewed next. Used for scheduling and prioritization.                                                                              |

### Usage Tracking Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `average_usage_frequency` | `int` | Average frequency of reviews over time. May be renamed to `review_count` or `total_reviews` for clarity. |
| `last_used` | `datetime` | Timestamp of the most recent review or interaction. Critical for time-based decay calculations in memory_rate. |
| `created_at` | `datetime` | Timestamp when the flashbrick was first created from a Context source. |

## Operations

### `calculateMemoryRate(): void`

Calculates and updates the `memory_rate` attribute based on:
- Current `status`
- `repetitions` count
- Time elapsed since `last_used`
- `activity_time` from associated Sessions
- Success/failure history
- `interval` and `ease_factor`
- `difficulty` rating

**Algorithm Overview:**
- Base formula inspired by Anki's ease factor system
- Custom adjustments based on status transitions
- Time count modifier for overdue reviews
- Engagement-based adjustments from session activity_time

**Update Triggers:**
- After each review session
- When status transitions occur
- Periodically for overdue reviews
- When explicitly requested

See [Memory Rate Calculation Algorithm](memory%20rate.md) for detailed documentation.

## Relationships

### Context → Flashbrick
- **Type:** Directed Association
- **Label:** `derives`
- **Multiplicity:** Context (1..*) → Flashbrick (*)
- **Description:** Flashbricks are created from Context sources (YouTubeVideo, Book, Series, Film). One context can generate multiple flashbricks.

### PrivateCollection → Flashbrick
- **Type:** Aggregation
- **Label:** `contains`
- **Multiplicity:** PrivateCollection (1) → Flashbrick (*)
- **Description:** Flashbricks are organized into private collections. A collection can contain multiple flashbricks, and flashbricks can belong to collections.

### Session → Flashbrick
- **Type:** Association
- **Label:** `contains`
- **Multiplicity:** Session (1) → Flashbrick (*)
- **Description:** Learning sessions involve multiple flashbricks. Sessions track `activity_time` which influences memory_rate calculations.

## Status State Machine

### Status Definitions

| Status | Description | Memory Rate Behavior |
|--------|-------------|---------------------|
| `new` | Recently added/created (just collected from Context). Temporary state. | Default initial value (e.g., 0.5) |
| `asleep` | Never reviewed/activated. User may already know it or hasn't started learning it yet. | No calculation (null/0.0) - hasn't entered learning cycle |
| `picked` | First interaction - user has started reviewing it. Initial learning phase begins. | Calculated based on initial performance |
| `learning` | Active learning phase - multiple short-interval reviews. | Calculated based on initial performance with shorter intervals |
| `review` | In regular spaced repetition cycle - uses calculated intervals. | Full calculation with time modifiers |
| `retained` | Successfully mastered - long intervals. Can transition to forgotten if performance drops. | Full calculation with time modifiers, longer intervals |
| `forgotten` | Previously retained but failed review. | Reset or penalized memory_rate |
| `relearning` | Relearning after forgetting - shorter intervals than review. | Recalculated with recovery adjustments |

### Status Transitions

```
new → asleep → picked → learning → review → retained
                              ↓
                         forgotten → relearning → review
```

**Transition Rules:**
- `new` → `asleep`: Automatic transition after creation
- `asleep` → `picked`: User initiates first review
- `picked` → `learning`: After first successful review
- `learning` → `review`: After mastery threshold reached
- `review` → `retained`: After consistent successful reviews
- `review`/`retained` → `forgotten`: On review failure
- `forgotten` → `relearning`: User attempts to relearn
- `relearning` → `review`: After recovery threshold reached

## Attribute Usage in Spaced Repetition

### Interval Calculation
```
new_interval = previous_interval × ease_factor × difficulty_modifier
```

### Memory Rate Calculation
The `memory_rate` is calculated using a custom formula that considers:
1. **Base retention** from repetitions and ease_factor
2. **Time decay** based on days since last_used
3. **Status modifiers** that adjust based on current learning phase
4. **Engagement factors** from session activity_time

See [Memory Rate Calculation Algorithm](memory%20rate.md) for the complete formula.

## Design Considerations

### Attribute Naming
- Consider renaming `average_usage_frequency` to `review_count` or `total_reviews` for clarity
- `status` enum should be clearly documented with all possible values

### Data Types
- All datetime attributes should use consistent timezone handling
- Float precision should be sufficient for memory_rate calculations (typically 4-6 decimal places)
- Integer types should accommodate expected ranges (e.g., repetitions may grow large over time)

### Relationships
- Flashbrick lifecycle is tied to Context (source material)
- Flashbrick scheduling depends on Session activity
- Flashbrick organization depends on PrivateCollection structure

## Related Documentation

- [Memory Rate Calculation Algorithm](memory%20rate.md)
- [Status State Machine Details](./flashbrick-status-states.md)
- [Spaced Repetition Algorithm](./spaced-repetition-algorithm.md)

