#!/bin/bash

# Test script to verify API endpoints are working
API_BASE="http://10.0.110.97:8000/api"

echo "Testing DMX API endpoints..."

echo "1. Testing GET /api/groups"
curl -v -X GET "$API_BASE/groups" 2>&1

echo -e "\n\n2. Testing GET /api/groups/front-lights"
curl -v -X GET "$API_BASE/groups/front-lights" 2>&1

echo -e "\n\n3. Testing POST /api/groups/front-lights"
curl -v -X POST "$API_BASE/groups/front-lights" \
     -H "Content-Type: application/json" \
     -d '{"Intensity":{"Intensity":1.0}}' 2>&1

echo -e "\n\n4. Testing GET /api/presets"
curl -v -X GET "$API_BASE/presets" 2>&1

echo -e "\n\n5. Testing GET /api/presets/all-on"
curl -v -X GET "$API_BASE/presets/all-on" 2>&1

echo -e "\n\n6. Testing POST /api/presets/all-on"
curl -v -X POST "$API_BASE/presets/all-on" \
     -H "Content-Type: application/json" \
     -d '{"Intensity":1.0}' 2>&1

echo -e "\n\nTest complete."