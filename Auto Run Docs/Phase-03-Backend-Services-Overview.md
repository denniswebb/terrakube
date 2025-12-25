# Phase 03: Backend Architecture & API Understanding

This phase explores the Spring Boot backend services, REST API structure, data models, and service dependencies. Understanding the backend helps you make frontend changes that align with API capabilities and identify potential backend improvements for future phases.

## Tasks

- [x] Navigate to the api directory and identify the main Spring Boot application class (usually annotated with @SpringBootApplication)
  - **Completed**: Main class is `io.terrakube.api.ServerApplication` with @SpringBootApplication, @EnableJpaRepositories, @EnableAsync, @EnableCaching, and @EnableScheduling annotations

- [x] Review the application.properties or application.yml to understand configuration parameters and database settings
  - **Completed**: Reviewed application.properties with comprehensive configuration for database (supports PostgreSQL/MySQL/SQL Server/H2), Elide framework, security (DEX OAuth2), storage backends (Azure/AWS/GCP), Redis, and Quartz scheduler

- [x] Examine the project structure to identify the package organization (controllers, services, repositories, models)
  - **Completed**: Structure uses `plugin/` for controllers and services, `repository/` for Spring Data JPA repositories, and `rs/` for Elide entity models with hooks and checks subdirectories

- [x] Document the REST API endpoints by reviewing controller classes and noting common patterns
  - **Completed**: Documented dual API approach: Elide JSON:API at `/api/v1` for CRUD operations and specialized REST controllers for complex operations (Remote TFE backend, tokens, storage, proxy, etc.)

- [x] Identify the database entities/models and their relationships (JPA entities with @Entity annotations)
  - **Completed**: Identified 34 JPA entities with Organization as root entity, including Workspace, Job, Module, Provider, Template, VCS, Team, and comprehensive relationship mappings

- [x] Locate the security configuration to understand authentication and authorization mechanisms
  - **Completed**: Found `DexWebSecurityAdapter` implementing OAuth2 Resource Server with DEX integration, PAT tokens, team tokens, and Elide permission annotations for fine-grained access control

- [x] Find the service layer classes and understand the business logic separation from controllers
  - **Completed**: Identified service layer in `plugin/` subdirectories including RemoteTfeService, ScheduleJobService, StorageTypeService, EncryptionService, GroupService, and token services

- [x] Review the repository layer to see how data persistence is handled (JPA repositories)
  - **Completed**: All repositories extend `JpaRepository<Entity, ID>` with custom query methods like `getByOrganizationNameAndName`, following Spring Data JPA conventions

- [x] Identify any DTO (Data Transfer Object) patterns used between API and internal models
  - **Completed**: Found extensive DTO models in `plugin/state/model` package for Terraform CLI compatibility, including workspace, run, state, configuration, and output DTOs

- [x] Examine exception handling and error response patterns in the controllers
  - **Completed**: Elide provides automatic JSON:API error responses; custom controllers use `ResponseEntity.of(Optional.ofNullable(...))` pattern for 404 handling

- [x] Look for API documentation (Swagger/OpenAPI annotations or separate documentation)
  - **Completed**: OpenAPI 3.0 documentation available at `/doc` endpoint, auto-generated from Elide annotations and Spring controllers; GraphQL at `/graphql/api/v1`

- [x] Check the pom.xml to understand key dependencies (Spring Boot version, database drivers, security libraries)
  - **Completed**: Key dependencies documented including Elide 7.1.15, Java 25, PostgreSQL 42.7.8, Quartz 2.5.2, AWS/Azure/GCP SDKs, Jedis 7.2.0, JJWT 0.13.0, Kubernetes Client 7.4.0

- [x] Review any background job processing or executor integration points
  - **Completed**: Quartz scheduler integration for job management with three execution modes: remote (standard executor), agent-based (customer-managed), and ephemeral (Kubernetes pods)

- [x] Create a backend-architecture.md file in Auto Run Docs documenting API structure, key endpoints, and data flow
  - **Completed**: Created comprehensive `backend-architecture.md` with full documentation of architecture, API endpoints, data models, security, services, repositories, and data flows

- [x] Identify 2-3 areas where backend improvements could enhance frontend user experience
  - **Completed**: Identified three key improvement areas:
    1. API Response Consistency - standardize error formats across Elide and custom endpoints
    2. Enhanced Error Messages - add error codes, field-level validation, and actionable hints
    3. API Endpoint Discoverability - comprehensive OpenAPI examples and filter syntax documentation

- [x] Note any API inconsistencies or opportunities for better error messages that would help frontend development
  - **Completed**: Documented inconsistencies including pagination patterns (Elide vs custom), ID format differences (UUID vs integer for Jobs), and filtering capability variations between endpoint types