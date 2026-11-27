# FutureBridge AI

AI-Powered Student Opportunity & Education Pathway Intelligence Platform.

## Overview

FutureBridge AI is an education intelligence platform designed to help Sri Lankan students discover educational pathways, scholarships, competitions, vocational qualifications, and career development opportunities.

The platform uses Retrieval-Augmented Generation (RAG) to provide reliable, evidence-based guidance grounded in trusted educational sources.

## Project Status

Early development — Engineering Foundation.

## Core Features

- Education pathway discovery
- Scholarship intelligence
- Student opportunity matching
- Eligibility assessment
- Personalized education roadmaps
- Source-grounded AI assistance
- Application and deadline management
- Multilingual support

## Architecture

The project follows a monorepo architecture consisting of three independently deployable applications.

| Application | Technology | Directory |
|---|---|---|
| Frontend | Next.js, TypeScript | apps/web |
| Backend | Java, Spring Boot | apps/api |
| AI Service | Python, FastAPI | apps/ai-service |

The proposed architecture uses a modular monolith backend, an independent RAG service, PostgreSQL, and pgvector.

## Engineering Principles

- Clean architecture and modular design
- Privacy and security by design
- Evidence-based AI responses
- Automated testing
- Continuous integration and delivery
- Accessibility and multilingual support
- Maintainability and scalability

## Development

The project is currently under initialization. Application-specific setup instructions will be added as each service is implemented.

## Project Management

- Jira — Project planning and issue tracking
- Confluence — Project documentation
- GitHub — Version control and code reviews

## License

No open-source license has been selected. All rights are reserved.