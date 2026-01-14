# Spaced Repetition Algorithm - Complete Documentation

## Overview

This document provides comprehensive documentation of the spaced repetition algorithm used in the Flashbricks system. The algorithm is inspired by Anki's approach but implements a custom formula that considers multiple factors including status transitions, time-based decay, and engagement metrics.

## Algorithm Purpose

The spaced repetition algorithm optimizes vocabulary learning by:
1. **Maximizing Retention**: Scheduling reviews at optimal intervals to prevent forgetting
2. **Minimizing Effort**: Reducing unnecessary reviews while maintaining high retention
3. **Adapting to Performance**: Adjusting difficulty and intervals based on individual performance
4. **Tracking Progress**: Providing measurable learning metrics through memory_rate

## Core Concepts

### Memory Rate
- **Definition**: Probability (0.0-1.0) that a learner will successfully recall a flashbrick
- **Purpose**: Primary metric for scheduling and progress tracking
- **Calculation**: See [Memory Rate Calculation](memory%20rate.md)

### Ease Factor
- **Definition**: Multiplier (typically 1.3-2.5) that determines interval growth
- **Default**: ~2.5 (Anki-inspired)
- **Adjustment**: 
  - Increases on successful reviews (easier card)
  - Decreases on failed reviews (harder card)
  - Formula: `new_ease = old_ease + adjustment`

### Interval
- **Definition**: Days until next scheduled review
- **Calculation**: `new_interval = previous_interval × ease_factor × difficulty_modifier`
- **Constraints**: Minimum 1 day, maximum based on system limits

### Repetitions
- **Definition**: Count of successful consecutive reviews
- **Purpose**: Indicates learning progress and influences interval calculations
- **Reset**: On review failure, transitions to forgotten state

## Algorithm Components

### 1. Memory Rate Calculation

The memory_rate is the foundation of the algorithm. It combines multiple factors:

```
memory_rate = clamp(
    base_retention × 
    time_modifier × 
    status_modifier × 
    engagement_modifier,
    0.0,
    1.0
)
```

**Components:**
- **Base Retention**: From repetitions, ease_factor, and difficulty
- **Time Modifier**: Exponential decay for overdue reviews
- **Status Modifier**: Adjustments based on learning phase
- **Engagement Modifier**: Based on session activity_time

See [Memory Rate Calculation Algorithm](memory%20rate.md) for detailed formulas.

### 2. Interval Calculation

The interval determines when a flashbrick should be reviewed next:

```
if status == 'new' or status == 'asleep':
    interval = 0  # Not scheduled
elif status == 'picked' or status == 'learning':
    interval = calculate_learning_interval(repetitions)  # Short intervals
elif status == 'review' or status == 'retained':
    interval = previous_interval × ease_factor × difficulty_modifier
elif status == 'relearning':
    interval = calculate_relearning_interval(repetitions)  # Recovery intervals
elif status == 'forgotten':
    interval = 0  # Not scheduled until relearning
```

**Learning Interval (picked/learning):**
```
interval = min(1, repetitions) days  # 1 day for first, then increasing
```

**Review Interval (review/retained):**
```
base_interval = previous_interval × ease_factor
difficulty_modifier = 1.0 - (difficulty × 0.2)  # Easier cards get longer intervals
interval = base_interval × difficulty_modifier
interval = max(1, min(interval, max_interval))  # Clamp to valid range
```

**Relearning Interval:**
```
interval = min(3, repetitions + 1) days  # Shorter intervals for recovery
```

### 3. Ease Factor Adjustment

Ease factor adapts based on review performance:

**On Successful Review:**
```
if performance == 'excellent':
    ease_adjustment = +0.15
elif performance == 'good':
    ease_adjustment = +0.10
elif performance == 'hard':
    ease_adjustment = -0.15
else:  # again
    ease_adjustment = -0.20

new_ease_factor = old_ease_factor + ease_adjustment
new_ease_factor = clamp(new_ease_factor, 1.3, 2.5)  # Reasonable bounds
```

**On Failed Review:**
```
ease_adjustment = -0.20
new_ease_factor = old_ease_factor + ease_adjustment
new_ease_factor = max(1.3, new_ease_factor)  # Minimum bound
```

### 4. Status Transition Logic

Status transitions are triggered by review outcomes:

```
function handle_review_result(flashbrick, result):
    if flashbrick.status == 'asleep':
        flashbrick.status = 'picked'
        flashbrick.repetitions = 0
    elif flashbrick.status == 'picked':
        if result == 'success':
            flashbrick.status = 'learning'
            flashbrick.repetitions = 1
        else:
            flashbrick.repetitions = 0  # Stay in picked
    elif flashbrick.status == 'learning':
        if result == 'success':
            flashbrick.repetitions += 1
            if flashbrick.repetitions >= MASTERY_THRESHOLD:  # e.g., 3-5
                flashbrick.status = 'review'
        else:
            flashbrick.repetitions = max(0, flashbrick.repetitions - 1)
    elif flashbrick.status == 'review':
        if result == 'success':
            flashbrick.repetitions += 1
            adjust_ease_factor(flashbrick, 'increase')
            if flashbrick.interval >= LONG_INTERVAL_THRESHOLD:  # e.g., 30 days
                flashbrick.status = 'retained'
        else:
            flashbrick.status = 'forgotten'
            flashbrick.repetitions = 0
            adjust_ease_factor(flashbrick, 'decrease')
    elif flashbrick.status == 'retained':
        if result == 'success':
            adjust_ease_factor(flashbrick, 'increase')
        else:
            flashbrick.status = 'forgotten'
            flashbrick.repetitions = 0
            adjust_ease_factor(flashbrick, 'decrease')
    elif flashbrick.status == 'forgotten':
        if result == 'attempt':  # User trying to relearn
            flashbrick.status = 'relearning'
            flashbrick.repetitions = 0
    elif flashbrick.status == 'relearning':
        if result == 'success':
            flashbrick.repetitions += 1
            if flashbrick.repetitions >= RECOVERY_THRESHOLD:  # e.g., 2-4
                flashbrick.status = 'review'
        else:
            flashbrick.repetitions = max(0, flashbrick.repetitions - 1)
    
    # Update timestamps and recalculate
    flashbrick.last_used = now()
    flashbrick.next_review_date = calculate_next_review_date(flashbrick)
    flashbrick.calculate_memory_rate()
```

### 5. Time-Based Decay (Time Count Modifier)

Time decay applies when reviews are overdue:

```
function calculate_time_modifier(flashbrick):
    days_since = (now() - flashbrick.last_used).days
    expected_interval = flashbrick.interval
    
    if days_since <= expected_interval:
        return 1.0  # On-time or early review
    else:
        days_overdue = days_since - expected_interval
        decay_rate = get_decay_rate(flashbrick)  # Default 0.15, can vary
        return exp(-decay_rate × days_overdue)
```

**Decay Rate Factors:**
- Base rate: 0.15 (default)
- Card difficulty: Harder cards may have higher decay
- User learning profile: Can be personalized
- Content type: Words vs. phrases may differ

### 6. Engagement-Based Adjustments

Session activity_time influences memory_rate:

```
function calculate_engagement_modifier(flashbrick):
    recent_sessions = get_recent_sessions(flashbrick, days=7)
    total_activity_time = sum(session.activity_time for session in recent_sessions)
    average_activity_time = total_activity_time / len(recent_sessions) if recent_sessions else 0
    
    engagement_threshold = 60  # seconds, configurable
    if average_activity_time > engagement_threshold:
        activity_bonus = min(0.2, (average_activity_time - engagement_threshold) / 300)
        return 1.0 + activity_bonus
    else:
        return 1.0
```

## Complete Algorithm Flow

### Review Session Flow

```
1. User initiates review session
2. System selects flashbricks based on:
   - next_review_date (overdue or due)
   - status (exclude asleep, forgotten)
   - memory_rate (prioritize low rates)
3. For each flashbrick in session:
   a. Present flashbrick to user
   b. Record activity_time
   c. User provides response (success/failure)
   d. Update flashbrick:
      - Update status based on result
      - Adjust ease_factor
      - Update repetitions
      - Update last_used timestamp
      - Recalculate memory_rate
      - Calculate new interval
      - Set next_review_date
   e. Store review result in history
4. End session, update session statistics
```

### Scheduling Algorithm

```
function schedule_reviews():
    due_flashbricks = get_flashbricks_where(
        next_review_date <= now() AND
        status IN ('picked', 'learning', 'review', 'retained', 'relearning')
    )
    
    # Prioritize by:
    # 1. Overdue status (most overdue first)
    # 2. Low memory_rate
    # 3. Status priority (learning > review > retained)
    
    prioritized = sort_by_priority(due_flashbricks)
    return prioritized
```

## Configuration Parameters

### Tunable Constants

| Parameter | Default | Description | Range |
|-----------|---------|-------------|-------|
| `INITIAL_EASE_FACTOR` | 2.5 | Starting ease factor for new cards | 1.3 - 2.5 |
| `MIN_EASE_FACTOR` | 1.3 | Minimum ease factor | 1.3 - 2.0 |
| `MAX_EASE_FACTOR` | 2.5 | Maximum ease factor | 2.0 - 3.0 |
| `DECAY_RATE` | 0.15 | Time decay rate for overdue reviews | 0.1 - 0.3 |
| `MASTERY_THRESHOLD` | 3 | Successful reviews needed to move from learning to review | 2 - 5 |
| `RECOVERY_THRESHOLD` | 2 | Successful reviews needed to move from relearning to review | 2 - 4 |
| `LONG_INTERVAL_THRESHOLD` | 30 | Days interval to transition to retained | 20 - 60 |
| `ENGAGEMENT_THRESHOLD` | 60 | Seconds of activity_time for engagement bonus | 30 - 120 |

## Performance Considerations

### Optimization Strategies

1. **Batch Calculations**: Recalculate memory_rate for multiple flashbricks in batch
2. **Caching**: Cache calculated intervals and next_review_dates
3. **Lazy Evaluation**: Only calculate when needed (on review, not on every query)
4. **Indexing**: Database indexes on next_review_date, status, memory_rate
5. **Background Jobs**: Periodic recalculation for overdue flashbricks

### Scalability

- Algorithm complexity: O(1) per flashbrick calculation
- Batch processing: O(n) for n flashbricks
- Database queries: Optimized with proper indexing
- Real-time updates: Efficient for individual reviews

## Testing and Validation

### Test Cases

1. **New Flashbrick**: Verify initial values and status transition
2. **Learning Phase**: Test mastery threshold and interval growth
3. **Review Phase**: Test ease factor adjustments and interval calculations
4. **Forgotten Recovery**: Test relearning process and recovery threshold
5. **Overdue Reviews**: Test time decay and penalty calculations
6. **Edge Cases**: Maximum intervals, minimum ease factors, rapid status changes

### Validation Metrics

- Retention rate: Percentage of successful reviews
- Review efficiency: Reviews per mastered flashbrick
- Time to mastery: Days from creation to retained status
- Forgetting rate: Percentage transitioning to forgotten

## Related Documentation

- [Flashbrick Class Model](./flashbrick-class.md)
- [Memory Rate Calculation Algorithm](memory%20rate.md)
- [Status State Machine](./flashbrick-status-states.md)

