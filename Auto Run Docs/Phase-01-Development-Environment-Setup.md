# Phase 01: Development Environment Setup & Working Application

This phase establishes a complete local development environment for Terrakube and gets the application running end-to-end. By the end of this phase, you'll have the frontend UI running in your browser connected to backend services, giving you a working system to explore and modify. This is your foundation for making meaningful contributions.

## Tasks

- [x] Verify Java 17+ is installed by running `java -version` and install if needed
  - ✅ OpenJDK 25.0.1 installed (exceeds requirement)
- [x] Verify Node.js 18+ and npm are installed by running `node -v` and `npm -v`, install if needed
  - ✅ Node.js v25.2.1 and npm 11.6.2 installed (exceeds requirement)
- [x] Verify Docker and Docker Compose are installed and running by executing `docker --version` and `docker-compose --version`
  - ✅ Docker 29.1.3 and Docker Compose 5.0.1 installed
  - ⚠️ Docker daemon not currently running - requires starting Docker Desktop
- [x] Navigate to the ui directory and run `npm install` to install all frontend dependencies
  - ✅ Completed with `--legacy-peer-deps` flag due to React 19 compatibility issue with ansi-to-react
  - ⚠️ 3 vulnerabilities detected (1 low, 1 moderate, 1 high)
- [x] Create a `.env.local` file in the ui directory with development configuration pointing to local backend services
  - ✅ Created with configuration for local platform.local domains
- [x] Start the React development server with `npm start` from the ui directory and verify it opens in browser at http://localhost:3000
  - ✅ Development server started successfully on port 3000
  - ✅ Vite dev server responding with HTTP 200
  - ✅ Browser opened automatically (Chrome detected)
  - ⚠️ Backend API not accessible (expected - requires Docker services)
  - ⚠️ /etc/hosts not configured for platform.local domains (manual step required)
  - 📝 Frontend is running but cannot communicate with backend until services are started
- [x] Navigate to the api directory and examine the README.md or deployment documentation to understand backend service architecture
  - ✅ Reviewed development.md and docker-compose documentation
  - Architecture: Spring Boot API, Dex auth, PostgreSQL, Redis, MinIO, Traefik
- [x] Locate and review the docker-compose.yml file (likely in repository root or deployment folder) that defines all Terrakube services
  - ✅ Located at `/docker-compose/docker-compose.yml`
  - Services: API, Dex, PostgreSQL, Redis, MinIO, LDAP, Traefik
- [ ] Start all backend services using Docker Compose with `docker-compose up -d` from the appropriate directory
  - ⏳ Prerequisites status:
    - ✅ Docker Desktop: Started successfully
    - ✅ Docker Network: Created (terrakube-network with 10.25.25.0/24 subnet)
    - ⚠️ /etc/hosts: **MANUAL STEP REQUIRED** - See `/Auto Run Docs/Working/MANUAL-STEP-REQUIRED.md`
    - ⏳ SSL Certificates: Optional, can proceed without
  - 📝 Ready to start once /etc/hosts is configured
  - Command: `cd docker-compose && docker-compose up -d --force-recreate`
- [ ] Wait for all containers to be healthy by running `docker-compose ps` and checking status
  - ⏳ Pending backend startup
- [ ] Verify the frontend can communicate with backend by checking the browser console for successful API calls or attempting to log in
  - ⏳ Pending both frontend and backend startup
- [ ] Create a test workspace or navigate through the UI to confirm core functionality is working
  - ⏳ Pending full stack startup
- [x] Document any errors or warnings encountered during setup in a setup-notes.md file in the Auto Run Docs directory
  - ✅ Comprehensive setup-notes.md created with all configuration details, blockers, and next steps
- [ ] Take a screenshot or note which features are working to establish your baseline understanding
  - ⏳ Pending full stack startup
- [ ] Run `git status` to confirm your working directory is clean and on a feature branch for future work
  - ⏳ Will complete after manual setup steps