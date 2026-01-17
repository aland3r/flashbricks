# CONTENT

## Overview

The `CONTENT` class represents the original source material used as input for learning and creation of flashbricks in the Flashbricks language learning system. Content exists independently before flashbricks are created from it and continues to exist regardless of flashbrick creation.

## Definition

### Name
**CONTENT**

### Other Labels
**Content; Source; Material; Input; Context**

### Purpose
Represents the original material (videos, books, series, films, articles) that serves as the source for vocabulary extraction and flashbrick creation. A YouTube video, for example, exists before flashbricks are created from it and still exists without them. Content is the foundational input that enables vocabulary learning.

## Attributes

### Identity Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `content_id` | `bigint` | Unique identifier for each content instance. Primary key. |
| `title` | `string` | Title of the content (e.g., video title, book title, article headline). Used for identification and display. |
| `content_type` | `enum` | Type of content. Values: `{youtube_video, book, series, film, article, podcast, other}`. Determines how content is processed and displayed. |

### Source Material Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `url` | `string` | URL or identifier for accessing the content. For YouTube videos: video URL. For books: ISBN or book identifier. Nullable for physical materials. |
| `source_language` | `string` | Language code of the content (e.g., 'en', 'pt', 'de', 'fr'). Used to identify target language for vocabulary extraction. |
| `duration` | `int` | Duration in seconds (for videos/audio) or pages/chapters (for books). Nullable for non-timed content. |
| `description` | `text` | Description or summary of the content. Provides context for vocabulary extraction. Nullable. |

### Metadata

| Attribute | Type | Description |
|-----------|------|-------------|
| `created_at` | `timestamp` | System timestamp when content record was created. |
| `updated_at` | `timestamp` | System timestamp when content record was last updated. Auto-updated via trigger. |
| `deleted_at` | `timestamp` | Soft delete timestamp. Nullable - set when content is deleted. |

## Relationships

### CONTENT → FLASHBRICK
- **Type:** Directed Association
- **Label:** `derives`
- **Multiplicity:** CONTENT (1..*) → FLASHBRICK (*)
- **Description:** Content serves as the source for flashbrick creation. One content item can generate multiple flashbricks. Flashbricks are extracted from content through vocabulary identification and processing.

### CONTENT → LANGUAGE
- **Type:** Directed Association
- **Label:** `is_in`
- **Multiplicity:** CONTENT (1) → LANGUAGE (1)
- **Description:** Content (videos, books, series, films) is in a specific source language. This language determines the target language for flashbricks extracted from the content.

## Business Rules

### Constraints
- `title` must not be empty
- `content_type` must be a valid enum value
- `source_language` must be a valid language code (ISO 639-1 format, two-letter language code)
- `url` should be unique for content that can be uniquely identified by URL (e.g., YouTube videos)

### Content Types
- **YouTube Video**: Video content from YouTube platform
- **Book**: Written book material (print or digital)
- **Series**: Television or streaming series
- **Film**: Movie or film content
- **Article**: Written article or blog post
- **Podcast**: Audio podcast content
- **Other**: Other types of source material

## Design Considerations

### Content Independence
- Content exists independently of flashbricks
- A content item can exist without any flashbricks being created from it
- Multiple flashbricks can be extracted from a single content item
- Content lifecycle is independent of flashbrick lifecycle

### Source Material Processing
- Content is processed to extract vocabulary items
- Extraction process identifies words, phrases, and patterns from content
- Extracted vocabulary becomes flashbricks for learners
- Content serves as reference material for understanding context

### Relationships
- Content lifecycle is independent - it can be added, modified, or removed without affecting existing flashbricks
- Flashbricks reference their source content for context and reference
- One content item can support multiple learners through different flashbricks

## Related Documentation

- [FLASHBRICK.md](./FLASHBRICK.md) - Flashbricks derived from content
- [LANGUAGE.md](./LANGUAGE.md) - Languages used in content
