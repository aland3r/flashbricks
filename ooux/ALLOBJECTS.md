# All Objects

## Overview

This document provides a brief overview of all objects in the Flashbricks language learning system. Each object represents a core concept in the vocabulary learning process.

## Objects

### FLASHBRICK

**Primary Purpose**: The core learning unit - a digital flashcard representing a vocabulary item (word or phrase).

**Key Characteristics**:
- Extracted from CONTENT sources (videos, books, series, films)
- Implements spaced repetition algorithm for optimized retention
- Tracks learning status, difficulty, and review intervals
- Each FLASHBRICK has a personalized vocabulary retention index (VRI) per HUMAN

**Relationships**:
- Derived from CONTENT (one content can generate many flashbricks)
- Learned by HUMANS (each human has their own VRI for each flashbrick)
- Reviewed in PRACTICES (practices contain multiple flashbricks)

**See**: [FLASHBRICK.md](./FLASHBRICK.md) for detailed documentation.

---

### CONTENT

**Primary Purpose**: Original source material used as input for learning and flashbrick creation.

**Key Characteristics**:
- Exists independently before flashbricks are created from it
- Can exist without any flashbricks (content can remain unused)
- Types include: YouTube videos, books, series, films, articles, podcasts
- Serves as the foundational source for vocabulary extraction

**Relationships**:
- Derives FLASHBRICKS (one content can generate multiple flashbricks)
- Independent lifecycle (not dependent on flashbricks)

**See**: [CONTENT.md](./CONTENT.md) for detailed documentation.

---

### HUMAN

**Primary Purpose**: Represents a learner or tutor who uses the Flashbricks system to learn vocabulary.

**Key Characteristics**:
- Can be a learner or tutor
- Has personal attributes: id, name
- Speaks multiple languages (native and learned) via LANGUAGE relationships
- Tracks proficiency levels for learned languages (A1-C2)
- Each HUMAN has individual progress on each FLASHBRICK (VRI stored per-human-per-flashbrick)

**Relationships**:
- Conducts PRACTICES (one human can conduct multiple practices)
- Learns FLASHBRICKS (has personalized VRI for each flashbrick)
- Speaks LANGUAGES (has one native language and multiple learned languages)

**See**: [HUMAN.md](./HUMAN.md) for detailed documentation.

---

### PRACTICE

**Primary Purpose**: Represents a discrete period of learning activity where a HUMAN engages with vocabulary blocks.

**Key Characteristics**:
- Dialogue session between AI Agent and HUMAN
- Tracks activity time for engagement metrics
- Can be self-directed or tutor-led
- Can be remote or on-site
- Activity time influences vocabulary retention index (VRI) calculations

**Relationships**:
- Conducted by HUMAN (one human can conduct multiple practices)
- Contains FLASHBRICKS (one practice reviews multiple flashbricks)
- Influences VRI calculations through activity_time tracking

**See**: [PRACTICE.md](./PRACTICE.md) for detailed documentation.

---

### LANGUAGE

**Primary Purpose**: Represents a language entity (e.g., English, German, French) that can be native or learned by humans, and targeted by flashbricks.

**Key Characteristics**:
- Has language code (ISO 639-1) and name
- Can be native or learned language for humans
- Proficiency levels (A1-C2) tracked for learned languages
- Each human has one native language and can have multiple learned languages

**Relationships**:
- Spoken by HUMANS (one human can speak multiple languages)
- Targeted by FLASHBRICKS (each flashbrick targets one language)
- Used in CONTENT (content is in a specific language)

**See**: [LANGUAGE.md](./LANGUAGE.md) for detailed documentation.

---

## Object Relationships Summary

```
CONTENT
  └─→ derives → FLASHBRICK
                    └─→ learned by → HUMAN
                    └─→ targets → LANGUAGE
                    └─→ reviewed in → PRACTICE
                                         └─→ conducted by → HUMAN
HUMAN
  └─→ speaks → LANGUAGE (native and learned)
```

**Flow**: CONTENT → FLASHBRICK → HUMAN (via PRACTICE)
- Content provides source material
- Flashbricks are extracted from content
- Humans learn flashbricks through practices
- Practices track engagement and influence VRI calculations
- Each human has personalized VRI for each flashbrick

## Related Documentation

- [FLASHBRICK.md](./FLASHBRICK.md) - Core learning unit documentation
- [CONTENT.md](./CONTENT.md) - Source material documentation
- [HUMAN.md](./HUMAN.md) - Learner/tutor documentation
- [PRACTICE.md](./PRACTICE.md) - Learning session documentation
- [LANGUAGE.md](./LANGUAGE.md) - Language entity documentation