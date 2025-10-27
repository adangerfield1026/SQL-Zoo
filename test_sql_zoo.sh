#!/bin/bash
# ===========================================
# SQL-Zoo Repository Query Testing Script
# ===========================================
# This script tests all queries from the repository
# Run from: ~/Documents/GitHub/SQL-Zoo/SQL-Zoo

echo "================================================"
echo "SQL-Zoo Repository Query Verification Test"
echo "================================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
total_tests=0
passed_tests=0
failed_tests=0

# Function to test a query
test_query() {
    local db=$1
    local query=$2
    local test_name=$3
    
    total_tests=$((total_tests + 1))
    echo -n "Testing: $test_name... "
    
    result=$(psql -U postgres -d "$db" -t -c "$query" 2>&1)
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}PASSED${NC}"
        passed_tests=$((passed_tests + 1))
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        echo "  Error: $result"
        failed_tests=$((failed_tests + 1))
        return 1
    fi
}

# ===========================================
# Test Database Connections
# ===========================================
echo "Step 1: Testing Database Connections"
echo "-------------------------------------"

test_query "postgres" "SELECT version();" "PostgreSQL Connection"
test_query "playstore_db" "SELECT 1;" "PlayStore Database"
test_query "products_db" "SELECT 1;" "Products Database"
test_query "vehicles_db" "SELECT 1;" "Vehicles Database"

echo ""

# ===========================================
# Test Table Existence
# ===========================================
echo "Step 2: Testing Table Existence"
echo "--------------------------------"

test_query "playstore_db" "SELECT COUNT(*) FROM analytics;" "Analytics Table"
test_query "products_db" "SELECT COUNT(*) FROM products;" "Products Table (may be 0)"
test_query "vehicles_db" "SELECT COUNT(*) FROM owners;" "Owners Table"
test_query "vehicles_db" "SELECT COUNT(*) FROM vehicles;" "Vehicles Table"

echo ""

# ===========================================
# Test Sample Queries from playstore.sql
# ===========================================
echo "Step 3: Testing PlayStore Queries"
echo "----------------------------------"

test_query "playstore_db" "SELECT * FROM analytics WHERE id = 1880;" "Query 1: Find app by ID"
test_query "playstore_db" "SELECT id, app_name FROM analytics WHERE last_updated = '2018-08-01';" "Query 2: Apps updated on date"
test_query "playstore_db" "SELECT category, COUNT(*) FROM analytics GROUP BY category LIMIT 1;" "Query 3: Count by category"
test_query "playstore_db" "SELECT * FROM analytics ORDER BY reviews DESC LIMIT 5;" "Query 4: Top 5 reviewed"
test_query "playstore_db" "SELECT * FROM analytics WHERE rating >= 4.8 ORDER BY reviews DESC LIMIT 1;" "Query 5: Top rated with reviews"
test_query "playstore_db" "SELECT category, AVG(rating) FROM analytics GROUP BY category ORDER BY avg DESC LIMIT 1;" "Query 6: Avg rating by category"

echo ""

# ===========================================
# Test Advanced Queries from study.sql
# ===========================================
echo "Step 4: Testing Advanced Queries"
echo "---------------------------------"

test_query "playstore_db" "SELECT * FROM analytics WHERE app_name ILIKE '%facebook%' LIMIT 1;" "FS2: ILIKE pattern matching"
test_query "playstore_db" "SELECT * FROM analytics WHERE array_length(genres, 1) = 2 LIMIT 1;" "FS3: Array length check"
test_query "playstore_db" "SELECT * FROM analytics WHERE genres @> '{\"Education\"}' LIMIT 1;" "FS4: Array containment"

echo ""

# ===========================================
# Test JOIN Queries
# ===========================================
echo "Step 5: Testing JOIN Operations"
echo "--------------------------------"

test_query "vehicles_db" "SELECT * FROM owners o FULL OUTER JOIN vehicles v ON o.id=v.owner_id LIMIT 1;" "Query 1: Full outer join"
test_query "vehicles_db" "SELECT first_name, last_name, COUNT(owner_id) FROM owners o JOIN vehicles v on o.id=v.owner_id GROUP BY (first_name, last_name) ORDER BY first_name LIMIT 1;" "Query 2: Join with count"

echo ""

# ===========================================
# Test Data Integrity
# ===========================================
echo "Step 6: Testing Data Integrity"
echo "-------------------------------"

# Check if we have enough data for queries
app_count=$(psql -U postgres -d playstore_db -t -c "SELECT COUNT(*) FROM analytics;" | tr -d ' ')
if [ "$app_count" -gt 50 ]; then
    echo -e "✓ Analytics table has $app_count rows ${GREEN}(sufficient data)${NC}"
else
    echo -e "⚠ Analytics table has only $app_count rows ${YELLOW}(may need more data)${NC}"
fi

# Check for category with 300+ apps (needed for Query 14)
large_categories=$(psql -U postgres -d playstore_db -t -c "SELECT COUNT(*) FROM (SELECT category FROM analytics GROUP BY category HAVING COUNT(*) > 300) AS subq;" | tr -d ' ')
if [ "$large_categories" -gt 0 ]; then
    echo -e "✓ Found $large_categories categories with 300+ apps ${GREEN}(Query 14 ready)${NC}"
else
    echo -e "⚠ No categories with 300+ apps ${YELLOW}(may need more data for Query 14)${NC}"
fi

# Check for expensive apps (needed for Query 7)
expensive_count=$(psql -U postgres -d playstore_db -t -c "SELECT COUNT(*) FROM analytics WHERE price > 100;" | tr -d ' ')
if [ "$expensive_count" -gt 0 ]; then
    echo -e "✓ Found $expensive_count expensive apps ${GREEN}(Query 7 ready)${NC}"
else
    echo -e "⚠ No expensive apps found ${YELLOW}(Query 7 may fail)${NC}"
fi

echo ""

# ===========================================
# Summary
# ===========================================
echo "================================================"
echo "Test Summary"
echo "================================================"
echo -e "Total Tests: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $failed_tests${NC}"
echo ""

if [ $failed_tests -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed! Your SQL-Zoo setup is complete!${NC}"
    echo ""
    echo "You can now run queries from:"
    echo "  - playstore.sql (in playstore_db)"
    echo "  - products.sql (in products_db)"
    echo "  - queries.sql (in vehicles_db)"
    echo "  - study.sql (in playstore_db)"
    echo ""
    echo "Example: psql -U postgres -d playstore_db -f playstore.sql"
else
    echo -e "${YELLOW}⚠ Some tests failed. Check the errors above.${NC}"
    echo ""
    echo "Common issues:"
    echo "  1. Database not created - Run the CREATE DATABASE commands"
    echo "  2. Tables not created - Run the table creation scripts"
    echo "  3. No data loaded - Run load_playstore_data.sql"
    echo "  4. Password incorrect - Check your PostgreSQL password"
fi

echo "================================================"
