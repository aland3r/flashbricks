# Vocabulary Retention Index (VRI) Calculation Algorithm

## Overview

The `vocabulary_retention_index` (VRI) is a float value (0.0-1.0) that represents the probability of a learner successfully recalling a Flashbrick during review. This document explains the algorithm used in the `calculate_vocabulary_retention_index()` operation. Note: VRI is calculated and stored per-human-per-flashbrick in the HUMAN-FLASHBRICK relationship.

## Purpose

The `vocabulary_retention_index` (VRI) serves multiple purposes:
- **Retention Probability**: Estimates likelihood of successful recall
- **Scheduling**: Determines when a flashbrick should be reviewed next
- **Progress Tracking**: Indicates mastery level and learning progress
- **Adaptive Learning**: Adjusts difficulty and intervals based on performance

## Output

- **Range**: 0.0 to 1.0 (inclusive)
- **Interpretation**:
  - `0.0`: Completely forgotten, needs immediate review
  - `0.25-0.3`: Poor retention, frequent reviews needed
  - `0.3-0.6`: Moderate retention, regular reviews
  - `0.6-0.8`: Good retention, spaced reviews
  - `0.8-1.0`: Excellent retention, long intervals between reviews
  - `1.0`: Mastered, maximum interval

- **User-Facing Labels**:
  - `0.0-0.24`: (No specific label - below threshold for "New")
  - `0.25-0.3`: **New** - Flashbrick is newly introduced or recently encountered
  - `0.4-0.9`: **Memorizing** - Flashbrick is in active learning phase, being memorized
  - `1.0`: **Memorized** - Flashbrick is fully mastered and memorized

## Input Factors

The calculation considers the following factors:

### 1. Current Status
The flashbrick's current state in the learning cycle affects the base calculation:
- **`asleep`**: No calculation (returns null or 0.0)
- **`new`**: Default initial value (typically 0.25)
- **`picked`/`learning`**: Based on initial performance
- **`review`/`retained`**: Full calculation with all factors
- **`forgotten`**: Reset to low value (typically 0.1-0.2)
- **`relearning`**: Recovery calculation with adjustments

### 2. Repetitions Count
- **Type**: `int` (number of successful consecutive reviews)
- **Impact**: Higher repetitions increase vocabulary_retention_index (VRI)
- **Formula Component**: `repetition_bonus = log(repetitions + 1) × 0.1`

### 3. Time Since Last Used
- **Source**: `last_used` (datetime)
- **Calculation**: `days_since = (now - last_used).days`
- **Impact**: Longer time since last review decreases vocabulary_retention_index (VRI) (forgetting curve)

### 4. Activity Time from Practices
- **Source**: `activity_time` from associated `Practice` objects
- **Impact**: Longer engagement time may indicate better understanding
- **Usage**: Weighted factor in engagement-based adjustments

### 5. Success/Failure History
- **Source**: Review performance records
- **Impact**: Recent failures decrease vocabulary_retention_index (VRI), successes increase it
- **Weight**: Recent reviews weighted more heavily than older ones

### 6. Interval (Expected Review Interval)
- **Type**: `int` (days)
- **Impact**: Used to determine if review is overdue
- **Usage**: Compares actual time elapsed vs. expected interval

### 7. Ease Factor
- **Type**: `float` (default ~2.5, Anki-inspired)
- **Impact**: Higher ease_factor indicates easier card, supports higher vocabulary_retention_index (VRI)
- **Adjustment**: Modified based on performance (decreases on failure, increases on success)

### 8. Difficulty Rating
- **Type**: `float` (0.0-1.0)
- **Impact**: Lower difficulty (easier card) supports higher vocabulary_retention_index (VRI)
- **Usage**: Modifies base calculation and interval adjustments

## Algorithm Overview

The vocabulary_retention_index (VRI) calculation uses a **custom formula** inspired by Anki's algorithm while allowing for system-specific adjustments.

### Base Formula Structure

```
vocabulary_retention_index (VRI) = base_retention × time_modifier × status_modifier × engagement_modifier
```

### Component Calculations

#### 1. Base Retention
```
base_retention = min(1.0, 
    initial_rate + 
    (repetitions × ease_factor × 0.05) + 
    (difficulty_modifier × 0.2)
)
```

Where:
- `initial_rate`: 0.5 for new cards, adjusted for status
- `difficulty_modifier`: (1.0 - difficulty) to invert scale
- Clamped to [0.0, 1.0] range

#### 2. Time Count Modifier

The time modifier applies exponential decay for overdue reviews:

```
if days_since <= interval:
    time_modifier = 1.0  # On-time or early review
else:
    days_overdue = days_since - interval
    decay_rate = 0.15  # Customizable per user/difficulty
    time_modifier = exp(-decay_rate × days_overdue)
```

**Behavior:**
- **On-time reviews**: No penalty (modifier = 1.0)
- **Overdue reviews**: Exponential decay based on days overdue
- **Decay rate**: Configurable (default 0.15), can be adjusted per user or card difficulty

#### 3. Status Modifier

Adjusts calculation based on current learning phase:

| Status | Modifier | Description |
|--------|----------|-------------|
| `new` | 0.5 | Default initial value |
| `asleep` | 0.0 | No calculation |
| `picked` | 0.6 | First interaction bonus |
| `learning` | 0.7 | Active learning phase |
| `review` | 1.0 | Normal calculation |
| `retained` | 1.0 | Normal calculation |
| `forgotten` | 0.15 | Penalty for forgetting |
| `relearning` | 0.8 | Recovery phase adjustment |

#### 4. Engagement Modifier

Based on `activity_time` from practices:

```
if average_activity_time > threshold:
    engagement_modifier = 1.0 + (activity_bonus × 0.1)
else:
    engagement_modifier = 1.0
```

Where `activity_bonus` is calculated from recent practice activity times.

### Complete Formula

```
vocabulary_retention_index = clamp(
    base_retention × 
    time_modifier × 
    status_modifier × 
    engagement_modifier,
    0.0,
    1.0
)
```

## Update Triggers

The `calculate_vocabulary_retention_index()` operation is called:

1. **After each review practice**: When a flashbrick is reviewed (success or failure)
2. **On status transitions**: When status changes (e.g., `learning` → `review`)
3. **Periodically for overdue reviews**: Background job recalculates overdue flashbricks
4. **On explicit request**: When user or system requests recalculation
5. **Before scheduling**: When determining next review date

## Custom Formula Implementation

The algorithm is designed to be customizable:

### Configurable Parameters

- **Decay rate**: Default 0.15, adjustable per user or card
- **Initial rate**: Default 0.5, can vary by content type
- **Ease factor adjustments**: Customizable increment/decrement amounts
- **Engagement thresholds**: Adjustable based on user behavior analysis
- **Status modifiers**: Can be tuned based on learning analytics

### Extension Points

The formula can be extended with:
- **Content type factors**: Different rates for words vs. phrases
- **Language-specific adjustments**: Account for language difficulty
- **User learning style**: Adapt to individual learning patterns
- **Time-of-day factors**: Consider optimal learning times
- **Contextual factors**: Adjust based on source material difficulty

## Example Calculations

### Example 1: New Flashbrick
- Status: `new`
- Repetitions: 0
- Days since last_used: 0
- Ease factor: 2.5
- Difficulty: 0.5

```
base_retention = 0.5 + (0 × 2.5 × 0.05) + (0.5 × 0.2) = 0.6
time_modifier = 1.0
status_modifier = 0.5
engagement_modifier = 1.0
vocabulary_retention_index (VRI) = 0.6 × 1.0 × 0.5 × 1.0 = 0.3
```

### Example 2: Well-Retained Flashbrick
- Status: `retained`
- Repetitions: 10
- Days since last_used: 5 (on-time, interval = 7)
- Ease factor: 2.8
- Difficulty: 0.3

```
base_retention = 0.5 + (10 × 2.8 × 0.05) + (0.7 × 0.2) = 0.5 + 1.4 + 0.14 = 2.04 → 1.0 (clamped)
time_modifier = 1.0 (on-time)
status_modifier = 1.0
engagement_modifier = 1.0
vocabulary_retention_index (VRI) = 1.0 × 1.0 × 1.0 × 1.0 = 1.0
```

### Example 3: Overdue Forgotten Flashbrick
- Status: `forgotten`
- Repetitions: 5 (reset on forgetting)
- Days since last_used: 20 (overdue, interval = 7)
- Ease factor: 2.0 (decreased due to failure)
- Difficulty: 0.7

```
base_retention = 0.5 + (5 × 2.0 × 0.05) + (0.3 × 0.2) = 0.5 + 0.5 + 0.06 = 1.06 → 1.0 (clamped)
time_modifier = exp(-0.15 × 13) = exp(-1.95) ≈ 0.14
status_modifier = 0.15
engagement_modifier = 1.0
vocabulary_retention_index (VRI) = 1.0 × 0.14 × 0.15 × 1.0 = 0.021 → 0.02 (clamped to minimum)
```

## Integration with Spaced Repetition

The vocabulary_retention_index (VRI) directly influences:
- **Next review date**: Higher rate = longer interval
- **Card scheduling**: Prioritizes low vocabulary_retention_index (VRI) cards
- **Difficulty adjustments**: Modifies ease_factor based on rate changes
- **Learning analytics**: Tracks progress over time

## Related Documentation

- [Flashbrick Class Model](./flashbrick-class.md)
- [Status State Machine](./flashbrick-status-states.md)
- [Spaced Repetition Algorithm](./spaced-repetition-algorithm.md)

