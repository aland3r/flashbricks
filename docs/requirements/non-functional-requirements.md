# Flashbricks - Non-Functional Requirements

This document contains all non-functional requirements for the Flashbricks language learning application.

## Technology & Architecture Constraints

**ID:** N-REQ001 
**Name:** Python Backend
**Specification:** The backend services shall be implemented using Python programming language

**ID:** N-REQ002 
**Name:** FastAPI Framework
**Specification:** The backend services shall be implemented using the FastAPI framework

**ID:** N-REQ003 
**Name:** UV Dependency Manager
**Specification:** The system shall use uv as the dependency and virtual environment manager for the Python backend

**ID:** N-REQ004 
**Name:** Front-end Technology
**Specification:** The system's front-end shall be developed with React Native

**ID:** N-REQ005 
**Name:** JSON API Format
**Specification:** The backend API shall exchange data using JSON over HTTP

**ID:** N-REQ006 
**Name:** Database Technology
**Specification:** The system shall persist all application data in a PostgreSQL relational database

**ID:** N-REQ007 
**Name:** Database Management Platform
**Specification:** The PostgreSQL database shall be managed using the Supabase platform

## Performance Requirements

**ID:** N-REQ008 
**Name:** API Response Time
**Specification:** API endpoints shall respond within 200ms for 95% of requests under normal load conditions

**ID:** N-REQ009 
**Name:** Real-time Subtitle Synchronization Latency
**Specification:** Real-time subtitle synchronization shall have a latency of less than 100ms from media playback to subtitle display

**ID:** N-REQ010 
**Name:** Frontend Load Time
**Specification:** The frontend application shall achieve First Contentful Paint (FCP) within 1.5 seconds on 4G networks

## Usability Requirements

**ID:** N-REQ011 
**Name:** Responsive Design
**Specification:** The user interface shall respond harmonically to all screen sizes, supporting devices from 320px to 2560px width

**ID:** N-REQ012 
**Name:** UX Research
**Specification:** At least nine users shall be interviewed in UX Research before initial release

## Security Requirements

**ID:** N-REQ013 
**Name:** HTTPS/TLS Encryption
**Specification:** All API communications shall use HTTPS/TLS 1.2 or higher

**ID:** N-REQ014 
**Name:** Authentication Protocols
**Specification:** User authentication shall implement OAuth 2.0 and OpenID Connect protocols

**ID:** N-REQ015 
**Name:** Data Encryption at Rest
**Specification:** Sensitive user data at rest shall be encrypted using AES-256 encryption

**ID:** N-REQ016 
**Name:** GDPR Compliance
**Specification:** The system shall comply with GDPR data privacy regulations

**ID:** N-REQ026 
**Name:** Authorization Enforcement
**Specification:** The system shall enforce role-based authorization at all API endpoints and user interface levels, ensuring users can only access features and perform actions permitted by their assigned role

## Reliability & Availability

**ID:** N-REQ017 
**Name:** System Uptime
**Specification:** The system shall maintain 99.9% uptime availability (maximum 8.76 hours downtime per year)

**ID:** N-REQ018 
**Name:** Graceful Degradation
**Specification:** The system shall implement graceful degradation when external services are unavailable

## Scalability Requirements

**ID:** N-REQ019 
**Name:** Concurrent User Support
**Specification:** The system shall support at least 1,000 concurrent users without performance degradation

## Maintainability Requirements

**ID:** N-REQ020 
**Name:** Minimal Maintenance
**Specification:** The system shall require less than 10 hours of maintenance per month under normal operations

**ID:** N-REQ021 
**Name:** Documentation Language
**Specification:** The system's documentation and all business artefacts shall be initially produced in English

## Testability Requirements

**ID:** N-REQ022 
**Name:** Testing Device Requirements
**Specification:** User interface tests must be run on specified testing devices: mobile tests shall use iPhone 16 Pro, and desktop tests shall use a specified desktop testing device configuration (to be defined)

## Business Logic Requirements

**ID:** N-REQ024 
**Name:** AI-Generated Flashbricks
**Specification:** The flashbricks shall be produced by AI with an accuracy rate of at least 95% for vocabulary extraction

## Operational Requirements

**ID:** N-REQ025 
**Name:** Subtitle Quality Assurance Efficiency
**Specification:** The process for subtitle review and editing shall be designed to minimize manual intervention time while maintaining accuracy standards (target efficiency metrics to be defined)

**ID:** N-REQ027 
**Name:** Content Workflow Notifications
**Specification:** The system shall notify Content Editors when content requires review, and notify Content Curators when their uploaded content has been processed and is ready for review
