# Flashbricks - Business Requirements

This document contains the business requirements for the Flashbricks language learning application, following the framework from *Software Requirements Essentials* by Karl Wiegers and Candase Hokanson.

## Business Objectives

### BO-001: Vocabulary Learning Optimization
**Objective:** Maximize vocabulary retention and learning efficiency through scientifically-backed spaced repetition algorithms.

**Success Metrics:**
- Average memory retention rate of 80%+ after 30 days
- Reduction in review time by 40% compared to traditional flashcard methods
- User engagement rate of 70%+ (active users per week)

### BO-002: Context-Based Learning
**Objective:** Enable vocabulary learning from authentic content contexts (videos, audiobooks, books) to improve real-world language application.

**Success Metrics:**
- 90% of users report improved confidence in using vocabulary in context
- Average of 50+ flashbricks created per user per month
- Context completion rate of 60%+

### BO-003: Peer Learning and Tutoring Platform
**Objective:** Facilitate peer-to-peer learning sessions and enable qualified tutors to monetize their teaching expertise.

**Success Metrics:**
- 30% of learners engage in peer sessions monthly
- Average tutor session completion rate of 85%+
- Tutor satisfaction rating of 4.5+ out of 5.0

### BO-004: Scalable Revenue Model
**Objective:** Establish sustainable revenue through subscription plans and tutor marketplace commission.

**Success Metrics:**
- 20% conversion rate from free to paid plans
- Average revenue per user (ARPU) of $15/month
- Platform commission covers operational costs

## Vision Statement

Flashbricks is a language learning platform that transforms how people learn vocabulary by combining context-rich content with scientifically-proven spaced repetition algorithms. Learners create personalized flashcard collections from authentic media (videos, audiobooks, books), review them using adaptive scheduling, and practice through peer sessions or tutor-led classes. Qualified tutors can monetize their expertise, while learners access premium features through subscription plans. The platform serves language learners worldwide, starting with English, and expanding to Italian, German, Spanish, and Portuguese.

## Solution Boundaries

### In Scope
- Web application for vocabulary learning (MVP)
- Spaced repetition algorithm implementation
- Context browsing and flashbrick creation from media
- Peer-to-peer learning sessions
- Tutor-led paid sessions
- Subscription plan management
- Flashbrick collections organized by context
- Progress tracking and analytics

### Out of Scope (MVP)
- Mobile native applications (deferred to post-MVP)
- AI agent conversation features
- Simulation space for vocabulary practice
- Automated content processing (manual upload for MVP)
- Multi-language support (English only for MVP)
- Content curation and editing workflows (admin-only for MVP)

## Stakeholders

### Primary Stakeholders

**Learners (Free and Paid)**
- **Role:** End users who learn vocabulary
- **Interest:** Effective learning, progress tracking, affordable access
- **Representative:** Direct users of the platform

**Tutors**
- **Role:** Qualified teachers who provide paid sessions
- **Interest:** Monetization, student management, payment processing
- **Representative:** Promoted from learner role based on qualifications

**System Administrators**
- **Role:** Platform operators managing users, content, and system configuration
- **Interest:** System stability, user satisfaction, revenue growth
- **Representative:** Internal team members

### Secondary Stakeholders

**Content Providers**
- **Role:** Sources of learning contexts (YouTube, publishers, etc.)
- **Interest:** Proper attribution, copyright compliance
- **Representative:** External entities (not directly managed in MVP)

**Payment Processors**
- **Role:** Stripe or similar payment gateway
- **Interest:** Transaction security, compliance
- **Representative:** External service providers

## Business Rules

### BR-001: Role Assignment
**Rule:** Users are assigned one primary role: `learner`, `tutor`, or `admin`. Role assignment determines capabilities, not subscription status.

**Rationale:** Separates permissions (role) from feature access (plan), allowing tutors to also have premium features.

### BR-002: Tutor Promotion
**Rule:** Learners can be promoted to `tutor` role through admin approval or automatic qualification based on metrics (e.g., 50+ sessions completed, 4.8+ rating, 90%+ attendance rate).

**Rationale:** Ensures quality control for paid tutoring services while providing clear path for qualified users.

### BR-003: Session Charging
**Rule:** Only sessions where `tutor_id` references a user with `human_type = 'tutor'` can be charged. Peer sessions between learners are free.

**Rationale:** Clear monetization model that distinguishes free peer learning from paid professional tutoring.

### BR-004: Plan Membership
**Rule:** Plan membership (`plan_id`) is independent of role. Any user (learner or tutor) can subscribe to premium plans to unlock additional features.

**Rationale:** Allows flexible feature access regardless of user role, maximizing revenue opportunities.

### BR-005: Flashbrick Collection
**Rule:** Flashbrick collections are automatically created per context. Each user has private collections organized by the context from which flashbricks were extracted.

**Rationale:** Maintains learning context and enables organized review sessions.

### BR-006: Spaced Repetition Scheduling
**Rule:** Flashbricks are scheduled for review based on memory_rate calculation, which considers repetitions, ease_factor, time decay, status, and engagement metrics.

**Rationale:** Optimizes learning efficiency through scientifically-backed scheduling algorithms.

## Success Criteria

The Flashbricks platform will be considered successful when:

1. **Learning Effectiveness:** Users demonstrate 80%+ vocabulary retention after 30 days
2. **User Engagement:** 70%+ of registered users are active weekly
3. **Revenue Sustainability:** 20% conversion to paid plans and positive unit economics
4. **Tutor Satisfaction:** Tutors rate platform 4.5+ out of 5.0
5. **System Reliability:** 99.9% uptime and <200ms API response times

## Constraints

### Business Constraints
- Must comply with GDPR and data privacy regulations
- Payment processing must support international transactions
- Content must respect copyright and fair use policies

### Technical Constraints
- Backend must use Python/FastAPI (existing codebase)
- Database must use PostgreSQL (existing schema)
- Frontend MVP must be web-based (mobile deferred)

### Resource Constraints
- MVP must be deployable within 4-5 weeks
- Initial team: solo developer with AI assistance
- Budget constraints for third-party services (Stripe, hosting)

## Assumptions

1. Users have reliable internet access for web application
2. Users are motivated to learn and will engage with spaced repetition system
3. Qualified tutors exist who want to monetize teaching on the platform
4. Payment processing (Stripe) will be available in target markets
5. Content can be manually uploaded for MVP (automated processing deferred)

## Risks

### High Risk
- **User Adoption:** Low engagement with spaced repetition system
  - *Mitigation:* Clear onboarding, progress visualization, gamification elements

- **Tutor Quality:** Unqualified tutors providing poor service
  - *Mitigation:* Qualification criteria, rating system, admin oversight

### Medium Risk
- **Payment Processing:** Geographic limitations or compliance issues
  - *Mitigation:* Research payment providers, plan for phased geographic rollout

- **Content Copyright:** Legal issues with user-uploaded content
  - *Mitigation:* Clear terms of service, content moderation, attribution requirements

### Low Risk
- **Technical Scalability:** Performance issues with growth
  - *Mitigation:* Design for scalability from start, monitor performance metrics

