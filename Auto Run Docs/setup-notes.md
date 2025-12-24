# Terrakube Development Environment Setup Notes

## Date: 2025-12-24

## Prerequisites Verification - ✅ COMPLETED

### Java
- **Status**: ✅ Installed
- **Version**: OpenJDK 25.0.1 (Homebrew)
- **Requirement**: Java 17+ (EXCEEDED)

### Node.js and npm
- **Status**: ✅ Installed
- **Node Version**: v25.2.1
- **npm Version**: 11.6.2
- **Requirement**: Node.js 18+ (EXCEEDED)

### Docker
- **Status**: ⚠️ Installed but daemon not running
- **Docker Version**: 29.1.3
- **Docker Compose Version**: 5.0.1
- **Action Required**: Start Docker Desktop application

## Frontend Setup - ✅ COMPLETED

### Dependencies Installation
- **Status**: ✅ Completed
- **Location**: `/ui` directory
- **Command**: `npm install --legacy-peer-deps`
- **Note**: Used `--legacy-peer-deps` flag due to React 19.2.3 compatibility issue with `ansi-to-react@6.1.6` (requires React ^16.3.2 || ^17.0.0)
- **Warnings**:
  - 3 vulnerabilities (1 low, 1 moderate, 1 high)
  - Deprecated packages: inflight@1.0.6, glob@7.2.3, @babel/plugin-proposal-private-property-in-object@7.21.11

### Environment Configuration
- **Status**: ✅ Created
- **File**: `/ui/.env.local`
- **Configuration**:
  ```
  REACT_CONFIG_TERRAKUBE_URL=https://terrakube-api.platform.local/api/v1/
  REACT_CONFIG_CLIENT_ID=example-app
  REACT_CONFIG_AUTHORITY=https://terrakube-dex.platform.local
  REACT_CONFIG_REDIRECT=http://localhost:3000
  REACT_CONFIG_REGISTRY_URI=https://terrakube-registry.platform.local
  REACT_CONFIG_SCOPE=email openid profile offline_access groups
  ```

## Backend Setup - 🔄 IN PROGRESS

### Completed Steps

#### 1. Start Docker Desktop
- **Status**: ✅ Completed
- **Action**: Launched Docker Desktop application successfully
- **Verification**: `docker ps` confirms daemon is running

#### 2. Create Docker Network
- **Status**: ✅ Completed
- **Network**: terrakube-network (ID: 5909200c7de8)
- **Configuration**: Bridge network with subnet 10.25.25.0/24, gateway 10.25.25.254
- **Verification**: `docker network ls | grep terrakube` shows network exists

### Required Manual Steps

#### 3. Update /etc/hosts - ⚠️ REQUIRES USER ACTION
Add the following entries to `/etc/hosts`:
```
10.25.25.253 terrakube.platform.local
10.25.25.253 terrakube-api.platform.local
10.25.25.253 terrakube-registry.platform.local
10.25.25.253 terrakube-dex.platform.local
```

**Note**: Requires sudo access
```bash
sudo nano /etc/hosts
# Or
sudo vim /etc/hosts
```

#### 4. Generate SSL Certificates (Optional but Recommended)
Install mkcert for local HTTPS:
```bash
brew install mkcert
cd docker-compose
mkcert -install
mkcert -key-file key.pem -cert-file cert.pem platform.local *.platform.local
CAROOT=$(mkcert -CAROOT)/rootCA.pem
cp $CAROOT rootCA.pem
```

#### 5. Start Backend Services
```bash
cd docker-compose
docker-compose up -d --force-recreate
```

#### 6. Verify Services
```bash
docker-compose ps
```

Expected services:
- terrakube-api (Spring Boot API)
- terrakube-dex (Authentication)
- terrakube-postgres (Database)
- terrakube-redis (Cache)
- terrakube-minio (Storage)
- terrakube-ldap (Directory)
- traefik (Reverse Proxy)

## Frontend Start - ⏳ PENDING

### Commands
```bash
cd ui
npm start
```

Expected behavior:
- Development server starts on http://localhost:3000
- Browser opens automatically
- UI should connect to backend services at platform.local domains

## Authentication Details

### Default Credentials
- **Username**: admin@example.com
- **Password**: admin

### Additional Test Users
| User | Password | Groups |
|------|----------|--------|
| aws@example.com | aws | AWS_DEVELOPERS |
| azure@example.com | azure | AZURE_DEVELOPERS |
| gcp@example.com | gcp | GCP_DEVELOPERS |

### Groups
- TERRAKUBE_ADMIN
- TERRAKUBE_DEVELOPERS
- AZURE_DEVELOPERS
- AWS_DEVELOPERS
- GCP_DEVELOPERS

## Access URLs (After Complete Setup)

- **Frontend**: http://localhost:3000
- **Backend API**: https://terrakube-api.platform.local/api/v1/
- **Dex Authentication**: https://terrakube-dex.platform.local
- **Registry**: https://terrakube-registry.platform.local
- **Main Portal**: https://terrakube.platform.local

## Known Issues and Resolutions

### Issue 1: npm install dependency conflict
- **Problem**: React 19.2.3 incompatible with ansi-to-react@6.1.6
- **Solution**: Used `--legacy-peer-deps` flag
- **Impact**: May have broken dependencies, but allows installation to proceed

### Issue 2: Docker daemon not running
- **Problem**: Cannot connect to Docker daemon
- **Solution**: Must start Docker Desktop application manually
- **Status**: Requires manual intervention

### Issue 3: Missing /etc/hosts entries
- **Problem**: Local domains not configured
- **Solution**: Requires sudo to edit /etc/hosts file
- **Status**: Requires manual intervention

## Next Steps

1. ✅ Prerequisites verified (Java 25.0.1, Node.js 25.2.1, npm 11.6.2, Docker installed)
2. ✅ Frontend dependencies installed
3. ✅ Environment configuration created
4. ✅ Docker Desktop started
5. ✅ Docker network created (terrakube-network)
6. ⚠️ **MANUAL ACTION REQUIRED**: Configure /etc/hosts - See `/Auto Run Docs/Working/MANUAL-STEP-REQUIRED.md`
7. ⏳ (Optional) Generate SSL certificates
8. ⏳ Start backend services with docker-compose (ready once /etc/hosts configured)
9. ⏳ Start frontend development server
10. ⏳ Test login and core functionality
11. ⏳ Document working features

## Current Blocker

**The setup is blocked on /etc/hosts configuration** which requires sudo access and cannot be automated.

### Status Update (2025-12-24 10:22 CST)

- ✅ All Docker services are **UP and HEALTHY** (10 containers running)
- ❌ `/etc/hosts` is **NOT configured** - domains cannot be resolved
- 📋 **Action Required**: Manual /etc/hosts configuration

See comprehensive guide at: `/Auto Run Docs/Working/MANUAL-HOSTS-CONFIGURATION-GUIDE.md`

Once you've added the /etc/hosts entries, you can immediately:
1. Start the React dev server: `cd ui && npm start`
2. Access the UI at `http://localhost:3000`
3. Login with `admin@example.com` / `admin`
4. Verify frontend-backend communication in browser console

## Development Architecture

Based on repository exploration:
- **Frontend**: React UI with Vite build system (ui directory)
- **Backend**: Spring Boot Java API (api directory)
- **Authentication**: Dex with OpenLDAP connector
- **Database**: PostgreSQL 17
- **Cache**: Redis 7.0.10
- **Storage**: MinIO S3-compatible storage
- **Reverse Proxy**: Traefik
- **Orchestration**: Docker Compose for local development

## Reference Documentation

- Main README: `/README.md`
- Development Guide: `/development.md`
- UI Setup: `/ui/README.md`
- Docker Compose Setup: `/docker-compose/README.md`
- Contributing: `/CONTRIBUTING.md`
