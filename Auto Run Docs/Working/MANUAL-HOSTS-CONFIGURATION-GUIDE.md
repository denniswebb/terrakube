# /etc/hosts Configuration Guide for Terrakube

## Current Status: BLOCKER - Manual Action Required

This task **cannot be completed automatically** because modifying `/etc/hosts` requires sudo/administrator privileges that Claude Code does not have.

## What Needs to Be Done

Add the following entries to your `/etc/hosts` file to enable local domain routing for Terrakube services:

```
10.25.25.253 terrakube.platform.local
10.25.25.253 terrakube-api.platform.local
10.25.25.253 terrakube-registry.platform.local
10.25.25.253 terrakube-dex.platform.local
```

## Why This Is Required

1. **Docker Services Are Running**: All backend services are successfully running in Docker containers
2. **Traefik Reverse Proxy**: Traefik is listening on `10.25.25.253:80` and `10.25.25.253:443`
3. **Domain-Based Routing**: Traefik routes requests based on the `Host` header:
   - `terrakube-api.platform.local` → API service (port 8080)
   - `terrakube-dex.platform.local` → Dex authentication (port 5556)
   - `terrakube-registry.platform.local` → Registry service
   - `terrakube.platform.local` → UI service
4. **Frontend Configuration**: The React app is configured (in `.env.local`) to communicate with these domains
5. **DNS Resolution**: Without `/etc/hosts` entries, your system cannot resolve `*.platform.local` domains to the Traefik IP address

## How to Configure /etc/hosts

### Option 1: Using nano (Recommended for beginners)

```bash
sudo nano /etc/hosts
```

1. Enter your password when prompted
2. Scroll to the bottom of the file
3. Add the four lines shown above
4. Press `Ctrl+O` to save
5. Press `Enter` to confirm
6. Press `Ctrl+X` to exit

### Option 2: Using vim

```bash
sudo vim /etc/hosts
```

1. Enter your password when prompted
2. Press `i` to enter insert mode
3. Scroll to the bottom and add the four lines
4. Press `Esc` to exit insert mode
5. Type `:wq` and press `Enter` to save and quit

### Option 3: Using echo (One-liner)

```bash
echo "10.25.25.253 terrakube.platform.local
10.25.25.253 terrakube-api.platform.local
10.25.25.253 terrakube-registry.platform.local
10.25.25.253 terrakube-dex.platform.local" | sudo tee -a /etc/hosts
```

## Verification After Configuration

Once you've added the entries, verify they work:

```bash
# Test DNS resolution
ping -c 1 terrakube-api.platform.local

# Expected output: 64 bytes from 10.25.25.253...
```

```bash
# Test HTTP access through Traefik
curl -H "Host: terrakube-api.platform.local" http://10.25.25.253/api/v1/

# Expected: JSON response from the API
```

## What Happens Next

Once `/etc/hosts` is configured:

1. **Frontend can reach backend**: The React app will be able to make API calls to `https://terrakube-api.platform.local/api/v1/`
2. **Authentication will work**: Dex login flow will function at `https://terrakube-dex.platform.local`
3. **Full stack operational**: You can test the complete login and workspace creation flow

## Current Service Status

All backend services are **UP and HEALTHY**:

```
✅ PostgreSQL - Ready on port 5432
✅ API Server - Running on port 8080
✅ Dex Auth - Listening on port 5556
✅ MinIO - Running on port 9000
✅ Redis - Operational
✅ LDAP - Operational
✅ Traefik - Listening on ports 80/443 at 10.25.25.253
✅ UI Container - Running
✅ Executor - Running
✅ Registry - Running
```

## After Configuration - Next Steps

1. Start the React development server:
   ```bash
   cd /Users/dennis/Repositories/github.com/denniswebb/terrakube/ui
   npm start
   ```

2. Open browser to `http://localhost:3000`

3. Login with default credentials:
   - Username: `admin@example.com`
   - Password: `admin`

4. Verify the browser console shows successful API calls to `https://terrakube-api.platform.local`

## Default Test Credentials

| User | Password | Groups |
|------|----------|--------|
| admin@example.com | admin | TERRAKUBE_ADMIN |
| aws@example.com | aws | AWS_DEVELOPERS |
| azure@example.com | azure | AZURE_DEVELOPERS |
| gcp@example.com | gcp | GCP_DEVELOPERS |

## Troubleshooting

### Issue: "connection refused" after adding /etc/hosts

**Check if Docker services are running:**
```bash
cd /Users/dennis/Repositories/github.com/denniswebb/terrakube/docker-compose
docker-compose ps
```

All services should show "Up" status.

### Issue: "SSL certificate error"

This is **expected** if you haven't generated SSL certificates. The application will still work, but you'll need to accept the browser warning or generate certificates using mkcert (see setup-notes.md).

### Issue: "404 Not Found"

Verify the Host header is being sent correctly. The Traefik routing depends on the correct hostname.

## Reference Files

- Docker Compose configuration: `/docker-compose/docker-compose.yml`
- Environment variables: `/docker-compose/.env`
- Frontend configuration: `/ui/.env.local`
- Complete setup notes: `/Auto Run Docs/setup-notes.md`
