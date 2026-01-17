# LANGUAGE

## Overview

The `LANGUAGE` class represents a language entity in the Flashbricks language learning system. It represents a language (e.g., English, German, French, Portuguese) that can be associated with humans as their native or learned language, and with flashbricks as the target language for vocabulary learning.

## Definition

### Name
**LANGUAGE**

### Other Labels
**Language; Target Language; Source Language; Learning Language**

### Purpose
Represents a language that humans learn or already know, and the language that flashbricks target for vocabulary learning. A language can be a human's native language or a learned language, with associated proficiency levels.

## Attributes

### Identity Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `id` | `bigint` | Unique identifier for each language instance. Primary key. |
| `language_code` | `string` | ISO 639-1 two-letter language code (e.g., 'en', 'pt', 'de', 'fr', 'es'). Used for standardization and identification. Must be unique. |
| `name` | `string` | Full name of the language (e.g., 'English', 'Portuguese', 'German', 'French'). Used for display and user-friendly identification. |

### Language Type Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `is_native` | `boolean` | Indicates whether this language is a native language for a specific human. False indicates it is a learned language. This attribute exists in the HUMAN-LANGUAGE relationship. |
| `proficiency_level` | `enum` | CEFR proficiency level for learned languages. Values: `{A1, A2, B1, B2, C1, C2}`. Nullable - not applicable for native languages. This attribute exists in the HUMAN-LANGUAGE relationship for learned languages. |

### Metadata

| Attribute | Type | Description |
|-----------|------|-------------|
| `created_at` | `timestamp` | System timestamp when language record was created. |
| `updated_at` | `timestamp` | System timestamp when language record was last updated. Auto-updated via trigger. |
| `deleted_at` | `timestamp` | Soft delete timestamp. Nullable - set when language is deleted. |

## Relationships

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

### FLASHBRICK → LANGUAGE
- **Type:** Directed Association
- **Label:** `targets`
- **Multiplicity:** FLASHBRICK (1) → LANGUAGE (1)
- **Description:** Each flashbrick targets one specific language for vocabulary learning. The flashbrick's vocabulary item is in this target language.

### CONTENT → LANGUAGE
- **Type:** Directed Association
- **Label:** `is_in`
- **Multiplicity:** CONTENT (1) → LANGUAGE (1)
- **Description:** Content (videos, books, series, films) is in a specific source language. This language determines the target language for flashbricks extracted from the content.

## Business Rules

### Constraints
- `language_code` must be a valid ISO 639-1 two-letter code
- `language_code` must be unique
- `name` must not be empty
- `name` should be consistent (e.g., 'English' not 'english' or 'ENGLISH')
- Each HUMAN must have exactly one language with `is_native = true`
- `proficiency_level` is required when `is_native = false` (learned language)
- `proficiency_level` must be null when `is_native = true` (native language)

### Language Types
- **Native Language**: `is_native = true` - The human's first language or mother tongue
- **Learned Language**: `is_native = false` - A language the human is learning or has learned, with associated proficiency level (A1-C2)

### Proficiency Levels (CEFR)
- **A1**: Beginner - Basic user, can understand and use familiar everyday expressions
- **A2**: Elementary - Basic user, can understand sentences and common expressions
- **B1**: Intermediate - Independent user, can understand main points on familiar matters
- **B2**: Upper-Intermediate - Independent user, can understand complex text and communicate fluently
- **C1**: Advanced - Proficient user, can understand demanding texts and express ideas fluently
- **C2**: Mastery - Proficient user, can understand virtually everything and express spontaneously

## Design Considerations

### Language Identification
- `language_code` provides standardized identification (ISO 639-1)
- `name` provides user-friendly display names
- Both are necessary for different contexts (API vs UI)

### Native vs Learned Languages
- `is_native` attribute in HUMAN-LANGUAGE relationship distinguishes language types
- Each human should have exactly one native language
- Multiple learned languages can be associated with a human
- Proficiency levels only apply to learned languages

### Relationships
- Language lifecycle is independent - languages exist regardless of human or flashbrick associations
- Flashbricks target a specific language for vocabulary learning
- Content sources determine the language context for flashbrick extraction
- Humans can learn multiple languages with different proficiency levels

## Related Documentation

- [HUMAN.md](./HUMAN.md) - Humans who speak languages
- [FLASHBRICK.md](./FLASHBRICK.md) - Flashbricks targeting languages
- [CONTENT.md](./CONTENT.md) - Content in specific languages
