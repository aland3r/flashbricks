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
| `vocabulary_retention_index` (VRI)      | `float`    | Vocabulary Retention Index (0.0-1.0). Represents the likelihood that a learner will remember this flashbrick. Note: VRI is typically stored per-human-per-flashbrick in the HUMAN-FLASHBRICK relationship. This attribute may represent a default or aggregate value. Updated by `calculateVocabularyRetentionIndex()` operation.                   |
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
| `last_used` | `datetime` | Timestamp of the most recent review or interaction. Critical for time-based decay calculations in vocabulary retention index (VRI). |
| `created_at` | `datetime` | Timestamp when the flashbrick was first created from a CONTENT source. |

## Operations

### `calculateVocabularyRetentionIndex(): void`

Calculates and updates the `vocabulary_retention_index` (VRI) attribute based on:
- Current `status`
- `repetitions` count
- Time elapsed since `last_used`
- `activity_time` from associated Practices
- Success/failure history
- `interval` and `ease_factor`
- `difficulty` rating

**Algorithm Overview:**
- Base formula inspired by Anki's ease factor system
- Custom adjustments based on status transitions
- Time count modifier for overdue reviews
- Engagement-based adjustments from practice activity_time

**Update Triggers:**
- After each review practice
- When status transitions occur
- Periodically for overdue reviews
- When explicitly requested

See [Vocabulary Retention Index Calculation Algorithm](VOCABULARY%20RETENTION%20INDEX%20(VRI).md) for detailed documentation.

## Relationships

### CONTENT → Flashbrick
- **Type:** Directed Association
- **Label:** `derives`
- **Multiplicity:** CONTENT (1..*) → Flashbrick (*)
- **Description:** Flashbricks are created from CONTENT sources (YouTubeVideo, Book, Series, Film). One content can generate multiple flashbricks.

### PrivateCollection → Flashbrick
- **Type:** Aggregation
- **Label:** `contains`
- **Multiplicity:** PrivateCollection (1) → Flashbrick (*)
- **Description:** Flashbricks are organized into private collections. A collection can contain multiple flashbricks, and flashbricks can belong to collections.

### Practice → Flashbrick
- **Type:** Association
- **Label:** `contains`
- **Multiplicity:** Practice (1) → Flashbrick (*)
- **Description:** Learning practices involve multiple flashbricks. Practices track `activity_time` which influences vocabulary retention index (VRI) calculations.

### FLASHBRICK → LANGUAGE
- **Type:** Directed Association
- **Label:** `targets`
- **Multiplicity:** FLASHBRICK (1) → LANGUAGE (1)
- **Description:** Each flashbrick targets one specific language for vocabulary learning. The flashbrick's vocabulary item is in this target language.

### HUMAN → Flashbrick
- **Type:** Association with attributes
- **Label:** `learns`
- **Multiplicity:** HUMAN (0..*) → Flashbrick (*)
- **Description:** A human learns multiple flashbricks. Each relationship stores the human's individual vocabulary retention index (VRI) for that specific flashbrick. VRI is calculated per-human based on their personal learning history with the flashbrick.

## Status State Machine

### Status Definitions

| Status | Description | Vocabulary Retention Index (VRI) Behavior |
|--------|-------------|---------------------|
| `new` | Recently added/created (just collected from CONTENT). Temporary state. | Default initial value (e.g., 0.5) |
| `asleep` | Never reviewed/activated. User may already know it or hasn't started learning it yet. | No calculation (null/0.0) - hasn't entered learning cycle |
| `picked` | First interaction - user has started reviewing it. Initial learning phase begins. | Calculated based on initial performance |
| `learning` | Active learning phase - multiple short-interval reviews. | Calculated based on initial performance with shorter intervals |
| `review` | In regular spaced repetition cycle - uses calculated intervals. | Full calculation with time modifiers |
| `retained` | Successfully mastered - long intervals. Can transition to forgotten if performance drops. | Full calculation with time modifiers, longer intervals |
| `forgotten` | Previously retained but failed review. | Reset or penalized vocabulary retention index (VRI) |
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

### Vocabulary Retention Index (VRI) Calculation
The `vocabulary_retention_index` (VRI) is calculated using a custom formula that considers:
1. **Base retention** from repetitions and ease_factor
2. **Time decay** based on days since last_used
3. **Status modifiers** that adjust based on current learning phase
4. **Engagement factors** from practice activity_time

Note: VRI is typically calculated and stored per-human-per-flashbrick in the HUMAN-FLASHBRICK relationship.

See [Vocabulary Retention Index Calculation Algorithm](VOCABULARY%20RETENTION%20INDEX%20(VRI).md) for the complete formula.

## Design Considerations

### Attribute Naming
- Consider renaming `average_usage_frequency` to `review_count` or `total_reviews` for clarity
- `status` enum should be clearly documented with all possible values

### Data Types
- All datetime attributes should use consistent timezone handling
- Float precision should be sufficient for vocabulary retention index (VRI) calculations (typically 4-6 decimal places)
- Integer types should accommodate expected ranges (e.g., repetitions may grow large over time)

### Relationships
- Flashbrick lifecycle is tied to CONTENT (source material)
- Flashbrick scheduling depends on Practice activity
- Flashbrick organization depends on PrivateCollection structure

## Related Documentation

- [Vocabulary Retention Index Calculation Algorithm](VOCABULARY%20RETENTION%20INDEX%20(VRI).md)
- [Status State Machine Details](./flashbrick-status-states.md)
- [Spaced Repetition Algorithm](./spaced-repetition-algorithm.md)
- [LANGUAGE.md](./LANGUAGE.md) - Languages targeted by flashbricks

