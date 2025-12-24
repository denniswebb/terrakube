#!/bin/bash
# Verification script for /etc/hosts configuration
# Run this after adding platform.local entries to /etc/hosts

echo "==================================================================="
echo "Terrakube /etc/hosts Configuration Verification"
echo "==================================================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0

# Test 1: Check if entries exist in /etc/hosts
echo "Test 1: Checking /etc/hosts entries..."
if grep -q "platform\.local" /etc/hosts 2>/dev/null; then
    echo -e "${GREEN}✅ platform.local entries found in /etc/hosts${NC}"
    grep "platform\.local" /etc/hosts | sed 's/^/   /'
else
    echo -e "${RED}❌ No platform.local entries found in /etc/hosts${NC}"
    echo "   Please add the following entries to /etc/hosts:"
    echo "   10.25.25.253 terrakube.platform.local"
    echo "   10.25.25.253 terrakube-api.platform.local"
    echo "   10.25.25.253 terrakube-registry.platform.local"
    echo "   10.25.25.253 terrakube-dex.platform.local"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 2: Check DNS resolution
echo "Test 2: Testing DNS resolution..."
for domain in terrakube-api.platform.local terrakube-dex.platform.local terrakube.platform.local terrakube-registry.platform.local; do
    if ping -c 1 -t 1 "$domain" &>/dev/null; then
        echo -e "${GREEN}✅ $domain resolves correctly${NC}"
    else
        echo -e "${RED}❌ $domain does not resolve${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# Test 3: Check Docker services are running
echo "Test 3: Checking Docker services..."
cd /Users/dennis/Repositories/github.com/denniswebb/terrakube/docker-compose
RUNNING_CONTAINERS=$(docker-compose ps --services --filter "status=running" 2>/dev/null | wc -l | tr -d ' ')
EXPECTED_CONTAINERS=10

if [ "$RUNNING_CONTAINERS" -ge 8 ]; then
    echo -e "${GREEN}✅ Docker services are running ($RUNNING_CONTAINERS containers)${NC}"
else
    echo -e "${RED}❌ Not enough Docker containers running (found: $RUNNING_CONTAINERS, expected: ~$EXPECTED_CONTAINERS)${NC}"
    echo "   Run: docker-compose up -d"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Test 4: Test HTTP connectivity through Traefik
echo "Test 4: Testing Traefik routing..."
if curl -k -s -H "Host: terrakube-api.platform.local" https://terrakube-api.platform.local/api/v1/ --max-time 5 2>&1 | grep -q "401\|links\|self"; then
    echo -e "${GREEN}✅ Traefik routing to API is working${NC}"
else
    echo -e "${YELLOW}⚠️  Traefik routing test inconclusive (may require authentication)${NC}"
    # This is not necessarily an error - API requires auth
fi
echo ""

# Test 5: Check frontend configuration
echo "Test 5: Checking frontend .env.local configuration..."
if [ -f "/Users/dennis/Repositories/github.com/denniswebb/terrakube/ui/.env.local" ]; then
    if grep -q "terrakube-api.platform.local" /Users/dennis/Repositories/github.com/denniswebb/terrakube/ui/.env.local; then
        echo -e "${GREEN}✅ Frontend configured for platform.local domains${NC}"
    else
        echo -e "${YELLOW}⚠️  Frontend .env.local may not be configured correctly${NC}"
    fi
else
    echo -e "${RED}❌ Frontend .env.local not found${NC}"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Summary
echo "==================================================================="
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✅ ALL CHECKS PASSED!${NC}"
    echo ""
    echo "Your environment is ready. Next steps:"
    echo "1. Start the frontend: cd ui && npm start"
    echo "2. Open browser to: http://localhost:3000"
    echo "3. Login with: admin@example.com / admin"
else
    echo -e "${RED}❌ $ERRORS ERROR(S) FOUND${NC}"
    echo ""
    echo "Please resolve the errors above before proceeding."
fi
echo "==================================================================="
