# MANUAL STEP REQUIRED: Configure /etc/hosts

## Status
- Docker Desktop: ✅ Started
- Docker Network: ✅ Created (terrakube-network)
- /etc/hosts Configuration: ⚠️ **REQUIRES YOUR ACTION**

## What You Need To Do

Add the following entries to your `/etc/hosts` file:

```
10.25.25.253 terrakube.platform.local
10.25.25.253 terrakube-api.platform.local
10.25.25.253 terrakube-registry.platform.local
10.25.25.253 terrakube-dex.platform.local
```

## How To Do It

### Option 1: Using Terminal (Recommended)
```bash
sudo nano /etc/hosts
```
Then add the lines above at the end of the file, save (Ctrl+O, Enter, Ctrl+X).

### Option 2: Using vim
```bash
sudo vim /etc/hosts
```
Press `i` to enter insert mode, add the lines, press `Esc`, type `:wq` and press Enter.

### Option 3: One Command (Copy/Paste)
```bash
sudo sh -c 'echo "
# Terrakube local development
10.25.25.253 terrakube.platform.local
10.25.25.253 terrakube-api.platform.local
10.25.25.253 terrakube-registry.platform.local
10.25.25.253 terrakube-dex.platform.local" >> /etc/hosts'
```

## Verification
After adding the entries, verify with:
```bash
cat /etc/hosts | grep terrakube
```

You should see the four entries listed above.

## Why This Is Needed
The Terrakube docker-compose setup uses local domain names (platform.local) instead of localhost. These entries tell your computer to route those domains to the Docker containers running at IP address 10.25.25.253.

## What Happens Next
Once you've added these entries, the automated setup can continue with:
1. Starting all backend services with docker-compose
2. Verifying containers are healthy
3. Testing the complete stack

## The entries are already in hosts-entries.txt
You can find the exact text to add in:
`/Users/dennis/Repositories/github.com/denniswebb/terrakube/Auto Run Docs/Working/hosts-entries.txt`
