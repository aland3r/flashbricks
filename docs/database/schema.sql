-- ============================================================================
-- Flashbricks Database Schema
-- PostgreSQL DDL for Flashbricks Language Learning Application
-- ============================================================================
-- This schema implements the UML class diagram using Single Table Inheritance
-- for Human and Context hierarchies, with proper relationships, constraints,
-- and indexes for optimal performance.
-- ============================================================================

-- Drop existing types and tables (for clean setup - use with caution in production)
-- DROP TABLE IF EXISTS ... CASCADE;
-- DROP TYPE IF EXISTS ... CASCADE;

-- ============================================================================
-- ENUM TYPES (Required before table definitions)
-- ============================================================================

-- Human status enum
CREATE TYPE human_status_enum AS ENUM (
    'active',
    'inactive',
    'suspended',
    'deleted'
);

-- Human type enum (discriminator for inheritance)
CREATE TYPE human_type_enum AS ENUM (
    'visitor',
    'client',
    'curator',
    'tutor',
    'editor',
    'agent'
);

-- Language proficiency level enum (CEFR)
CREATE TYPE proficiency_level_enum AS ENUM (
    'A1.1',
    'A1.2',
    'A2.1',
    'A2.2',
    'B1.1',
    'B1.2',
    'B2.1',
    'B2.2',
    'C1.1',
    'C1.2',
    'C2.1',
    'C2.2'
);

-- Context status enum
CREATE TYPE context_status_enum AS ENUM (
    
    'pending_review',
    'under_review',
    'published',
    'archived'
);

-- Context type enum (discriminator for inheritance)
CREATE TYPE context_type_enum AS ENUM (
    'audiovisual',
    'book'
);

-- Audiovisual type enum (discriminator for audiovisual subclasses)
CREATE TYPE audiovisual_type_enum AS ENUM (
    'series',
    'film',
    'youtube_video'
);

-- Flashbrick status enum
CREATE TYPE flashbrick_status_enum AS ENUM (
    'new',
    'asleep',
    'picked',
    'learning',
    'review',
    'relearning',
    'forgotten',
    'retained'
);

-- Plan reoccurrance enum
CREATE TYPE plan_reoccurrance_enum AS ENUM (
    'monthly',
    'annually'
);

-- Invoice status enum
CREATE TYPE invoice_status_enum AS ENUM (
    'pending',
    'paid',
    'failed',
    'refunded'
);

-- ============================================================================
-- TABLES
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Humans Table (Single Table Inheritance for Human hierarchy)
-- ----------------------------------------------------------------------------
CREATE TABLE humans (
    human_id BIGSERIAL PRIMARY KEY,
    human_type human_type_enum NOT NULL,
    public_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    bio VARCHAR(100),
    status human_status_enum NOT NULL DEFAULT 'active',
    username VARCHAR(255) NOT NULL UNIQUE,
    
    -- Type-specific attributes (nullable, only populated for relevant types)
    is_bot BOOLEAN,                    -- Visitor
    classes_taught INTEGER,             -- Tutor
    
    -- Foreign keys for relationships
    plan_id BIGINT,                    -- Client/Agent: associated plan
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,  -- Soft delete
    
    -- Constraints
    CONSTRAINT chk_visitor_is_bot CHECK (
        (human_type = 'visitor' AND is_bot IS NOT NULL) OR 
        (human_type != 'visitor' AND is_bot IS NULL)
    ),
    CONSTRAINT chk_tutor_classes CHECK (
        (human_type = 'tutor' AND classes_taught IS NOT NULL) OR 
        (human_type != 'tutor' AND classes_taught IS NULL)
    ),
    CONSTRAINT chk_client_plan CHECK (
        (human_type = 'client' AND plan_id IS NOT NULL) OR 
        (human_type != 'client')
    )
);

COMMENT ON TABLE humans IS 'Single table for all human types (visitor, client, curator, tutor, editor, agent)';
COMMENT ON COLUMN humans.human_type IS 'Discriminator for inheritance hierarchy';
COMMENT ON COLUMN humans.plan_id IS 'Foreign key to plans (for clients and agents)';

-- ----------------------------------------------------------------------------
-- Languages Table
-- ----------------------------------------------------------------------------
CREATE TABLE languages (
    language_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    proficiency_level proficiency_level_enum,
    is_native BOOLEAN NOT NULL DEFAULT FALSE,
    input_time INTEGER,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE languages IS 'Languages that can be learned or spoken';
COMMENT ON COLUMN languages.proficiency_level IS 'CEFR proficiency level';

-- ----------------------------------------------------------------------------
-- Contexts Table (Single Table Inheritance for Context hierarchy)
-- ----------------------------------------------------------------------------
CREATE TABLE contexts (
    context_id BIGSERIAL PRIMARY KEY,
    context_type context_type_enum NOT NULL,
    audiovisual_type audiovisual_type_enum,  -- Only for audiovisual contexts
    title VARCHAR(255) NOT NULL,
    is_original_title BOOLEAN NOT NULL DEFAULT TRUE,
    status context_status_enum NOT NULL DEFAULT 'draft',
    
    -- Audiovisual attributes (nullable, only for audiovisual contexts)
    isan INTEGER,                    -- International Standard Audiovisual Number
    
    -- Series-specific attributes
    unique_id INTEGER,               -- Series unique identifier
    duration INTEGER,                 -- Total duration in seconds
    episode_number INTEGER,          -- Episode number
    episode_duration INTEGER,         -- Episode duration in seconds
    
    -- YouTubeVideo-specific attributes
    link VARCHAR(500),               -- YouTube video URL
    
    -- Book-specific attributes
    isbn VARCHAR(20),                -- International Standard Book Number
    author VARCHAR(255),              -- Author name
    country VARCHAR(100),             -- Country of origin
    
    -- Audiobook-specific attributes
    audiobook_duration INTEGER,       -- Audiobook duration in seconds
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Constraints
    CONSTRAINT chk_audiovisual_type CHECK (
        (context_type = 'audiovisual' AND audiovisual_type IS NOT NULL) OR 
        (context_type != 'audiovisual' AND audiovisual_type IS NULL)
    ),
    CONSTRAINT chk_series_attributes CHECK (
        (audiovisual_type = 'series' AND unique_id IS NOT NULL AND episode_number IS NOT NULL) OR 
        (audiovisual_type != 'series')
    ),
    CONSTRAINT chk_youtube_link CHECK (
        (audiovisual_type = 'youtube_video' AND link IS NOT NULL) OR 
        (audiovisual_type != 'youtube_video')
    ),
    CONSTRAINT chk_book_isbn CHECK (
        (context_type = 'book' AND isbn IS NOT NULL) OR 
        (context_type != 'book')
    ),
    CONSTRAINT uk_contexts_link UNIQUE (link) WHERE link IS NOT NULL,
    CONSTRAINT uk_contexts_isbn UNIQUE (isbn) WHERE isbn IS NOT NULL
);

COMMENT ON TABLE contexts IS 'Single table for all context types (audiovisual: series/film/youtube_video, book: book/audiobook)';
COMMENT ON COLUMN contexts.context_type IS 'Discriminator: audiovisual or book';
COMMENT ON COLUMN contexts.audiovisual_type IS 'Discriminator for audiovisual subclasses: series, film, youtube_video';

-- ----------------------------------------------------------------------------
-- Subtitles Table
-- ----------------------------------------------------------------------------
CREATE TABLE subtitles (
    subtitle_id BIGSERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    language_id BIGINT NOT NULL,
    context_id BIGINT NOT NULL,
    start_time INTEGER,              -- Start timestamp in seconds
    end_time INTEGER,                -- End timestamp in seconds
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Foreign keys
    CONSTRAINT fk_subtitles_language FOREIGN KEY (language_id) 
        REFERENCES languages(language_id) ON DELETE CASCADE,
    CONSTRAINT fk_subtitles_context FOREIGN KEY (context_id) 
        REFERENCES contexts(context_id) ON DELETE CASCADE
);

COMMENT ON TABLE subtitles IS 'Subtitle content for audiovisual media';

-- ----------------------------------------------------------------------------
-- Transcripts Table
-- ----------------------------------------------------------------------------
CREATE TABLE transcripts (
    transcript_id BIGSERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    context_id BIGINT NOT NULL,
    language_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Foreign keys
    CONSTRAINT fk_transcripts_context FOREIGN KEY (context_id) 
        REFERENCES contexts(context_id) ON DELETE CASCADE,
    CONSTRAINT fk_transcripts_language FOREIGN KEY (language_id) 
        REFERENCES languages(language_id) ON DELETE CASCADE
);

COMMENT ON TABLE transcripts IS 'Transcript content derived from subtitles or audio';

-- ----------------------------------------------------------------------------
-- Flashbricks Table
-- ----------------------------------------------------------------------------
CREATE TABLE flashbricks (
    flashbrick_id BIGSERIAL PRIMARY KEY,
    status flashbrick_status_enum NOT NULL DEFAULT 'new',
    label INTEGER,
    memory_rate DOUBLE PRECISION NOT NULL DEFAULT 0.5,
    repetitions INTEGER NOT NULL DEFAULT 0,
    average_usage_frequency INTEGER,
    last_used TIMESTAMP WITH TIME ZONE,
    next_review_date TIMESTAMP WITH TIME ZONE,
    difficulty DOUBLE PRECISION NOT NULL DEFAULT 0.5,
    ease_factor DOUBLE PRECISION NOT NULL DEFAULT 2.5,
    interval INTEGER NOT NULL DEFAULT 0,
    context_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Foreign keys
    CONSTRAINT fk_flashbricks_context FOREIGN KEY (context_id) 
        REFERENCES contexts(context_id) ON DELETE CASCADE,
    
    -- Constraints
    CONSTRAINT chk_flashbrick_memory_rate CHECK (memory_rate >= 0.0 AND memory_rate <= 1.0),
    CONSTRAINT chk_flashbrick_difficulty CHECK (difficulty >= 0.0 AND difficulty <= 1.0),
    CONSTRAINT chk_flashbrick_repetitions CHECK (repetitions >= 0),
    CONSTRAINT chk_flashbrick_interval CHECK (interval >= 0),
    CONSTRAINT chk_flashbrick_ease_factor CHECK (ease_factor >= 1.3 AND ease_factor <= 2.5)
);

COMMENT ON TABLE flashbricks IS 'Core learning unit: digital flashcards for vocabulary learning';
COMMENT ON COLUMN flashbricks.memory_rate IS 'Retention probability (0.0-1.0), calculated by spaced repetition algorithm';
COMMENT ON COLUMN flashbricks.status IS 'Learning cycle status: new, asleep, picked, learning, review, relearning, forgotten, retained';
COMMENT ON COLUMN flashbricks.ease_factor IS 'Interval multiplier (Anki-inspired, default 2.5)';

-- ----------------------------------------------------------------------------
-- Sessions Table
-- ----------------------------------------------------------------------------
CREATE TABLE sessions (
    session_id BIGSERIAL PRIMARY KEY,
    activity_time INTEGER NOT NULL,  -- Duration in seconds
    human_id BIGINT NOT NULL,
    tutor_id BIGINT,                 -- Optional: tutor conducting session
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Foreign keys
    CONSTRAINT fk_sessions_human FOREIGN KEY (human_id) 
        REFERENCES humans(human_id) ON DELETE CASCADE,
    CONSTRAINT fk_sessions_tutor FOREIGN KEY (tutor_id) 
        REFERENCES humans(human_id) ON DELETE SET NULL,
    
    -- Constraints
    CONSTRAINT chk_sessions_activity_time CHECK (activity_time > 0),
    CONSTRAINT chk_sessions_tutor_type CHECK (
        tutor_id IS NULL OR 
        EXISTS (SELECT 1 FROM humans WHERE human_id = tutor_id AND human_type = 'tutor')
    )
);

COMMENT ON TABLE sessions IS 'Learning sessions where users interact with flashbricks';
COMMENT ON COLUMN sessions.activity_time IS 'Session duration in seconds';

-- ----------------------------------------------------------------------------
-- Private Collections Table
-- ----------------------------------------------------------------------------
CREATE TABLE private_collections (
    private_collection_id BIGSERIAL PRIMARY KEY,
    rate INTEGER,
    human_id BIGINT NOT NULL,
    context_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Foreign keys
    CONSTRAINT fk_private_collections_human FOREIGN KEY (human_id) 
        REFERENCES humans(human_id) ON DELETE CASCADE,
    CONSTRAINT fk_private_collections_context FOREIGN KEY (context_id) 
        REFERENCES contexts(context_id) ON DELETE CASCADE
);

COMMENT ON TABLE private_collections IS 'User private collections of flashbricks organized by context';

-- ----------------------------------------------------------------------------
-- POIs (Points of Interest) Table
-- ----------------------------------------------------------------------------
CREATE TABLE pois (
    poi_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE pois IS 'Points of interest within content or sessions';

-- ----------------------------------------------------------------------------
-- Plans Table
-- ----------------------------------------------------------------------------
CREATE TABLE plans (
    plan_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    reoccurrance plan_reoccurrance_enum NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE plans IS 'Subscription plans that unlock features (e.g., Agent access)';

-- ----------------------------------------------------------------------------
-- Invoices Table
-- ----------------------------------------------------------------------------
CREATE TABLE invoices (
    invoice_id BIGSERIAL PRIMARY KEY,
    cost DOUBLE PRECISION NOT NULL,
    charged_at TIMESTAMP WITH TIME ZONE NOT NULL,
    client_id BIGINT NOT NULL,
    plan_id BIGINT,
    status invoice_status_enum NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    -- Foreign keys
    CONSTRAINT fk_invoices_client FOREIGN KEY (client_id) 
        REFERENCES humans(human_id) ON DELETE CASCADE,
    CONSTRAINT fk_invoices_plan FOREIGN KEY (plan_id) 
        REFERENCES plans(plan_id) ON DELETE SET NULL,
    
    -- Constraints
    CONSTRAINT chk_invoices_cost CHECK (cost >= 0),
    CONSTRAINT chk_invoices_client_type CHECK (
        EXISTS (SELECT 1 FROM humans WHERE human_id = client_id AND human_type = 'client')
    )
);

COMMENT ON TABLE invoices IS 'Billing invoices for clients';

-- ============================================================================
-- FOREIGN KEY CONSTRAINTS (Additional relationships)
-- ============================================================================

-- Add foreign key for plans (referenced by humans)
ALTER TABLE humans
ADD CONSTRAINT fk_humans_plan FOREIGN KEY (plan_id) 
    REFERENCES plans(plan_id) ON DELETE SET NULL;

-- ============================================================================
-- JOIN TABLES (Many-to-Many Relationships)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Human-Language (speaks relationship)
-- ----------------------------------------------------------------------------
CREATE TABLE human_languages (
    human_id BIGINT NOT NULL,
    language_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (human_id, language_id),
    CONSTRAINT fk_human_languages_human FOREIGN KEY (human_id) 
        REFERENCES humans(human_id) ON DELETE CASCADE,
    CONSTRAINT fk_human_languages_language FOREIGN KEY (language_id) 
        REFERENCES languages(language_id) ON DELETE CASCADE
);

COMMENT ON TABLE human_languages IS 'Many-to-many: Humans speak Languages';

-- ----------------------------------------------------------------------------
-- Human-Human (connects with relationship - self-referential)
-- ----------------------------------------------------------------------------
CREATE TABLE human_connections (
    human_id_1 BIGINT NOT NULL,
    human_id_2 BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (human_id_1, human_id_2),
    CONSTRAINT fk_human_connections_human1 FOREIGN KEY (human_id_1) 
        REFERENCES humans(human_id) ON DELETE CASCADE,
    CONSTRAINT fk_human_connections_human2 FOREIGN KEY (human_id_2) 
        REFERENCES humans(human_id) ON DELETE CASCADE,
    CONSTRAINT chk_human_connections_different CHECK (human_id_1 != human_id_2)
);

COMMENT ON TABLE human_connections IS 'Many-to-many self-referential: Humans connect with other Humans';

-- ----------------------------------------------------------------------------
-- Language-Context (provides relationship)
-- ----------------------------------------------------------------------------
CREATE TABLE language_contexts (
    language_id BIGINT NOT NULL,
    context_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (language_id, context_id),
    CONSTRAINT fk_language_contexts_language FOREIGN KEY (language_id) 
        REFERENCES languages(language_id) ON DELETE CASCADE,
    CONSTRAINT fk_language_contexts_context FOREIGN KEY (context_id) 
        REFERENCES contexts(context_id) ON DELETE CASCADE
);

COMMENT ON TABLE language_contexts IS 'Many-to-many: Languages provide Contexts';

-- ----------------------------------------------------------------------------
-- Session-Flashbrick (contains relationship)
-- ----------------------------------------------------------------------------
CREATE TABLE session_flashbricks (
    session_id BIGINT NOT NULL,
    flashbrick_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (session_id, flashbrick_id),
    CONSTRAINT fk_session_flashbricks_session FOREIGN KEY (session_id) 
        REFERENCES sessions(session_id) ON DELETE CASCADE,
    CONSTRAINT fk_session_flashbricks_flashbrick FOREIGN KEY (flashbrick_id) 
        REFERENCES flashbricks(flashbrick_id) ON DELETE CASCADE
);

COMMENT ON TABLE session_flashbricks IS 'Many-to-many: Sessions contain Flashbricks';

-- ----------------------------------------------------------------------------
-- POI-Session (relationship)
-- ----------------------------------------------------------------------------
CREATE TABLE poi_sessions (
    poi_id BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (poi_id, session_id),
    CONSTRAINT fk_poi_sessions_poi FOREIGN KEY (poi_id) 
        REFERENCES pois(poi_id) ON DELETE CASCADE,
    CONSTRAINT fk_poi_sessions_session FOREIGN KEY (session_id) 
        REFERENCES sessions(session_id) ON DELETE CASCADE
);

COMMENT ON TABLE poi_sessions IS 'Many-to-many: POIs are associated with Sessions';

-- ----------------------------------------------------------------------------
-- Transcript-Session (relationship)
-- ----------------------------------------------------------------------------
CREATE TABLE transcript_sessions (
    transcript_id BIGINT NOT NULL,
    session_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (transcript_id, session_id),
    CONSTRAINT fk_transcript_sessions_transcript FOREIGN KEY (transcript_id) 
        REFERENCES transcripts(transcript_id) ON DELETE CASCADE,
    CONSTRAINT fk_transcript_sessions_session FOREIGN KEY (session_id) 
        REFERENCES sessions(session_id) ON DELETE CASCADE
);

COMMENT ON TABLE transcript_sessions IS 'Many-to-many: Transcripts are part of Sessions';

-- ----------------------------------------------------------------------------
-- Subtitle-Flashbrick (uploads relationship)
-- ----------------------------------------------------------------------------
CREATE TABLE subtitle_flashbricks (
    subtitle_id BIGINT NOT NULL,
    flashbrick_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (subtitle_id, flashbrick_id),
    CONSTRAINT fk_subtitle_flashbricks_subtitle FOREIGN KEY (subtitle_id) 
        REFERENCES subtitles(subtitle_id) ON DELETE CASCADE,
    CONSTRAINT fk_subtitle_flashbricks_flashbrick FOREIGN KEY (flashbrick_id) 
        REFERENCES flashbricks(flashbrick_id) ON DELETE CASCADE
);

COMMENT ON TABLE subtitle_flashbricks IS 'Many-to-many: Subtitles upload/create Flashbricks';

-- ----------------------------------------------------------------------------
-- Editor-Transcript (checks relationship)
-- ----------------------------------------------------------------------------
CREATE TABLE editor_transcripts (
    editor_id BIGINT NOT NULL,
    transcript_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (editor_id, transcript_id),
    CONSTRAINT fk_editor_transcripts_editor FOREIGN KEY (editor_id) 
        REFERENCES humans(human_id) ON DELETE CASCADE,
    CONSTRAINT fk_editor_transcripts_transcript FOREIGN KEY (transcript_id) 
        REFERENCES transcripts(transcript_id) ON DELETE CASCADE,
    CONSTRAINT chk_editor_transcripts_editor_type CHECK (
        EXISTS (SELECT 1 FROM humans WHERE human_id = editor_id AND human_type = 'editor')
    )
);

COMMENT ON TABLE editor_transcripts IS 'Many-to-many: Editors check/review Transcripts';

-- ----------------------------------------------------------------------------
-- Curator-POI (relationship)
-- ----------------------------------------------------------------------------
CREATE TABLE curator_pois (
    curator_id BIGINT NOT NULL,
    poi_id BIGINT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (curator_id, poi_id),
    CONSTRAINT fk_curator_pois_curator FOREIGN KEY (curator_id) 
        REFERENCES humans(human_id) ON DELETE CASCADE,
    CONSTRAINT fk_curator_pois_poi FOREIGN KEY (poi_id) 
        REFERENCES pois(poi_id) ON DELETE CASCADE,
    CONSTRAINT chk_curator_pois_curator_type CHECK (
        EXISTS (SELECT 1 FROM humans WHERE human_id = curator_id AND human_type = 'curator')
    )
);

COMMENT ON TABLE curator_pois IS 'Many-to-many: Curators are associated with POIs';

-- ============================================================================
-- INDEXES
-- ============================================================================

-- Human indexes
CREATE INDEX idx_humans_type ON humans(human_type);
CREATE INDEX idx_humans_email ON humans(email);
CREATE INDEX idx_humans_username ON humans(username);
CREATE INDEX idx_humans_plan_id ON humans(plan_id);
CREATE INDEX idx_humans_deleted_at ON humans(deleted_at) WHERE deleted_at IS NULL;

-- Language indexes
CREATE INDEX idx_languages_name ON languages(name);
CREATE INDEX idx_languages_deleted_at ON languages(deleted_at) WHERE deleted_at IS NULL;

-- Context indexes
CREATE INDEX idx_contexts_type ON contexts(context_type);
CREATE INDEX idx_contexts_audiovisual_type ON contexts(audiovisual_type);
CREATE INDEX idx_contexts_status ON contexts(status);
CREATE INDEX idx_contexts_deleted_at ON contexts(deleted_at) WHERE deleted_at IS NULL;

-- Subtitle indexes
CREATE INDEX idx_subtitles_context_id ON subtitles(context_id);
CREATE INDEX idx_subtitles_language_id ON subtitles(language_id);
CREATE INDEX idx_subtitles_deleted_at ON subtitles(deleted_at) WHERE deleted_at IS NULL;

-- Transcript indexes
CREATE INDEX idx_transcripts_context_id ON transcripts(context_id);
CREATE INDEX idx_transcripts_language_id ON transcripts(language_id);
CREATE INDEX idx_transcripts_deleted_at ON transcripts(deleted_at) WHERE deleted_at IS NULL;

-- Flashbrick indexes
CREATE INDEX idx_flashbricks_context_id ON flashbricks(context_id);
CREATE INDEX idx_flashbricks_status ON flashbricks(status);
CREATE INDEX idx_flashbricks_next_review_date ON flashbricks(next_review_date) WHERE next_review_date IS NOT NULL;
CREATE INDEX idx_flashbricks_memory_rate ON flashbricks(memory_rate);
CREATE INDEX idx_flashbricks_deleted_at ON flashbricks(deleted_at) WHERE deleted_at IS NULL;

-- Session indexes
CREATE INDEX idx_sessions_human_id ON sessions(human_id);
CREATE INDEX idx_sessions_tutor_id ON sessions(tutor_id);
CREATE INDEX idx_sessions_started_at ON sessions(started_at);
CREATE INDEX idx_sessions_deleted_at ON sessions(deleted_at) WHERE deleted_at IS NULL;

-- Private Collection indexes
CREATE INDEX idx_private_collections_human_id ON private_collections(human_id);
CREATE INDEX idx_private_collections_context_id ON private_collections(context_id);
CREATE INDEX idx_private_collections_deleted_at ON private_collections(deleted_at) WHERE deleted_at IS NULL;

-- Invoice indexes
CREATE INDEX idx_invoices_client_id ON invoices(client_id);
CREATE INDEX idx_invoices_plan_id ON invoices(plan_id);
CREATE INDEX idx_invoices_charged_at ON invoices(charged_at);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_deleted_at ON invoices(deleted_at) WHERE deleted_at IS NULL;

-- Plan indexes
CREATE INDEX idx_plans_deleted_at ON plans(deleted_at) WHERE deleted_at IS NULL;

-- Join table indexes (for foreign keys)
CREATE INDEX idx_human_languages_human_id ON human_languages(human_id);
CREATE INDEX idx_human_languages_language_id ON human_languages(language_id);
CREATE INDEX idx_human_connections_human1 ON human_connections(human_id_1);
CREATE INDEX idx_human_connections_human2 ON human_connections(human_id_2);
CREATE INDEX idx_language_contexts_language_id ON language_contexts(language_id);
CREATE INDEX idx_language_contexts_context_id ON language_contexts(context_id);
CREATE INDEX idx_session_flashbricks_session_id ON session_flashbricks(session_id);
CREATE INDEX idx_session_flashbricks_flashbrick_id ON session_flashbricks(flashbrick_id);
CREATE INDEX idx_poi_sessions_poi_id ON poi_sessions(poi_id);
CREATE INDEX idx_poi_sessions_session_id ON poi_sessions(session_id);
CREATE INDEX idx_transcript_sessions_transcript_id ON transcript_sessions(transcript_id);
CREATE INDEX idx_transcript_sessions_session_id ON transcript_sessions(session_id);
CREATE INDEX idx_subtitle_flashbricks_subtitle_id ON subtitle_flashbricks(subtitle_id);
CREATE INDEX idx_subtitle_flashbricks_flashbrick_id ON subtitle_flashbricks(flashbrick_id);
CREATE INDEX idx_editor_transcripts_editor_id ON editor_transcripts(editor_id);
CREATE INDEX idx_editor_transcripts_transcript_id ON editor_transcripts(transcript_id);
CREATE INDEX idx_curator_pois_curator_id ON curator_pois(curator_id);
CREATE INDEX idx_curator_pois_poi_id ON curator_pois(poi_id);

-- ============================================================================
-- TRIGGERS FOR UPDATED_AT
-- ============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at
CREATE TRIGGER update_humans_updated_at BEFORE UPDATE ON humans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_languages_updated_at BEFORE UPDATE ON languages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_contexts_updated_at BEFORE UPDATE ON contexts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subtitles_updated_at BEFORE UPDATE ON subtitles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transcripts_updated_at BEFORE UPDATE ON transcripts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_flashbricks_updated_at BEFORE UPDATE ON flashbricks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_sessions_updated_at BEFORE UPDATE ON sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_private_collections_updated_at BEFORE UPDATE ON private_collections
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pois_updated_at BEFORE UPDATE ON pois
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_plans_updated_at BEFORE UPDATE ON plans
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_invoices_updated_at BEFORE UPDATE ON invoices
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- END OF SCHEMA
-- ============================================================================

