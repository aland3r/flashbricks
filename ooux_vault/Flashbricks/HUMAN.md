## Overview

The `HUMAN` class represents a learner or tutor in the Flashbricks language learning system. It represents a user who conducts learning practices, collects flashbricks, and engages with vocabulary blocks to improve language proficiency.

## Definition

### Name
**HUMAN**

### Other Labels
**Human; Learner; User; Tutor; Student**

### Purpose
Represents a person (learner or tutor) who uses the Flashbricks system to learn vocabulary. Humans conduct practices, collect flashbricks, and track their progress through spaced repetition.

## Attributes

### Identity Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | `bigint` | Unique identifier for each human instance. Primary key. |
| `name` | `string` | The human's full name or display name. Used for identification and personalization. |

### Metadata

| Attribute | Type | Description |
|-----------|------|-------------|
| `created_at` | `timestamp` | System timestamp when human record was created. |
| `updated_at` | `timestamp` | System timestamp when human record was last updated. Auto-updated via trigger. |
| `deleted_at` | `timestamp` | Soft delete timestamp. Nullable - set when human is deleted. |

## Relationships

### HUMAN → PRACTICE
- **Type:** Directed Association
- **Label:** `conducts`
- **Multiplicity:** HUMAN (1) → PRACTICE (*)
- **Description:** A human (learner) can conduct multiple learning practices. Each practice belongs to one human.

### HUMAN → LANGUAGE
- **Type:** Association with attributes
- **Label:** `speaks`
- **Multiplicity:** HUMAN (1..*) → LANGUAGE (*)
- **Description:** A human can speak multiple languages (native and learned). Each relationship tracks whether the language is native or learned, and the proficiency level for learned languages.

#### Relationship Metadata (HUMAN-LANGUAGE)

| Attribute | Type | Description |
|-----------|------|-------------|
| `is_native` | `boolean` | True if this language is the human's native language. False if it is a learned language. Each human should have exactly one native language. |
| `proficiency_level` | `enum` | CEFR proficiency level for learned languages. Values: `{A1, A2, B1, B2, C1, C2}`. Required for learned languages (`is_native = false`), null for native languages (`is_native = true`). |

### HUMAN → FLASHBRICK
- **Type:** Association with attributes
- **Label:** `learns`
- **Multiplicity:** HUMAN (0..*) → FLASHBRICK (*)
- **Description:** A human can learn multiple flashbricks. Each relationship tracks the human's individual progress on that specific flashbrick.

#### Relationship Metadata (HUMAN-FLASHBRICK)

| Attribute | Type | Description |
|-----------|------|-------------|
| `vocabulary_retention_index` (VRI) | `float` | Vocabulary Retention Index (0.0-1.0). Represents the probability that this human will successfully recall this flashbrick. Calculated based on the human's personal learning history with this flashbrick, including repetitions, practice activity_time, and time since last review. Updated per human per flashbrick. |

## Business Rules

### Constraints
- `name` must not be empty
- Each HUMAN must have exactly one language with `is_native = true`
- `proficiency_level` is required when `is_native = false` (learned language)
- `proficiency_level` must be null when `is_native = true` (native language)
- `proficiency_level` must use valid CEFR levels: A1, A2, B1, B2, C1, C2

### Human Types
- **Learner**: Default type - conducts practices and learns vocabulary
- **Tutor**: Specialized type - can tutor other humans and conduct guided practices

## Design Considerations

### Language Relationships
- Native language (`is_native = true`) determines default interface language
- Learned languages (`is_native = false`) track proficiency levels (A1-C2)
- Language proficiency influences content recommendations and difficulty adjustments
- Multiple learned languages can be associated with a human
- Each human should have exactly one native language

### Identity Management
- `id` is immutable once assigned
- `name` can be updated for personalization
- Soft delete allows data retention for analytics

### Relationships
- Human lifecycle is tied to Practices (learning activity)
- Human progress is tracked through collected Flashbricks
- Peer relationships enable social learning features

## Related Documentation

- [PRACTICE.md](./PRACTICE.md) - Practices conducted by humans
- [FLASHBRICK.md](./FLASHBRICK.md) - Flashbricks collected by humans
- [LANGUAGE.md](./LANGUAGE.md) - Languages spoken by humans