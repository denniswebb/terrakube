# Terrakube Backend Architecture Documentation

## Overview
Terrakube's backend is a Spring Boot application that provides a comprehensive REST API for managing Infrastructure as Code (IaC) automation and collaboration. The backend uses the **Elide framework** for building JSON:API compliant REST endpoints alongside traditional Spring MVC controllers for specialized functionality.

## Application Entry Point

**Main Application Class**: `io.terrakube.api.ServerApplication`
- Location: `api/src/main/java/io/terrakube/api/ServerApplication.java`
- Annotations:
  - `@SpringBootApplication` - Spring Boot application marker
  - `@EnableJpaRepositories(basePackages = "io.terrakube.api.repository")` - JPA repository scanning
  - `@EnableAsync` - Asynchronous processing support
  - `@EnableCaching` - Caching support
  - `@EnableScheduling` - Scheduled task execution

## Configuration

**Primary Configuration File**: `application.properties`
- Location: `api/src/main/resources/application.properties`

### Key Configuration Areas:

1. **Database Configuration**
   - Supports multiple database types (PostgreSQL, SQL Server, MySQL, H2)
   - Uses Liquibase for database migrations
   - JPA/Hibernate for ORM with standard naming strategy
   - Configurable via environment variables: `ApiDataSourceType`, `DatasourceHostname`, `DatasourceDatabase`, etc.

2. **Elide Framework Configuration**
   - Model package: `io.terrakube.api.rs`
   - JSON:API endpoint: `/api/v1`
   - GraphQL endpoint: `/graphql/api/v1`
   - OpenAPI documentation: `/doc`

3. **Security & Authentication**
   - DEX integration for OAuth2/OIDC authentication
   - Personal Access Token (PAT) support
   - Team-based token authentication
   - Issuer URI configuration: `DexIssuerUri`
   - JWT-based authentication with configurable secrets

4. **Storage Backend**
   - Supports Azure Blob Storage, AWS S3, and GCP Cloud Storage
   - Configurable via `StorageType` environment variable

5. **Job Execution**
   - Quartz scheduler for job management
   - Executor URL configuration for job processing
   - Ephemeral executor support (Kubernetes-based)

6. **Redis Configuration**
   - Module caching
   - Support for standalone, cluster, and sentinel modes
   - Configurable connection pooling

7. **External Integrations**
   - Terraform/OpenTofu release management
   - Dynamic credentials support
   - Tools repository configuration

## Package Structure

```
io.terrakube.api/
├── ServerApplication.java          # Main application entry point
├── plugin/                          # Plugin modules and controllers
│   ├── context/                    # Job context management
│   ├── datasource/                 # Database configuration
│   ├── importer/                   # Terraform Cloud import functionality
│   ├── json/                       # JSON processing
│   ├── logs/                       # Log management
│   ├── manage/                     # Management endpoints
│   ├── migrate/                    # Migration utilities
│   ├── proxy/                      # Proxy service
│   ├── redirect/                   # Redirect handling
│   ├── scheduler/                  # Job scheduling (Quartz)
│   ├── security/                   # Security & authentication
│   │   ├── audit/                  # Audit logging
│   │   ├── authentication/dex/    # DEX authentication adapter
│   │   ├── encryption/             # Encryption services
│   │   └── groups/                 # Group management
│   ├── softdelete/                 # Soft delete functionality
│   ├── ssh/                        # SSH key management
│   ├── state/                      # Terraform state management
│   ├── storage/                    # Storage abstraction layer
│   ├── streaming/                  # Real-time streaming
│   ├── token/                      # Token management (PAT, Team tokens)
│   └── vcs/                        # Version control integration
├── repository/                     # Spring Data JPA repositories
└── rs/                             # Resource entities (Elide models)
    ├── Organization.java
    ├── workspace/
    ├── job/
    ├── module/
    ├── provider/
    ├── vcs/
    ├── team/
    ├── template/
    ├── agent/
    ├── collection/
    ├── globalvar/
    ├── project/
    ├── ssh/
    ├── tag/
    ├── token/
    ├── webhook/
    ├── checks/                     # Permission checks
    └── hooks/                      # Lifecycle hooks
```

## API Architecture

### Dual API Approach

Terrakube uses two complementary API patterns:

#### 1. Elide JSON:API (Primary Data API)
- **Base Path**: `/api/v1`
- **Framework**: Yahoo Elide
- **Standard**: JSON:API specification
- **Purpose**: CRUD operations on domain entities
- **Features**:
  - Automatic CRUD endpoints for all `@Include` entities
  - Built-in filtering, sorting, pagination
  - Relationship management
  - Field-level permissions via Elide annotations
  - GraphQL support at `/graphql/api/v1`

**Example Entities**:
- Organizations: `/api/v1/organization`
- Workspaces: `/api/v1/workspace`
- Jobs: `/api/v1/job`
- Modules: `/api/v1/module`
- Templates: `/api/v1/template`
- VCS: `/api/v1/vcs`

#### 2. Traditional REST Controllers (Specialized Operations)
- **Purpose**: Complex business operations not suitable for simple CRUD
- **Pattern**: Spring MVC `@RestController` with explicit mappings

**Key Controller Groups**:

1. **Terraform Remote Backend** (`RemoteTfeController`)
   - Base: `/remote/tfe/v2/`
   - Purpose: Terraform CLI remote backend compatibility
   - Endpoints:
     - `GET /organizations/{org}/workspaces/{workspace}` - Get workspace
     - `POST /workspaces/{id}/state-versions` - Upload state
     - `GET /state-versions/{id}` - Retrieve state version
     - `POST /workspaces/{id}/actions/lock` - Lock workspace
     - `POST /workspaces/{id}/actions/unlock` - Unlock workspace
     - `POST /workspaces/{id}/configuration-versions` - Create config version
     - `POST /workspaces/{id}/runs` - Create run

2. **Token Management**
   - `PatController`: `/pat/v1` - Personal Access Tokens
   - `TeamTokenController`: `/access-token/v1/teams` - Team tokens
   - `OpenIdConfigurationController`: `/.well-known/openid-configuration`
   - `JwksController`: `/.well-known/jwks`

3. **Storage Operations**
   - `TerraformStateController`: `/tfstate/v1` - State file operations
   - `TerraformOutputController`: Output retrieval

4. **Proxy Service**
   - `ProxyController`: `/proxy/v1` - HTTP proxy for external services

5. **Job Context**
   - `ContextController`: `/context/v1` - Job execution context

6. **Import/Export**
   - `TfCloudController`: `/importer/tfcloud` - Terraform Cloud migration

7. **VCS Integration**
   - Various VCS-specific controllers for GitHub, GitLab, Bitbucket, Azure DevOps webhooks

## Database Entities and Relationships

### Core Domain Model (34 JPA Entities)

#### Organization Hierarchy
```
Organization (Root Entity)
├── Workspace (1:N)
│   ├── Job (1:N)
│   │   └── Step (1:N)
│   ├── Variable (1:N)
│   ├── History (1:N - state versions)
│   ├── Schedule (1:N)
│   ├── Access (1:N - team permissions)
│   ├── Content (1:N - uploaded files)
│   └── WorkspaceTag (N:M with Tag)
├── Project (1:N)
├── Module (1:N)
├── Provider (1:N)
├── Template (1:N)
├── Vcs (1:N - VCS connections)
├── Ssh (1:N - SSH keys)
├── Team (1:N)
├── Globalvar (1:N - global variables)
├── Collection (1:N)
├── Agent (1:N - execution agents)
└── Webhook (1:N)
```

#### Key Entity Characteristics

**Organization** (`io.terrakube.api.rs.Organization`)
- ID: UUID
- Fields: name, description, disabled
- Permissions: Read (org members), Create/Update/Delete (superuser only)
- Soft delete: `@SQLRestriction(value = "disabled = false")`

**Workspace** (`io.terrakube.api.rs.workspace.Workspace`)
- ID: UUID
- Fields: name, description, source, branch, folder, terraformVersion, iacType, executionMode
- Status tracking: lastJobStatus, lastJobDate, locked, lockDescription
- Permissions: Team-based with view/manage/limited roles
- Relationships: Organization, Project, Template, Vcs, Ssh, Agent
- Soft delete: `@SQLRestriction(value = "deleted = false")`

**Job** (`io.terrakube.api.rs.job.Job`)
- ID: Integer (auto-increment)
- Fields: comments, status, output, commitId, terraformPlan, tcl (Terrakube Configuration Language)
- Status enum: pending, running, completed, failed, cancelled, etc.
- Relationships: Workspace, Organization, Template
- Audit: Extends `GenericAuditFields` (createdBy, createdDate, updatedBy, updatedDate)

**Module** (`io.terrakube.api.rs.module.Module`)
- Private Terraform module registry
- Versioning support
- VCS integration

**Provider** (`io.terrakube.api.rs.provider.Provider`)
- Private Terraform provider registry
- Platform-specific implementations

**Template** (`io.terrakube.api.rs.template.Template`)
- Workflow templates using Terrakube Configuration Language (TCL)
- Reusable job definitions

#### Security and Access Control

**Team** (`io.terrakube.api.rs.team.Team`)
- Organization-level teams
- Permissions: manage workspaces, view only, etc.

**Access** (`io.terrakube.api.rs.workspace.access.Access`)
- Workspace-level team permissions
- Granular access control per workspace

## Security Architecture

### Authentication Configuration

**Security Adapter**: `DexWebSecurityAdapter`
- Location: `api/src/main/java/io/terrakube/api/plugin/security/authentication/dex/DexWebSecurityAdapter.java`

#### Security Filter Chains

1. **Public Terraform Discovery**
   - Path: `GET /.well-known/terraform.json`
   - Access: Permit all (no authentication)

2. **Main Security Chain**
   - CORS: Configured via `io.terrakube.ui.url`
   - CSRF: Disabled for specific endpoints (state uploads, webhooks, remote backend)
   - Authentication: OAuth2 Resource Server with JWT

#### Authentication Methods

1. **DEX (Primary)**
   - OpenID Connect provider integration
   - Supports: Azure AD, Google, GitHub, SAML, LDAP, etc.
   - Issuer URI: Configurable via `DexIssuerUri`
   - Client ID: `DexClientId`

2. **Personal Access Tokens (PAT)**
   - JWT-based tokens
   - Secret: `PatSecret`
   - Service: `PatService`
   - Repository: `PatRepository`

3. **Team Tokens**
   - Group-based service tokens
   - Repository: `TeamTokenRepository`

4. **Internal Service Tokens**
   - Inter-service communication
   - Secret: `InternalSecret`

#### Authentication Manager Resolution

Uses `DexAuthenticationManagerResolver` to route authentication:
- DEX JWT tokens → DEX authentication
- PAT tokens → PAT authentication
- Internal tokens → Internal authentication

#### Public Endpoints (No Authentication Required)

- `OPTIONS /**` - CORS preflight
- `/actuator/**` - Health checks
- `/error` - Error handling
- `/callback/v1/**` - OAuth callbacks
- `/webhook/v1/**` - External webhooks
- `/.well-known/*` - Discovery endpoints
- `/remote/tfe/v2/ping` - Terraform CLI ping
- `PUT /remote/tfe/v2/configuration-versions/*` - Config uploads
- `PUT /tfstate/v1/archive/*/terraform.tfstate` - State uploads
- `/remote/tfe/v2/plans/logs/**` - Plan logs
- `/remote/tfe/v2/applies/logs/**` - Apply logs
- `/app/*/*/runs/*` - Run status pages
- `/tofu/index.json` - OpenTofu releases

#### Permission Model

**Elide Permissions** (Annotation-based):
- `@ReadPermission` - Who can read
- `@CreatePermission` - Who can create
- `@UpdatePermission` - Who can update
- `@DeletePermission` - Who can delete

**Permission Expressions** (Examples):
- `"user belongs organization"` - User is member of organization
- `"team manage workspace"` - Team has manage permission on workspace
- `"team limited view workspace"` - Team has limited view access
- `"user is a superuser"` - User has superuser role
- `"user is a super service"` - Service account with elevated privileges

**Check Classes**:
- Located in `io.terrakube.api.rs.checks`
- Custom permission logic for complex scenarios
- Examples: `OrganizationCheck`, `WorkspaceCheck`, `JobCheck`

## Service Layer

### Pattern: Service-Repository Architecture

Services encapsulate business logic and orchestrate repository operations.

#### Key Services

1. **RemoteTfeService**
   - Location: `io.terrakube.api.plugin.state.RemoteTfeService`
   - Purpose: Terraform remote backend protocol implementation
   - Responsibilities:
     - Workspace state management
     - Run creation and execution
     - State version handling
     - Configuration version processing

2. **ScheduleJobService**
   - Location: `io.terrakube.api.plugin.scheduler.ScheduleJobService`
   - Purpose: Job scheduling and execution
   - Uses: Quartz scheduler
   - Handles: Job triggers, execution planning

3. **StorageTypeService**
   - Location: `io.terrakube.api.plugin.storage.StorageTypeService`
   - Purpose: Storage abstraction
   - Supports: Azure Blob, AWS S3, GCP Cloud Storage
   - Operations: Upload, download, delete artifacts

4. **EncryptionService**
   - Location: `io.terrakube.api.plugin.security.encryption.EncryptionService`
   - Purpose: Sensitive data encryption
   - Use cases: Variables, credentials, tokens

5. **GroupService**
   - Location: `io.terrakube.api.plugin.security.groups.GroupService`
   - Purpose: Team/group membership validation

6. **PatService** & **TeamTokenService**
   - Token generation and validation
   - JWT creation and verification

## Repository Layer

### Pattern: Spring Data JPA Repositories

All repositories extend `JpaRepository<Entity, ID>` for standard CRUD operations.

#### Repository Examples

**WorkspaceRepository** (`io.terrakube.api.repository.WorkspaceRepository`)
```java
public interface WorkspaceRepository extends JpaRepository<Workspace, UUID> {
    Workspace getByOrganizationNameAndName(String organizationName, String workspaceName);
    Optional<List<Workspace>> findWorkspacesByOrganizationNameAndNameStartingWith(
        String organizationName, String workspaceNameStartingWidth);
    Optional<List<Workspace>> findWorkspacesByOrganization(Organization organization);
}
```

**JobRepository** (`io.terrakube.api.repository.JobRepository`)
- Job CRUD operations
- Status queries
- Workspace-based filtering

**OrganizationRepository**
- Organization lookup by name
- Organization membership queries

**Key Repositories** (18 total):
- WorkspaceRepository
- JobRepository
- OrganizationRepository
- ModuleRepository
- ProviderRepository
- TemplateRepository
- VcsRepository
- TeamRepository
- PatRepository
- TeamTokenRepository
- StepRepository
- HistoryRepository
- ContentRepository
- AddressRepository
- GlobalVarRepository
- VariableRepository
- WebhookRepository
- CollectionRepository

## Data Transfer Objects (DTOs)

### Pattern: Separate API Models

Located in `io.terrakube.api.plugin.state.model` package:

- **Purpose**: Terraform CLI compatibility and API versioning
- **Packages**:
  - `organization/` - Organization DTOs
  - `workspace/` - Workspace DTOs
  - `runs/` - Run/Job DTOs
  - `state/` - State version DTOs
  - `configuration/` - Configuration version DTOs
  - `apply/` - Apply operation DTOs
  - `plan/` - Plan operation DTOs
  - `outputs/` - Output DTOs

### Mapping Pattern
Entity → DTO conversion in services, typically:
```java
// Entity to DTO
WorkspaceData dto = WorkspaceModel.builder()
    .id(workspace.getId().toString())
    .type("workspaces")
    .attributes(WorkspaceAttributes.builder()
        .name(workspace.getName())
        .terraformVersion(workspace.getTerraformVersion())
        .build())
    .build();
```

## Exception Handling and Error Responses

### Elide Error Handling
- Automatic JSON:API error responses
- HTTP status codes: 400, 404, 403, 500
- Error format:
```json
{
  "errors": [{
    "detail": "Error message",
    "status": "404"
  }]
}
```

### Custom Exception Handling
Controllers use `ResponseEntity.of(Optional.ofNullable(...))` pattern:
- Returns 200 OK with data if present
- Returns 404 Not Found if null

### Error Patterns
- Validation errors → 400 Bad Request
- Permission denied → 403 Forbidden
- Resource not found → 404 Not Found
- Server errors → 500 Internal Server Error

## Background Job Processing

### Quartz Scheduler Integration

**Configuration**: `QuartzAutoConfiguration`
- Job store: JDBC-persisted
- Thread pool configuration
- Job triggers and scheduling

**Job Types**:
1. **Terraform/OpenTofu Execution Jobs**
   - Plan operations
   - Apply operations
   - Destroy operations

2. **Scheduled Jobs**
   - Workspace schedules
   - Module cache refresh
   - GitHub App token renewal

### Executor Integration

**Architecture**:
- API Server schedules jobs
- Executor service executes jobs
- Communication via REST API and Redis streams

**Execution Modes**:
1. **Remote Execution** (Standard)
   - Jobs run on executor service
   - API polls for status

2. **Agent Execution**
   - Jobs run on customer-managed agents
   - Agent pools for isolation

3. **Ephemeral Execution** (Kubernetes)
   - Jobs spawn Kubernetes pods
   - Auto-scaling support
   - Resource isolation

## Key Dependencies (from pom.xml)

### Core Framework
- **Spring Boot**: 3.x (implied by parent POM)
- **Java Version**: 25
- **Elide**: 7.1.15 (JSON:API framework)

### Persistence
- **PostgreSQL Driver**: 42.7.8
- **SQL Server Driver**: 13.2.1.jre11
- **H2 Database**: (for testing/dev)

### Security
- **Spring Security OAuth2 Resource Server**
- **JJWT**: 0.13.0 (JWT processing)
- **Bouncy Castle**: 1.83 (cryptography)

### Scheduling
- **Quartz**: 2.5.2

### Cloud Storage
- **AWS SDK**: 2.40.13
- **Azure SDK**: 6.1.0
- **GCP Libraries BOM**: 26.73.0

### Caching & Messaging
- **Redis (Jedis)**: 7.2.0
- **Spring Data Redis**

### VCS Integration
- **JGit**: 7.5.0 (Git operations)

### Kubernetes
- **Kubernetes Client**: 7.4.0

### Utilities
- **Lombok**: 1.18.42 (code generation)
- **Commons Text**: 1.15.0
- **Commons Lang3**: 3.20.0
- **Commons IO**: 2.21.0
- **Handlebars**: 4.3.1 (templating)

### Testing
- **WireMock**: 4.0.8
- **REST Assured**: 5.5.6

## API Documentation

### OpenAPI/Swagger
- **Endpoint**: `/doc`
- **Version**: OpenAPI 3.0
- **Auto-generated**: From Elide annotations and Spring controllers
- **Configuration**: `elide.api-docs.enabled=true`

### GraphQL
- **Endpoint**: `/graphql/api/v1`
- **Auto-generated**: From Elide entity models
- **Introspection**: Available for schema discovery

## Data Flow Patterns

### 1. Workspace Creation Flow
```
Frontend → POST /api/v1/workspace
  → Elide processes JSON:API request
  → WorkspaceManageHook (pre-commit)
  → WorkspaceRepository.save()
  → Database INSERT
  → WorkspaceManageHook (post-commit)
  → Response with created workspace
```

### 2. Job Execution Flow
```
User triggers job → POST /api/v1/job
  → JobManageHook (post-commit)
  → ScheduleJobService.scheduleJob()
  → Quartz schedules job
  → Executor polls/receives job
  → Job execution (plan/apply)
  → Status updates via API
  → Completion notification
```

### 3. State Upload Flow (Terraform CLI)
```
terraform apply → PUT /tfstate/v1/archive/{workspace}/terraform.tfstate
  → RemoteTfeController
  → RemoteTfeService.uploadState()
  → StorageTypeService.uploadState()
  → Cloud storage (S3/Azure/GCP)
  → History record created
  → Workspace.lastJobStatus updated
```

### 4. Remote Backend Flow (Terraform CLI)
```
terraform init → GET /.well-known/terraform.json
  → Discovery of remote backend capabilities

terraform plan → POST /remote/tfe/v2/runs
  → RemoteTfeService.createRun()
  → Job created
  → Configuration version created
  → Return run ID

terraform upload → PUT /remote/tfe/v2/configuration-versions/{id}
  → Upload tarball to storage
  → Trigger plan execution
```

## Areas for Backend Improvement

Based on the architecture analysis, here are opportunities to enhance the backend for better frontend developer experience:

### 1. API Response Consistency
**Current State**: Mix of JSON:API (Elide) and custom JSON responses
**Improvement Opportunity**:
- Standardize error response format across all controllers
- Add consistent metadata (pagination, timestamps) to custom endpoints
- Document which endpoints follow JSON:API vs custom format
**Impact on Frontend**: Simplified error handling, consistent data parsing patterns

### 2. Enhanced Error Messages
**Current State**: Some errors lack context for frontend debugging
**Improvement Opportunity**:
- Add error codes in addition to HTTP status
- Include field-level validation errors with specific field names
- Add "hint" or "suggestion" fields for common user errors
- Example:
```json
{
  "errors": [{
    "code": "WORKSPACE_NAME_INVALID",
    "detail": "Workspace name must be lowercase alphanumeric",
    "field": "name",
    "hint": "Try 'my-workspace' instead of 'My Workspace'"
  }]
}
```
**Impact on Frontend**: Better user experience with actionable error messages

### 3. API Endpoint Discoverability
**Current State**: OpenAPI docs available but could be enhanced
**Improvement Opportunity**:
- Add comprehensive examples to OpenAPI documentation
- Document Elide filter syntax for each entity
- Create endpoint summary document mapping UI features to API calls
- Add rate limiting information to docs
**Impact on Frontend**: Faster onboarding, fewer API misuse issues

## API Inconsistencies Noted

### 1. Pagination Patterns
- **Elide endpoints**: Use `page[number]` and `page[size]` query params
- **Custom endpoints**: Some don't support pagination consistently
- **Recommendation**: Document pagination clearly, ensure all list endpoints support it

### 2. ID Format Inconsistencies
- **Most entities**: Use UUID strings
- **Job entity**: Uses integer ID (auto-increment)
- **Impact**: Frontend must handle different ID types
- **Note**: This is by design (Jobs are frequently created, integers are more efficient)

### 3. Date/Time Format
- **Recommendation**: Ensure all timestamps use ISO 8601 format consistently
- **Current**: Most use standard Jackson serialization, but verify consistency

### 4. Filtering Capabilities
- **Elide endpoints**: Support sophisticated filtering via RSQL
- **Custom endpoints**: Limited or no filtering
- **Recommendation**: Document which endpoints support filtering and the syntax

## Additional Notes

### Lifecycle Hooks
Elide provides lifecycle hooks for pre/post operations:
- `@LifeCycleHookBinding` on entities
- Hooks in `io.terrakube.api.rs.hooks` package
- Use cases:
  - Pre-commit validation
  - Post-commit notifications
  - Audit logging
  - Trigger background jobs

Example hooks:
- `WorkspaceManageHook`: Validates workspace configuration
- `JobManageHook`: Triggers job scheduling
- `OrganizationManageHook`: Initializes org resources

### Soft Delete Pattern
Many entities use soft delete via `@SQLRestriction`:
```java
@SQLRestriction(value = "deleted = false")
@SQLRestriction(value = "disabled = false")
```
This preserves data while hiding it from queries.

### Audit Trail
Entities extend `GenericAuditFields`:
- `createdBy`: User who created record
- `createdDate`: Creation timestamp
- `updatedBy`: User who last modified
- `updatedDate`: Last modification timestamp

### Redis Usage
- **Module caching**: Speeds up module registry lookups
- **Streaming**: Real-time job status updates
- **Session state**: (if configured)
- **Configuration**: Supports standalone, cluster, and sentinel modes

### Multi-Tenancy
Organization-based multi-tenancy:
- All resources belong to an Organization
- Team-based access control within organizations
- Permission checks enforce organization boundaries

## Summary

The Terrakube backend is a sophisticated Spring Boot application that:

1. **Uses Elide framework** for automatic JSON:API generation from JPA entities
2. **Implements Terraform remote backend protocol** for CLI compatibility
3. **Supports multiple cloud storage backends** (Azure, AWS, GCP)
4. **Integrates with major VCS providers** (GitHub, GitLab, Bitbucket, Azure DevOps)
5. **Uses Quartz for job scheduling** with multiple execution modes
6. **Employs JWT-based authentication** with OAuth2/OIDC via DEX
7. **Provides fine-grained permissions** via Elide annotations and custom checks
8. **Maintains comprehensive audit trails** for compliance
9. **Supports multi-tenancy** via organization isolation

The architecture is well-structured with clear separation of concerns:
- **Entities** (`rs/`) define the domain model
- **Repositories** provide data access
- **Services** implement business logic
- **Controllers** expose REST endpoints
- **Security** configuration ensures proper authentication and authorization

Frontend developers should:
- Use `/api/v1/*` Elide endpoints for standard CRUD operations
- Use specialized controllers (`/remote/tfe/v2`, `/pat/v1`, etc.) for complex operations
- Understand JSON:API format for Elide endpoints
- Handle dual authentication (DEX OAuth2 + PAT tokens)
- Be aware of organization-based multi-tenancy in all operations
