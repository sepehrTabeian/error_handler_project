# Auth Feature

## Business Goal

The auth feature handles user authentication and session management. It enables users to log in with email/password, securely stores authentication tokens, and manages session state across app restarts.

## Architecture

### Clean Architecture Layers

```
Presentation Layer
├── (To be implemented)
    ↓ depends on
Domain Layer
├── AuthSessionEntity (Domain entity)
├── LoginRequestEntity (Request entity)
├── AuthRepository (Repository interface)
└── LoginUseCase (Business logic)
    ↓ depends on
Data Layer
├── AuthRepositoryImpl (Repository implementation)
├── AuthRemoteDataSource (REST API)
├── LoginRequestDto (Request DTO)
└── LoginResponseDto (Response DTO)
```

## Entities

### AuthSessionEntity

Domain entity representing an authenticated session:

- **accessToken**: JWT access token for API authentication
- **refreshToken**: JWT refresh token for obtaining new access tokens (optional)

### LoginRequestEntity

Domain entity for login request:

- **email**: User's email address
- **password**: User's password

## Repository

### AuthRepository Interface

```dart
abstract class AuthRepository {
  Future<Result<void>> login(LoginRequestEntity request);
  Future<void> logout();
}
```

### AuthRepositoryImpl

Implementation with:
- Remote data source for API calls
- Token storage for persisting tokens
- Failure mapping for error handling

## Use Case

### LoginUseCase

Validates credentials and authenticates user:

**Validation**:
- Email cannot be empty
- Password cannot be empty

**Flow**:
1. Validate input
2. Call repository login
3. Repository saves tokens to secure storage
4. Return Result<void>

**Error Handling**:
- Validation errors return immediately
- Network errors mapped to failures
- Server errors mapped to failures

## Data Sources

### AuthRemoteDataSource

REST API for authentication:

- **POST /login**: Authenticate user
- Returns access and refresh tokens
- Maps Dio errors to AppException

### AuthRemoteDataSourceImpl

Dio-based implementation:
- Uses configured Dio client
- Applies error mapping
- Serializes request/response

## Data Transfer Objects

### LoginRequestDto

DTO for login request:
- Maps from LoginRequestEntity
- Serializes to JSON

### LoginResponseDto

DTO for login response:
- Parses from JSON
- Maps to AuthSessionEntity

## JWT Token Management

### Token Storage

Tokens are stored securely:
- **Access Token**: Used for API authentication
- **Refresh Token**: Used to obtain new access tokens
- Stored in FlutterSecureStorage
- Encrypted at rest

### Token Payload

JWT token contains:
- **user_id**: Unique user identifier
- **userId**: Alternative user ID field
- **sub**: Subject (user identifier)
- **id**: Another user ID field
- **exp**: Expiration timestamp

### User ID Resolution

User ID is extracted from token payload:
- Checks multiple possible fields
- Returns first non-null value
- Used for session restoration

## Session Management

### Session Restoration

On app startup:
1. Check for stored access token
2. If token exists, decode JWT payload
3. Extract user ID from payload
4. Set user context
5. If token invalid, clear context

### Session Termination

On logout:
1. Clear tokens from secure storage
2. Clear user context
3. Navigate to login screen

## Security Considerations

### Token Storage

- Uses FlutterSecureStorage for encryption
- Tokens never stored in plain text
- Tokens cleared on logout
- Tokens cleared on app uninstall

### Token Transmission

- Tokens sent via HTTPS only
- Authorization header: `Bearer <token>`
- WebSocket uses token as query parameter

### Token Validation

- JWT signature validated by server
- Expiration checked by server
- Client validates token format

## Error Handling

### Validation Errors

- Email required: "ایمیل الزامی است"
- Password required: "رمز عبور الزامی است"

### Network Errors

- Connection failure: "اتصال اینترنت را بررسی کنید"

### Server Errors

- Unauthorized: "لطفا دوباره وارد شوید"
- Server error: "خطا در ارتباط با سرور"
- Validation error: Field-specific messages

## Integration Points

### Infrastructure Dependencies

- **TokenStorage**: Secure token persistence
- **TokenProvider**: Provides access tokens
- **UserIdResolver**: Extracts user ID from token
- **UserContextService**: Manages user session state
- **DioClient**: HTTP client for API calls
- **FailureMapper**: Maps exceptions to failures

### Feature Dependencies

- Used by features requiring authentication
- User context available to all features
- Tokens automatically added to API requests

## Future Enhancements

### Token Refresh

- Implement automatic token refresh
- Handle token expiration gracefully
- Refresh tokens before expiration

### Biometric Auth

- Add fingerprint/face authentication
- Secure storage with biometric unlock
- Quick re-authentication

### Social Login

- Add Google sign-in
- Add Apple sign-in
- Add Facebook sign-in

### Multi-Factor Auth

- Add SMS verification
- Add email verification
- Add authenticator app

## Testing Considerations

### Unit Tests

- LoginUseCase validation logic
- Repository with mocked data source
- DTO serialization/deserialization

### Integration Tests

- Login flow with mock server
- Token storage and retrieval
- Session restoration

### Widget Tests

- Login form UI (when implemented)
- Validation error display
- Loading states

## Guidelines

- Never store tokens in plain text
- Always use secure storage for tokens
- Validate input before API calls
- Handle network failures gracefully
- Clear tokens on logout
- Use HTTPS for all API calls
- Log authentication events for security
- Implement rate limiting (to be added)
- Add account lockout after failed attempts (to be added)
