# Flashbrick Status State Machine

## Overview

The Flashbrick `status` attribute represents the current state of a flashcard in the learning cycle. This document defines all possible status values, their meanings, transition rules, and how each status affects vocabulary retention index (VRI) calculation. The flashbrick has unique characteristics that differenciates it from the card behaviour, in a sense that it has sides or faces, that label viriants of the picked vocabulary brick.

## Status Enum Values

```
{new, asleep, picked, learning, review, relearning, forgotten, retained}
```

## Status Definitions

### 1. `new`

**Description**: Recently added/created flashbrick (just collected from CONTENT).

**Characteristics**:
- Temporary state immediately after creation
- Automatically transitions to `asleep` after initial creation
- Represents a flashbrick that has been extracted but not yet entered the learning cycle

**Vocabulary Retention Index (VRI) Behavior**:
- Default initial value: `0.5`
- No time-based decay applied
- Calculation uses status modifier of `0.5`

**Typical Duration**: Very short (seconds to minutes)

**Transition Rules**:
- **From**: Created from CONTENT
- **To**: `asleep` (automatic)

---

### 2. `asleep`

**Description**: Never reviewed/activated flashbrick. The user may already know the vocabulary item, or they simply haven't started learning it yet.

**Characteristics**:
- Hasn't entered the active learning cycle
- User may be familiar with the word/phrase (no need to learn)
- Or user hasn't initiated review yet
- No review history exists

**Vocabulary Retention Index (VRI) Behavior**:
- **No calculation** (returns `null` or `0.0`)
- Vocabulary retention index (VRI) is not meaningful for asleep flashbricks
- Status modifier: `0.0` (excluded from calculation)

**Typical Duration**: Indefinite (until user activates it)

**Transition Rules**:
- **From**: `new` (automatic), or user explicitly sets to asleep
- **To**: `picked` (when user initiates first review)

---

### 3. `picked`

**Description**: First interaction - user has started reviewing the flashbrick. Initial learning phase begins.

**Characteristics**:
- User has actively engaged with the flashbrick for the first time
- Marks the beginning of the learning journey
- Short intervals between reviews (minutes to hours)
- First review performance determines initial ease_factor

**Vocabulary Retention Index (VRI) Behavior**:
- Calculated based on initial performance
- Status modifier: `0.6` (slight bonus for engagement)
- Base calculation includes first review result
- Time modifier not heavily weighted (short intervals)

**Typical Duration**: Until first few successful reviews

**Transition Rules**:
- **From**: `asleep` (user initiates review)
- **To**: `learning` (after first successful review)

---

### 4. `learning`

**Description**: Active learning phase - multiple short-interval reviews to establish initial retention.

**Characteristics**:
- In the process of establishing memory
- Short review intervals (hours to 1-2 days)
- Multiple reviews needed before moving to spaced repetition
- Performance tracked to determine readiness for longer intervals

**Vocabulary Retention Index (VRI) Behavior**:
- Calculated based on performance during learning phase
- Status modifier: `0.7` (learning phase adjustment)
- Repetitions count starts accumulating
- Time modifier has less impact (short intervals)
- Ease_factor adjusts based on performance

**Typical Duration**: 3-7 reviews or until mastery threshold

**Transition Rules**:
- **From**: `picked` (after first successful review)
- **To**: `review` (after reaching mastery threshold - typically 3-5 successful consecutive reviews)

---

### 5. `review`

**Description**: In regular spaced repetition cycle - uses calculated intervals based on vocabulary retention index (VRI) and performance.

**Characteristics**:
- Established in the spaced repetition system
- Intervals calculated based on ease_factor, repetitions, and performance
- Standard review cycle with increasing intervals
- Full vocabulary retention index (VRI) calculation applies

**Vocabulary Retention Index (VRI) Behavior**:
- **Full calculation** with all factors:
  - Base retention from repetitions and ease_factor
  - Time modifier for overdue reviews
  - Status modifier: `1.0` (normal calculation)
  - Engagement modifier from practice activity
- Vocabulary retention index (VRI) directly influences next review interval
- Updates after each review

**Typical Duration**: Ongoing (primary state for active learning)

**Transition Rules**:
- **From**: `learning` (after mastery threshold), `relearning` (after recovery)
- **To**: 
  - `retained` (after consistent successful reviews with long intervals)
  - `forgotten` (on review failure)

---

### 6. `retained`

**Description**: Successfully mastered flashbrick - long intervals between reviews. Can transition back to forgotten if performance drops.

**Characteristics**:
- High vocabulary retention index (VRI, typically > 0.8)
- Long intervals between reviews (weeks to months)
- Consistent successful performance
- Considered "mastered" but still needs periodic review

**Vocabulary Retention Index (VRI) Behavior**:
- Full calculation with time modifiers
- Status modifier: `1.0` (normal calculation)
- High base retention due to many successful repetitions
- Time modifier important (long intervals, overdue penalties significant)
- Vocabulary retention index (VRI) should remain high (> 0.8)

**Typical Duration**: Ongoing with long intervals

**Transition Rules**:
- **From**: `review` (after consistent success with long intervals)
- **To**: `forgotten` (if review fails after long interval)

---

### 7. `forgotten`

**Description**: Previously retained flashbrick that failed review. Memory has decayed significantly.

**Characteristics**:
- Previously in `review` or `retained` state
- Failed a review (couldn't recall)
- Vocabulary retention index (VRI) significantly decreased
- Needs relearning process

**Vocabulary Retention Index (VRI) Behavior**:
- **Reset or penalized** vocabulary retention index (VRI)
- Status modifier: `0.15` (significant penalty)
- Base retention reset based on failure
- Repetitions may be reset or decreased
- Ease_factor decreased
- Time modifier may show significant decay if overdue

**Typical Duration**: Until user attempts relearning

**Transition Rules**:
- **From**: `review` or `retained` (on review failure)
- **To**: `relearning` (when user attempts to relearn)

---

### 8. `relearning`

**Description**: Relearning after forgetting - shorter intervals than review to recover lost knowledge.

**Characteristics**:
- Recovery phase after forgetting
- Shorter intervals than `review` state
- Focused on re-establishing retention
- Performance tracked to determine recovery

**Vocabulary Retention Index (VRI) Behavior**:
- **Recalculated with recovery adjustments**
- Status modifier: `0.8` (recovery phase adjustment)
- Base retention recalculated from current performance
- Time modifier less critical (shorter intervals)
- Ease_factor may be adjusted downward initially
- Vocabulary retention index (VRI) should improve with successful reviews

**Typical Duration**: Until recovery threshold reached (typically 2-4 successful reviews)

**Transition Rules**:
- **From**: `forgotten` (user attempts relearning)
- **To**: `review` (after recovery threshold - typically 2-4 successful consecutive reviews)

## Complete State Transition Diagram

```
                    [CONTENT creates]
                          ↓
                         new
                          ↓ (automatic)
                       asleep
                          ↓ (user initiates)
                        picked
                          ↓ (first success)
                      learning
                          ↓ (mastery threshold)
                       review ──────────┐
                          ↓             │
                      retained          │
                          ↓             │
                    (failure)           │
                          ↓             │
                     forgotten          │
                          ↓             │
                    (user relearns)     │
                          ↓             │
                    relearning ─────────┘
                          ↓ (recovery)
                       review
```

## Status Transition Rules Summary

| From Status | To Status | Trigger Condition |
|------------|-----------|-------------------|
| - | `new` | Flashbrick created from CONTENT |
| `new` | `asleep` | Automatic (after creation) |
| `asleep` | `picked` | User initiates first review |
| `picked` | `learning` | First successful review |
| `learning` | `review` | Mastery threshold reached (3-5 successful reviews) |
| `review` | `retained` | Consistent success with long intervals |
| `review` | `forgotten` | Review failure |
| `retained` | `forgotten` | Review failure after long interval |
| `forgotten` | `relearning` | User attempts to relearn |
| `relearning` | `review` | Recovery threshold reached (2-4 successful reviews) |

## Vocabulary Retention Index (VRI) Calculation by Status

| Status | Vocabulary Retention Index (VRI) Calculation | Status Modifier | Notes |
|--------|------------------------|-----------------|-------|
| `new` | Default initial (0.5) | 0.5 | Temporary state |
| `asleep` | No calculation (null/0.0) | 0.0 | Not in learning cycle |
| `picked` | Based on initial performance | 0.6 | First interaction bonus |
| `learning` | Based on initial performance | 0.7 | Short intervals |
| `review` | Full calculation | 1.0 | Standard spaced repetition |
| `retained` | Full calculation | 1.0 | Long intervals |
| `forgotten` | Reset/penalized | 0.15 | Significant penalty |
| `relearning` | Recovery calculation | 0.8 | Recovery adjustments |

## Implementation Considerations

### Status Persistence
- Status should be persisted in the database
- Status changes should be logged for analytics
- Status transitions should trigger vocabulary retention index (VRI) recalculation

### Status Validation
- Validate status transitions (prevent invalid state changes)
- Handle edge cases (e.g., multiple rapid status changes)
- Ensure status consistency with other attributes (e.g., repetitions)

### Status-Based Behavior
- Different UI indicators for each status
- Status-specific scheduling rules
- Status-based filtering and sorting
- Status-specific analytics and reporting

## Related Documentation

- [Flashbrick Class Model](./flashbrick-class.md)
- [Vocabulary Retention Index Calculation Algorithm](VOCABULARY%20RETENTION%20INDEX%20(VRI).md)
- [Spaced Repetition Algorithm](./spaced-repetition-algorithm.md)

