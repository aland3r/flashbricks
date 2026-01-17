# PRACTICE

## Overview

The `PRACTICE` represents an exercise session where a HUMAN trains and reviews FLASHBRICKS through various exercise types such as quizzes, dialogue sessions, translations, and other interactive learning activities. Practices track activity time and exercise performance, which influences vocabulary retention index (VRI) calculations for flashbricks reviewed during the practice.

## Definition

### Name
**PRACTICE**

### Other Labels
**Exercise; Training Session; Practice Session; Learning Exercise**

### Purpose
Represents a discrete exercise session where a human engages with flashbricks through interactive training activities. Practices provide various exercise formats (quiz, dialogue, translation) to reinforce vocabulary learning and improve retention. Each practice type offers different engagement methods to train flashbricks effectively.

## Attributes

### Identity Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | `bigint` | Unique identifier for each practice instance. Primary key. |

### Exercise Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `exercise_type` | `enum` | Type of exercise used in the practice. Values: `{quiz, dialogue, translation, other}`. Determines the format and interaction method for training flashbricks. |
| `activity_time` | `int` | Duration of active learning in seconds. Must be > 0. Represents actual engagement time during the exercise. Used in vocabulary retention index (VRI) calculations for flashbricks reviewed during this practice. |
| `score` | `float` | Performance score achieved in the practice (0.0-1.0). Represents the accuracy or success rate of the exercise. Nullable. |
| `questions_count` | `int` | Number of questions/exercises in the practice. Must be > 0. |
| `correct_answers` | `int` | Number of correct answers in the practice. Must be >= 0 and <= questions_count. |

### Metadata

| Attribute | Type | Description |
|-----------|------|-------------|
| `HUMAN ID` | `bigint` | Foreign key to the Human (learner) who conducted this practice. Required. |
| `started_at` | `timestamp` | When the practice began. Defaults to CURRENT_TIMESTAMP. |
| `ended_at` | `timestamp` | When the practice ended. Nullable - set when practice completes. |
| `created_at` | `timestamp` | System timestamp when practice record was created. |
| `updated_at` | `timestamp` | System timestamp when practice record was last updated. Auto-updated via trigger. |
| `deleted_at` | `timestamp` | Soft delete timestamp. Nullable - set when practice is deleted. |

## Exercise Types

### Quiz
- **Description**: Interactive question-and-answer format where humans test their knowledge of flashbricks
- **Examples**: Multiple choice, fill-in-the-blank, true/false questions
- **V1 Support**: ✅ Available in V1
- **Purpose**: Test recognition, recall, and understanding of vocabulary items

### Dialogue
- **Description**: Conversational practice session where humans engage in dialogue using flashbricks
- **Examples**: Role-playing, AI conversation partner, scenario-based dialogues
- **V1 Support**: ❌ Not available in V1
- **Purpose**: Practice vocabulary in conversational context and real-world usage

### Translation
- **Description**: Translation exercises between languages using flashbricks
- **Examples**: Word translation, sentence translation, bidirectional translation
- **V1 Support**: ❌ Not available in V1
- **Purpose**: Reinforce vocabulary understanding through translation practice

### Other
- **Description**: Future exercise types for vocabulary training
- **Examples**: Listening comprehension, writing exercises, pronunciation practice
- **V1 Support**: ❌ Not available in V1
- **Purpose**: Additional interactive methods for vocabulary training

**Note**: For V1, only `quiz` exercise type is supported. Other exercise types (dialogue, translation, other) will be available in future versions.

## Relationships

### HUMAN → PRACTICE
- **Type:** Directed Association
- **Label:** `conducts`
- **Multiplicity:** HUMAN (1) → PRACTICE (*)
- **Description:** A human (learner) can conduct multiple practice sessions. Each practice belongs to one human and represents their exercise session to train flashbricks.

### PRACTICE → FLASHBRICK
- **Type:** Association
- **Label:** `trains`
- **Multiplicity:** PRACTICE (1) → FLASHBRICK (*)
- **Description:** Practices train multiple flashbricks through exercises. The `activity_time`, `score`, and performance metrics from practices influence the vocabulary retention index (VRI) calculation of flashbricks reviewed during that practice.

## Business Rules

### Constraints
- `activity_time` must be greater than 0
- `exercise_type` must be a valid enum value
- `questions_count` must be greater than 0
- `correct_answers` must be >= 0 and <= `questions_count`
- `score` must be between 0.0 and 1.0 (if provided)
- `score` can be calculated as `correct_answers / questions_count`
- `ended_at` must be >= `started_at` (if both are set)

### Exercise Type Rules
- **V1**: Only `quiz` exercise type is supported
- **Future Versions**: `dialogue`, `translation`, and `other` exercise types will be available
- Exercise type determines the interaction format and scoring mechanism

### Performance Metrics
- `score` represents overall performance in the practice (0.0 = no correct answers, 1.0 = all correct)
- `activity_time` tracks actual engagement time during the exercise
- Performance metrics influence VRI calculations for trained flashbricks

## Design Considerations

### Exercise Type Extensibility
- Exercise types are designed to be extensible for future versions
- Each exercise type can have specific attributes and behaviors
- V1 focuses on quiz-based training with standardized scoring

### Activity Time Tracking
- `activity_time` represents active engagement during the exercise, not total session duration
- Should exclude breaks, thinking time without active interaction, or idle periods
- Used as engagement factor in vocabulary retention index (VRI) calculations

### Performance Scoring
- `score` provides feedback on practice performance
- Can be calculated automatically from `correct_answers` and `questions_count`
- Influences VRI calculations - better performance indicates stronger retention
- Score tracking enables progress monitoring and adaptive learning

### Practice Duration
- Can be calculated as `ended_at - started_at` if both timestamps are set
- `activity_time` may differ from duration if practice includes breaks or idle time
- `activity_time` focuses on productive learning time during the exercise

### Relationships
- Practice lifecycle is tied to HUMAN (learner conducting the practice)
- Practice performance directly impacts FLASHBRICK training and VRI updates
- Multiple practices can train the same flashbrick across different sessions

## Related Documentation

- [FLASHBRICK.md](./FLASHBRICK.md) - Flashbricks trained in practices
- [HUMAN.md](./HUMAN.md) - Humans who conduct practices
- [VOCABULARY RETENTION INDEX (VRI).md](./VOCABULARY%20RETENTION%20INDEX%20(VRI).md) - How practices influence VRI calculations
