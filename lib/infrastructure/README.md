# Infrastructure Module

## Purpose

The infrastructure module contains all external system integrations and technical concerns. It provides the foundation for the application to interact with the outside world while keeping the domain layer framework-agnostic.

## Responsibilities

- **Networking**: HTTP client configuration, interceptors, error mapping
- **Authentication**: Token storage, JWT parsing, user ID resolution
- **Database**: Local SQLite database schema and migrations
- **Storage**: Secure storage for sensitive data (tokens)
- **Session Management**: User context and session state
- **Error Handling**: Exception and failure types, error mapping

## Components

### Auth Module

Handles authentication and authorization:

- **TokenStorage**: Abstract interface for token persistence
- **SecureTokenStorage**: FlutterSecureStorage implementation
- **TokenProvider**: Provides access tokens for API calls
- **TokenPayloadReader**: Parses JWT token payloads
- **JwtTokenPayloadReader**: JWT-specific payload parser
- **UserIdResolver**: Extracts user ID from tokens
- **TokenUserIdResolver**: JWT-based user ID resolver

### Network Module

Handles HTTP communication:

- **DioClient**: Configured Dio HTTP client
- **AuthInterceptor**: Adds authorization headers to requests

### Database Module

Handles local data persistence:

- **AppDatabase**: Drift database with ChatMessages table
- **Migrations**: Database schema migration strategy

### Errors Module

Handles error types and mapping:

- **AppException**: Sealed class for infrastructure exceptions
- **AppFailure**: Sealed class for domain failures
- **DioErrorMapper**: Maps Dio errors to AppException
- **FailureMapper**: Maps AppException to AppFailure
- **ApiErrorResponse**: Parses API error responses
- **Result**: Generic success/failure type

### Session Module

Manages user session state:

- **UserContextService**: Abstract interface for user context
- **InMemoryUserContextService**: In-memory implementation

## What Should Be Placed Here

✅ **Include**:
- External system integrations (HTTP, WebSocket, Database)
- Platform-specific implementations (iOS, Android, Web)
- Third-party SDK integrations (Firebase, Analytics)
- Technical concerns (caching, storage, networking)
- Error types and mapping

❌ **Do Not Include**:
- Business logic or rules
- UI components
- Feature-specific entities
- Use cases or repositories
- Domain types

## Why Infrastructure Exists

1. **Separation of Concerns**: Keeps technical concerns separate from business logic
2. **Framework Agnosticism**: Domain layer remains framework-agnostic
3. **Testability**: External dependencies can be mocked easily
4. **Reusability**: Infrastructure can be shared across features
5. **Maintainability**: Changes to external systems are isolated

## Architecture

```
Domain Layer
    ↓ depends on
Infrastructure Layer
    ↓ depends on
External Systems (API, Database, Storage, etc.)
```

## Networking

### HTTP Client

The Dio client is configured with:
- Base URL from environment configuration
- Timeout settings (connect, receive, send)
- Default headers (Accept, Content-Type)
- Auth interceptor for automatic token injection

### Error Mapping

Network errors are mapped through this pipeline:

```
DioException → DioErrorMapper → AppException → FailureMapper → AppFailure
```

Error types:
- NetworkException: Connection failures, timeouts
- UnauthorizedException: 401 responses
- ServerException: 5xx responses
- ValidationException: 422/400 responses
- ParsingException: JSON parsing failures
- UnknownException: Unhandled errors

## Authentication

### Token Storage

Tokens are stored securely using FlutterSecureStorage:
- Access token: Used for API authentication
- Refresh token: Used to obtain new access tokens
- Encrypted at rest on device
- Cleared on logout

### JWT Parsing

JWT tokens are parsed to extract:
- User ID (from user_id, userId, sub, or id fields)
- Expiration time
- Other claims

### User Context

User context maintains:
- Current user ID
- Authentication state
- Used by features requiring user identification

## Database

### Schema

Current schema includes:

**ChatMessages Table**:
- localId (primary key)
- serverId (nullable, from server)
- userId
- messageText
- createdAt
- status (pending, sent, failed)

### Migrations

Migration strategy:
- onCreate: Create all tables
- onUpgrade: Handle schema migrations
- Version tracking with schemaVersion

## Session Management

### User Context Service

Provides:
- Current user ID getter
- Has user ID check
- Set user ID
- Clear user context

### Session Restoration

On app startup:
1. Check for stored access token
2. If token exists, decode and validate
3. Extract user ID from payload
4. Set user context
5. If token invalid, clear context

## Guidelines

- Keep infrastructure classes focused on single responsibilities
- Use abstract interfaces to enable testing
- Map external errors to domain failures
- Secure storage for sensitive data
- Handle network failures gracefully
- Log infrastructure errors for debugging
- Keep database migrations backward-compatible
- Document external API contracts
