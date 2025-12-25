# Terrakube Frontend Architecture

## Overview
The Terrakube UI is a modern React 19 single-page application (SPA) built with TypeScript, using Ant Design as the component library. The application uses Vite as the build tool and implements OIDC-based authentication for secure access.

## Technology Stack

### Core Framework
- **React**: 19.2.3
- **TypeScript**: 5.9.3
- **Build Tool**: Vite 7.3.0
- **Router**: React Router DOM 7.11.0

### UI Framework & Libraries
- **Component Library**: Ant Design (antd) 6.1.1
- **Icons**: @ant-design/icons 6.1.0, react-icons 5.5.0
- **Code Editor**: @monaco-editor/react 4.7.0
- **Visualizations**: react-vis 1.12.1, reactflow 11.11.3
- **Markdown**: react-markdown 10.1.0

### State Management
- **Redux**: 5.0.1 (minimal usage - see State Management section)

### Authentication
- **OIDC Library**: react-oidc-context 3.3.0
- **OIDC Client**: oidc-client-ts 3.4.1

### HTTP Client
- **Axios**: 1.13.2 (with custom wrappers for API communication)

## Directory Structure

```
ui/src/
├── config/               # Configuration files
│   ├── actionTypes.ts    # Redux action type constants
│   ├── authConfig.ts     # OIDC authentication configuration
│   ├── authUser.ts       # User authentication utilities
│   ├── axiosConfig.ts    # Axios instance configuration with interceptors
│   ├── monacoConfig.ts   # Monaco code editor configuration
│   └── themeConfig.ts    # Theme configuration (light/dark modes)
│
├── domain/               # Feature-based page components
│   ├── Home/            # Main app shell and routing
│   │   ├── App.tsx      # Main router configuration
│   │   └── MainMenu.tsx # Navigation menu
│   ├── Login/           # Authentication pages
│   ├── Organizations/   # Organization management
│   ├── Workspaces/      # Workspace CRUD operations
│   ├── Modules/         # Terraform module registry
│   ├── Jobs/            # Job execution pages
│   └── Settings/        # Settings and configuration
│
├── modules/              # Shared modules and utilities
│   ├── api/             # API client abstractions
│   │   ├── apiWrapper.ts     # REST API wrapper functions
│   │   ├── useApiRequest.ts  # React hook for API calls
│   │   └── types.ts          # API types
│   ├── layout/          # Layout components
│   ├── organizations/   # Organization-specific components
│   ├── workspaces/      # Workspace-specific components
│   ├── token/           # Token management
│   ├── user/            # User-specific components
│   └── utils/           # Utility functions
│
├── reducers/             # Redux reducers
│   ├── organization/     # Organization state reducer
│   ├── user/            # User state reducer
│   └── root.ts          # Root reducer combiner
│
├── store/                # Redux store configuration
│   └── index.js         # Store creation with DevTools
│
├── types/                # TypeScript type definitions
│   └── index.d.ts       # Global type declarations
│
├── ActionLoader.tsx      # Dynamic component loader for backend actions
└── index.tsx            # Application entry point
```

## Architecture Patterns

### Component Organization

The application follows a **feature-based organization pattern** with two main directories:

1. **`domain/`**: Page-level components representing complete routes
   - Each subdirectory represents a major feature area
   - Contains components that are route targets
   - Example: `domain/Workspaces/Create.tsx` handles the workspace creation page

2. **`modules/`**: Shared, reusable components and utilities
   - Cross-cutting concerns (API, layout, utilities)
   - Feature-specific components used across multiple pages
   - Example: `modules/workspaces/components/` contains workspace-related UI components

### Routing Configuration

Routing is centralized in `domain/Home/App.tsx` using React Router v7's `createBrowserRouter`:

**Main Route Structure:**
```
/ (root with header/footer layout)
├── / → OrganizationsPickerPage
├── /organizations/create → CreateOrganization
├── /organizations/:id/workspaces → OrganizationsDetailPage
├── /workspaces/create → CreateWorkspace
├── /workspaces/:id → WorkspaceDetails
├── /workspaces/:id/runs → WorkspaceDetails (tab 2)
├── /workspaces/:id/states → WorkspaceDetails (tab 3)
├── /workspaces/:id/variables → WorkspaceDetails (tab 4)
├── /workspaces/:id/schedules → WorkspaceDetails (tab 5)
├── /workspaces/:id/settings → WorkspaceDetails (tab 6)
├── /organizations/:orgid/registry → ModuleList
├── /organizations/:orgid/registry/:id → ModuleDetails
├── /organizations/:orgid/settings → OrganizationSettings
│   ├── /general → OrganizationSettings (tab 1)
│   ├── /teams → OrganizationSettings (tab 2)
│   ├── /vcs → OrganizationSettings (tab 4)
│   ├── /ssh → OrganizationSettings (tab 6)
│   ├── /tags → OrganizationSettings (tab 7)
│   ├── /actions → OrganizationSettings (tab 10)
│   └── /collection → OrganizationSettings (tab 9)
└── /settings/tokens → UserSettingsPage
```

**Route Pattern:** The app uses nested routes with a common layout (Header + Footer + Outlet). Most workspace routes support both:
- Short form: `/workspaces/:id`
- Long form with org: `/organizations/:orgid/workspaces/:id`

### State Management

The application uses **minimal Redux** with most state being managed locally in components using React hooks:

**Redux Usage:**
- **Store**: `src/store/index.js` - Simple Redux store with DevTools extension
- **Root Reducer**: Combines `organizationState` and potentially user state
- **Primary Use Case**: Organization context sharing across the app

**Local State Patterns:**
- `useState` for component-local state
- `useEffect` for side effects and data fetching
- `Form.useForm()` from Ant Design for form state management
- Session storage for persistence (`ORGANIZATION_ARCHIVE`, `ORGANIZATION_NAME`)

### API Communication Layer

The app has **two API client patterns** that should be consolidated:

#### Pattern 1: Axios Instance (Legacy)
Located in `config/axiosConfig.ts`:
```typescript
// Three axios instances:
axiosInstance     // For REST API with auth interceptor
axiosClient       // Alternative REST client
axiosGraphQL      // For GraphQL endpoint
```

**Usage:** Direct axios calls in components:
```typescript
axiosInstance.get(`organization/${organizationId}/vcs`)
  .then(response => setVCS(response.data.data))
```

#### Pattern 2: API Wrapper (Modern)
Located in `modules/api/`:
- `apiWrapper.ts`: Provides `apiGet`, `apiPost`, `apiPut`, `apiDelete` functions
- `useApiRequest.ts`: React hook for API calls with loading/error states
- `types.ts`: Shared API types

**Usage:** Declarative hook-based API calls:
```typescript
const { loading, error, execute, notificationContext } = useApiRequest({
  action: (data) => apiPost('/path', data),
  onReturn: (data) => handleSuccess(data),
  showErrorAsNotification: true
});
```

**Recommendation:** Migrate all axios direct calls to the `apiWrapper` pattern for consistency.

### Authentication Flow

The app uses **OIDC (OpenID Connect)** for authentication:

**Flow:**
1. **Entry Point** (`index.tsx`): App wrapped in `<AuthProvider>` with OIDC config
2. **Config** (`config/authConfig.ts`):
   - Authority, client ID, redirect URI from `window._env_`
   - Token storage in localStorage via `WebStorageStateStore`
   - Custom `useAuth()` hook for accessing auth context

3. **Login Guard** (`domain/Home/App.tsx`):
   ```typescript
   if (!auth.isAuthenticated) {
     return <Login />;
   }
   ```

4. **Login Page** (`domain/Login/Login.tsx`):
   - Calls `mgr.signinRedirect()` to redirect to OIDC provider
   - After successful auth, redirects back to app

5. **Token Injection** (`config/axiosConfig.ts`):
   - Axios request interceptor reads user from localStorage
   - Adds `Authorization: Bearer ${accessToken}` header to all requests

6. **Token Expiry Check** (`domain/Home/App.tsx`):
   - Checks `user.expires_at` against current time
   - Clears localStorage and forces re-login if expired

### Form Handling Patterns

Terrakube uses **Ant Design Form** extensively:

**Pattern Example** (from `domain/Workspaces/Create.tsx`):
```typescript
const [form] = Form.useForm();

// Multi-step form with conditional fields
<Form
  form={form}
  layout="vertical"
  onFinish={onFinish}
  onFinishFailed={onFinishFailed}
  validateMessages={validateMessages}
  initialValues={{ folder: "/" }}
>
  <Form.Item
    name="name"
    label="Workspace Name"
    rules={[
      { required: true },
      { pattern: /^[A-Za-z0-9_-]+$/, message: "..." }
    ]}
    extra="Explanation text"
  >
    <Input />
  </Form.Item>
</Form>
```

**Key Patterns:**
- Declarative validation rules
- Programmatic form control via `form.setFieldsValue()`, `form.getFieldValue()`
- Multi-step wizards using Steps component + hidden form sections
- Conditional field visibility using `hidden` prop
- Custom validation messages via `validateMessages` prop

### Error Handling Patterns

**API Errors:**
1. **Try-Catch in Components:**
   ```typescript
   .catch((error) => {
     if (error.response?.status === 403) {
       message.error(<span>Authorization message</span>);
     } else {
       message.error(<span>Generic error</span>);
     }
   })
   ```

2. **useApiRequest Hook:**
   ```typescript
   const { error, loading, execute } = useApiRequest({
     showErrorAsNotification: true, // Automatically shows notification
     requestErrorInfo: { title: "...", message: "..." }
   });
   ```

3. **API Wrapper Error Handling** (`apiWrapper.ts`):
   - Returns structured error objects: `{ isError: true, error: {...}, responseCode: number }`
   - Handles 404 specially with custom message
   - Falls back to status text for unknown errors

**Component Errors:**
- `ActionLoader.tsx` has an ErrorBoundary for dynamic component loading
- Most components rely on Ant Design's built-in error display

### Loading State Patterns

**Common Pattern:**
```typescript
const [loading, setLoading] = useState(false);

useEffect(() => {
  setLoading(true);
  axiosInstance.get(url)
    .then(response => {
      setData(response.data.data);
      setLoading(false);
    });
}, []);

// In render:
{loading ? <p>Data loading...</p> : <ComponentContent />}
```

**Alternative with Hook:**
```typescript
const { loading, error, execute } = useApiRequest({...});

// loading state managed by hook
{loading && <Spin />}
```

## Domain Models & TypeScript Types

Located in `domain/types.ts`, key domain models include:

### Core Entities
- **Organization**: `{ id, attributes: { name, description, executionMode, icon } }`
- **Workspace**: `{ id, attributes: { name, source, branch, folder, terraformVersion, iacType, ... }, relationships }`
- **Job**: `{ id, attributes: { status, via, output, ... } }` with enums `JobStatus`, `JobVia`
- **Template**: `{ id, attributes: { name, description, tcl, image } }`
- **Module**: `{ id, attributes: { name, provider, source, versions, ... } }`

### Supporting Types
- **VCS**: VcsModel with VcsType enum (GITHUB, GITLAB, BITBUCKET, AZURE_DEVOPS)
- **Team**: Team with permission flags (manageWorkspace, manageJob, etc.)
- **Variable**: Variable with VariableAttributes (key, value, sensitive, category)
- **Schedule**: Schedule with cron configuration
- **Tag**: Simple tag model for workspace categorization
- **Action**: Custom actions with display criteria

### Type Patterns
- **Attribute Wrapping**: `AttributeWrapped<T>` pattern separates id from attributes
- **API Responses**: `ApiResponse<T>` wrapper for data
- **Flat Types**: `Flat*` versions (FlatOrganization, FlatJob) combine id + attributes for easier rendering
- **Relationships**: `RelationshipItem` and `RelationshipArray` for JSON:API relationships

## Key Configuration

### Environment Variables
Loaded from `window._env_` (populated by `env-config.js`):
- `REACT_APP_AUTHORITY`: OIDC authority URL
- `REACT_APP_CLIENT_ID`: OIDC client ID
- `REACT_APP_REDIRECT_URI`: OAuth redirect URI
- `REACT_APP_SCOPE`: OAuth scopes
- `REACT_APP_TERRAKUBE_API_URL`: Backend API base URL
- `REACT_APP_TERRAKUBE_VERSION`: App version for footer
- `REACT_APP_REGISTRY_URI`: Module registry URI

### TypeScript Configuration
- **tsconfig.json**: Base configuration
- **tsconfig.app.json**: App-specific settings
- **tsconfig.node.json**: Node/Vite build settings
- **tsconfig.test.json**: Test environment settings

### Build Configuration
- **Vite**: Modern build tool with fast HMR
- **ESLint**: TypeScript ESLint with React, Prettier, and accessibility plugins
- **Prettier**: Code formatting
- **Jest**: Testing framework with React Testing Library

## Notable Architectural Features

### 1. Dynamic Component Loader (ActionLoader.tsx)
A sophisticated system for loading backend-defined UI components:
- Decodes base64-encoded JSX from backend
- Dynamically imports Ant Design components and icons
- Transpiles JSX to JavaScript using Babel standalone
- Creates isolated component context with required dependencies
- Error boundary for safe rendering

**Use Case:** Allows backend to define custom UI actions without frontend deployment

### 2. Theme Support
- Color schemes: Default, Blue, Green, Orange, Purple, Red
- Theme modes: Light, Dark
- Stored in localStorage: `terrakube-color-scheme`, `terrakube-theme-mode`
- Applied via Ant Design ConfigProvider

### 3. Multi-Workspace Routing
Supports both organizational and global workspace access:
- `/workspaces/:id` - Direct workspace access
- `/organizations/:orgid/workspaces/:id` - Org-scoped access

Both resolve to the same component but maintain context differently.

### 4. Session Management
Uses sessionStorage for ephemeral organization context:
- `ORGANIZATION_ARCHIVE`: Current organization ID
- `ORGANIZATION_NAME`: Current organization name
- Prevents repeated API calls for org details during navigation

## Identified Improvement Opportunities

### 1. API Client Inconsistency
**Issue:** Two competing API patterns (direct axios vs. apiWrapper)
**Impact:** Inconsistent error handling, loading states, and code duplication
**Recommendation:**
- Migrate all direct `axiosInstance` calls to `apiWrapper` functions
- Standardize on `useApiRequest` hook for component API calls
- Create higher-level hooks for common operations (useWorkspace, useOrganization, etc.)

### 2. Redux Underutilization
**Issue:** Redux store only used for organization state, most state is local
**Impact:**
- Prop drilling for organization context
- Repeated API calls for the same data
- Inconsistent state management patterns
**Recommendation:**
- Either fully adopt Redux for global state (organizations, user, auth)
- Or remove Redux entirely and use React Context API for the minimal global state needed
- Consider React Query/SWR for server state management

### 3. Form Validation Inconsistency
**Issue:** Mix of inline validation rules and scattered validation logic
**Example:** Some forms use regex patterns in JSX, others use functions
**Recommendation:**
- Create a shared validation utilities module
- Define reusable validation rules (workspace name, git URL, etc.)
- Centralize validation messages

### 4. Error Handling Fragmentation
**Issue:** Error handling varies by component:
- Some use try-catch with inline messages
- Some use useApiRequest with notifications
- Some show errors in UI state
- HTTP status codes handled inconsistently
**Recommendation:**
- Standardize on notification-based error display for operations
- Use inline errors for form validation
- Create error boundary for unexpected errors
- Centralize HTTP error code handling (401, 403, 404, 500)

### 5. Type Safety Gaps
**Issue:** Some files use `.js` instead of `.ts` (store/index.js, reportWebVitals.js)
**Impact:** Reduced type safety at critical integration points
**Recommendation:** Convert all `.js` files to `.ts` for full type coverage

## Component Patterns Summary

### Good Patterns to Follow
✅ Feature-based directory organization
✅ TypeScript for type safety
✅ Ant Design Form for declarative forms
✅ useApiRequest hook for API calls with loading/error states
✅ Session storage for transient state
✅ OIDC for authentication
✅ Centralized routing in App.tsx

### Patterns to Avoid/Refactor
❌ Direct axios calls in components (use apiWrapper)
❌ Mixing Redux and local state arbitrarily (pick a strategy)
❌ Inline error handling (centralize)
❌ Scattered validation logic (create shared validators)
❌ JavaScript files in TypeScript project (convert to .ts)

## Testing Strategy

### Current Setup
- **Jest**: 30.2.0 with jsdom environment
- **React Testing Library**: 16.3.1
- **Test Scripts**:
  - `npm test`: Run all tests
  - `npm run lint`: ESLint check
  - `npm run format`: Prettier format

### Test Organization
Tests should be colocated with components or in a dedicated `__tests__` directory per feature.

**Example Structure:**
```
domain/Workspaces/
├── Create.tsx
├── Create.test.tsx
└── __tests__/
    └── integration.test.tsx
```

## Next Steps for Phase 03

Based on this exploration, the next phase (Backend Services Overview) should focus on:
1. Understanding the API contract between frontend and backend
2. Identifying the JSON:API specification usage
3. Mapping frontend domain models to backend entities
4. Understanding the GraphQL endpoint usage
5. Examining WebSocket or polling for real-time updates

---

**Document Created:** 2024-12-24
**Phase:** 02 - Frontend Codebase Exploration
**Author:** terrakube-cc (Maestro AI Agent)
