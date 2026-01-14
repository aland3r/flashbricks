# Flashbricks - Functional Requirements

This document contains all functional requirements for the Flashbricks language learning application.

## Authentication & Access Control

**ID:** F-REQ001 
**Name:** Authentication
**Specification:** The system shall support authentication via Apple, Google, and Microsoft accounts

**ID:** F-REQ002 
**Name:** Role-Based Access Control
**Specification:** The system shall implement role-based authorization with four distinct roles: Learner (consume content), Content Curator (upload and manage content), Content Editor (review and edit subtitles), and System Administrator (full system access and user management)

## Language & Localization

**ID:** F-REQ003 
**Name:** Multi-language Support
**Specification:** The subtitles and flashbricks shall be available in English, Italian, German, Spanish and Portuguese

**ID:** F-REQ004 
**Name:** Language Switching
**Specification:** The system shall allow users to change their target language preference, and the change shall apply immediately to all system content including subtitles, flashbricks, and AI agent interactions

## Subtitle Features

**ID:** F-REQ005 
**Name:** Real-time Subtitle Synchronization
**Specification:** The system shall produce timestamp-aligned subtitles for video content and audiobooks, synchronizing each subtitle segment to specific media playback timestamps to ensure subtitle text displays at the corresponding moment in the audio/video stream during playback

**ID:** F-REQ006 
**Name:** Block Selection
**Specification:** Users shall be able to interact with both subtitle and transcript text to create flashbricks by tapping once on a word to select it, or tapping twice on the same word to select the entire phrase containing that word, allowing users to choose whether to create word-level or phrase-level flashbricks

**ID:** F-REQ007 
**Name:** Flashbrick Collection Overlay
**Specification:** When a user selects a word or phrase using block selection, an overlay or container shall open displaying the vocabulary card, allowing the user to review the selected content and add it to their collection

**ID:** F-REQ008 
**Name:** Vocabulary Card Colour Coding
**Specification:** Vocabulary cards and flashbricks shall use distinct colours for each grammatical category: nouns/noun phrases, verbs/verb phrases, adjectives/adjectival phrases, adverbs/adverbial phrases, and prepositions (when selected individually)

**ID:** F-REQ009 
**Name:** Prepositional Phrase Colour Assignment
**Specification:** When a preposition is tapped twice to create a prepositional phrase, the phrase shall use verb colour instead of the preposition's unique colour. Colour assignment for phrases shall be based on the head word of the phrase

## Flashbrick Collections

**ID:** F-REQ009 
**Name:** Automatic Collection Creation
**Specification:** The system shall automatically create a flashbrick collection for each content context (video or audiobook), organizing vocabulary selected by the user within that specific context. Future collection types based on semantic similarity or specific situational contexts may be added in subsequent versions.

## Learning Features

**ID:** F-REQ010 
**Name:** AI Agent Conversation
**Specification:** There shall be an AI agent that talks to users about their context in proficient language complexity

**ID:** F-REQ011 
**Name:** Simulation Space for Vocabulary Practice
**Specification:** The system shall provide a simulation space where users can practice real-life situations using vocabulary from their collections. The AI agent shall assist users in communicating within these simulated scenarios, helping them apply the vocabulary they have collected in contextually appropriate ways

## Content Management Workflow

**ID:** F-REQ012 
**Name:** Content Upload and Management
**Specification:** Content Curators shall be able to upload video files, audiobook files, and SRT subtitle files, and shall be able to add metadata and trigger AI processing for subtitle generation, cleaning, and synchronization

**ID:** F-REQ013 
**Name:** Subtitle Review and Editing Workflow
**Specification:** Content Editors shall be able to review, edit, and approve AI-generated or AI-processed subtitles, but shall not have the ability to reject content (rejection authority reserved for System Administrators)

**ID:** F-REQ014 
**Name:** Content Publication Workflow
**Specification:** Content shall transition through workflow states: Draft (uploaded by Curator), Pending Review (AI processing complete), Under Review (being edited by Editor), and Published (approved and available to Learners). Only Content Editors and System Administrators can approve content for publication.
