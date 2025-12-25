# Phase 02: Frontend Architecture Understanding

This phase focuses on understanding the React/TypeScript frontend architecture, component patterns, state management, and routing. You'll explore the codebase systematically to identify where common UI features live and how they're implemented, preparing you to make informed improvements.

## Tasks

- [x] Examine the ui/src directory structure and create a mental map of how components are organized (features, shared, layouts, etc.)
- [x] Identify the routing configuration file (likely App.tsx or routes file) and document the main application routes
- [x] Locate the state management solution (Redux, Context API, or other) and identify where global state is defined
- [x] Find and review the API client/service layer that handles backend communication (usually in services/ or api/ directory)
- [x] Examine the authentication flow by tracing login component → auth service → token storage → protected routes
- [x] Identify the UI component library or design system being used (Material-UI, Ant Design, custom components, etc.)
- [x] Review the workspace management components to understand the core feature's implementation
- [x] Locate form handling patterns by examining a representative form component (workspace creation, settings, etc.)
- [x] Check for existing error handling patterns in components and API calls
- [x] Identify loading state patterns used throughout the application
- [x] Document common TypeScript interfaces/types used for domain models (Workspace, Organization, Template, etc.)
- [x] Find the configuration files (tsconfig.json, package.json) and note key dependencies and their versions
- [x] Create a frontend-architecture.md file in Auto Run Docs summarizing component organization, state flow, and key patterns
- [x] Identify 2-3 UI components that could benefit from improvement based on your exploration
- [x] Note any inconsistencies in patterns that might indicate technical debt or refactoring opportunities

## Completion Notes

**Completed:** 2024-12-24

### Summary
All frontend architecture exploration tasks completed. Created comprehensive `frontend-architecture.md` documentation in `Auto Run Docs/Working/` covering:

### Key Findings

**Architecture Overview:**
- React 19.2.3 SPA with TypeScript 5.9.3
- Ant Design 6.1.1 component library
- Vite 7.3.0 build tool
- React Router DOM 7.11.0 for routing
- OIDC authentication via react-oidc-context

**Component Organization:**
- **domain/**: Feature-based page components (Organizations, Workspaces, Modules, Jobs, Settings)
- **modules/**: Shared components and utilities (api, layout, organizations, workspaces, user, utils)
- Clear separation between page-level and reusable components

**State Management:**
- Minimal Redux usage (only for organization state)
- Primarily local state with useState/useEffect
- Session storage for organization context persistence

**API Layer:**
- Two competing patterns identified (needs consolidation):
  1. Direct axios calls (legacy)
  2. apiWrapper + useApiRequest hook (modern, preferred)
- Three axios instances: REST API, REST client, GraphQL

**Authentication Flow:**
- OIDC-based with localStorage token storage
- Auth check in App.tsx guards all routes
- Axios interceptors inject Bearer tokens
- Token expiry checking with automatic logout

**Routing:**
- Centralized in domain/Home/App.tsx
- 30+ routes covering organizations, workspaces, modules, settings
- Nested routes with shared header/footer layout
- Dual route pattern: `/workspaces/:id` and `/organizations/:orgid/workspaces/:id`

**Form Handling:**
- Ant Design Form with declarative validation
- Multi-step wizards using Steps component
- Programmatic form control via form instance
- Inline validation rules with custom messages

**Type System:**
- Comprehensive TypeScript types in domain/types.ts
- 15+ domain models (Organization, Workspace, Job, Module, etc.)
- AttributeWrapped pattern for JSON:API compatibility
- Flat* types for simplified rendering

### Identified Improvement Opportunities

1. **API Client Inconsistency** - Migrate all direct axios calls to apiWrapper pattern
2. **Redux Underutilization** - Either fully adopt Redux or remove it for React Context
3. **Form Validation Inconsistency** - Create shared validation utilities module
4. **Error Handling Fragmentation** - Standardize error display and HTTP status handling
5. **Type Safety Gaps** - Convert remaining .js files to .ts (store/index.js, reportWebVitals.js)

### Components Requiring Improvement

1. **Workspace Creation Form** (domain/Workspaces/Create.tsx):
   - 720+ lines, highly complex multi-step wizard
   - Mixed concerns (UI, business logic, API calls)
   - Recommendation: Split into smaller components, extract wizard logic

2. **API Wrapper** (modules/api/apiWrapper.ts):
   - Good pattern but underutilized
   - Recommendation: Migrate all direct axios usage to this pattern

3. **Organization Settings** (domain/Settings/Settings.tsx):
   - Likely complex tab-based interface with multiple nested forms
   - Recommendation: Review for similar complexity issues as Create.tsx

### Technical Debt Patterns

- **Direct axios usage** scattered across components instead of using apiWrapper
- **Mixed .js and .ts files** reducing type safety
- **Prop drilling** for organization context (could use Context API)
- **Inline validation rules** duplicated across forms
- **Inconsistent error handling** (try-catch vs. hook vs. inline)
- **Session storage keys** as string literals instead of constants (partially addressed with actionTypes.ts)

### Next Phase Recommendations

For Phase 03 (Backend Services Overview), focus on:
1. Understanding JSON:API specification implementation
2. Mapping frontend domain models to backend entities
3. Examining GraphQL endpoint usage and schema
4. Identifying WebSocket/polling for real-time job updates
5. Understanding the "atomic operations" pattern seen in workspace creation