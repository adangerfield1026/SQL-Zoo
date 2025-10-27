# Windows PostgreSQL Installation & Setup Guide
## Complete Step-by-Step Instructions for SQL-Zoo Repository

---

## 📋 Prerequisites

✅ You have:
- Windows OS with Git Bash (MINGW64) ✓
- Repository cloned at `~/Documents/GitHub/SQL-Zoo/SQL-Zoo` ✓

⬜ You need:
- PostgreSQL installed
- Databases configured
- Sample data loaded

---

## Part 1: Install PostgreSQL (15-20 minutes)

### Step 1: Download PostgreSQL

1. **Open your web browser** and go to:
   ```
   https://www.postgresql.org/download/windows/
   ```

2. **Click** on "Download the installer"

3. **Choose the latest version** (PostgreSQL 16.x recommended)
   - Select your Windows version (likely Windows x86-64)
   - Download size: ~300-400 MB

4. **Wait for download to complete**

### Step 2: Run the Installer

1. **Locate the downloaded file** (likely in Downloads folder)
   - File name: `postgresql-16.x-x-windows-x64.exe`

2. **Double-click to run** (may need administrator permission)

3. **Installation Wizard - Click "Next"**

4. **Installation Directory**
   - Default: `C:\Program Files\PostgreSQL\16`
   - ✅ Keep the default - Click "Next"

5. **Select Components** - Make sure these are checked:
   - ✅ PostgreSQL Server
   - ✅ pgAdmin 4 (GUI tool)
   - ✅ Stack Builder (optional)
   - ✅ Command Line Tools (IMPORTANT!)
   - Click "Next"

6. **Data Directory**
   - Default: `C:\Program Files\PostgreSQL\16\data`
   - ✅ Keep the default - Click "Next"

7. **Password Setup - CRITICAL!**
   ```
   ⚠️ IMPORTANT: Set a password you'll remember!
   
   Enter password: _______________
   Retype password: _______________
   
   📝 Write this password down!
   
   Suggested password: postgres123 (for learning)
   ```
   - This is the password for the `postgres` superuser
   - You'll need this password every time you connect
   - Click "Next"

8. **Port**
   - Default: `5432`
   - ✅ Keep the default - Click "Next"

9. **Advanced Options - Locale**
   - Default: `[Default locale]`
   - ✅ Keep the default - Click "Next"

10. **Pre-Installation Summary**
    - Review your choices
    - Click "Next"

11. **Installation Progress**
    - Wait 5-10 minutes for installation
    - ☕ Grab a coffee!

12. **Completing the Setup**
    - ❌ Uncheck "Launch Stack Builder at exit" (not needed)
    - Click "Finish"

### Step 3: Verify Installation

1. **Open Git Bash** (you're already familiar with this!)

2. **Test psql command**:
   ```bash
   psql --version
   ```

3. **If you see something like**:
   ```
   psql (PostgreSQL) 16.x
   ```
   ✅ SUCCESS! PostgreSQL is installed!

4. **If you get "command not found"**:
   
   **Option A: Add to PATH temporarily**
   ```bash
   export PATH="/c/Program Files/PostgreSQL/16/bin:$PATH"
   psql --version
   ```
   
   **Option B: Add to PATH permanently**
   ```bash
   echo 'export PATH="/c/Program Files/PostgreSQL/16/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   psql --version
   ```

---

## Part 2: Create Databases (5 minutes)

### Step 1: Connect to PostgreSQL

1. **In Git Bash, run**:
   ```bash
   psql -U postgres
   ```

2. **Enter the password** you set during installation
   - You won't see characters as you type (normal behavior)
   - Press Enter

3. **You should see**:
   ```
   postgres=#
   ```
   ✅ You're connected!

### Step 2: Create Three Databases

**Copy and paste these commands one at a time:**

```sql
CREATE DATABASE playstore_db;
```
*You should see: `CREATE DATABASE`*

```sql
CREATE DATABASE products_db;
```
*You should see: `CREATE DATABASE`*

```sql
CREATE DATABASE vehicles_db;
```
*You should see: `CREATE DATABASE`*

### Step 3: Verify Databases Created

```sql
\l
```
*You should see your three new databases listed*

### Step 4: Exit psql

```sql
\q
```

---

## Part 3: Set Up Database Schemas (10 minutes)

### Step 1: Set Up PlayStore Database

1. **Navigate to your repository**:
   ```bash
   cd ~/Documents/GitHub/SQL-Zoo/SQL-Zoo
   ```

2. **Connect to playstore_db**:
   ```bash
   psql -U postgres -d playstore_db
   ```
   *Enter your password*

3. **Create the analytics table** - Copy and paste this entire block:
   ```sql
   CREATE TABLE analytics (
     id INTEGER PRIMARY KEY,
     app_name VARCHAR(255),
     category VARCHAR(100),
     rating DECIMAL(2,1),
     reviews INTEGER,
     size VARCHAR(20),
     min_installs INTEGER,
     price DECIMAL(10,2),
     content_rating VARCHAR(50),
     genres TEXT[],
     last_updated DATE,
     current_version VARCHAR(50),
     android_version VARCHAR(50)
   );
   ```
   *You should see: `CREATE TABLE`*

4. **Exit**:
   ```sql
   \q
   ```

### Step 2: Set Up Products Database

1. **Connect to products_db**:
   ```bash
   psql -U postgres -d products_db
   ```

2. **Create the products table**:
   ```sql
   CREATE TABLE products (
     id SERIAL PRIMARY KEY,
     name VARCHAR(100),
     price DECIMAL(10,2),
     can_be_returned BOOLEAN
   );
   ```
   *You should see: `CREATE TABLE`*

3. **Exit**:
   ```sql
   \q
   ```

### Step 3: Set Up Vehicles Database

1. **Connect to vehicles_db**:
   ```bash
   psql -U postgres -d vehicles_db
   ```

2. **Create owners table**:
   ```sql
   CREATE TABLE owners (
     id SERIAL PRIMARY KEY,
     first_name VARCHAR(50),
     last_name VARCHAR(50)
   );
   ```

3. **Create vehicles table**:
   ```sql
   CREATE TABLE vehicles (
     id SERIAL PRIMARY KEY,
     make VARCHAR(50),
     model VARCHAR(50),
     year INTEGER,
     price DECIMAL(10,2),
     owner_id INTEGER REFERENCES owners(id)
   );
   ```

4. **Load sample data for owners**:
   ```sql
   INSERT INTO owners (first_name, last_name) VALUES
   ('Alice', 'Anderson'),
   ('Bob', 'Brown'),
   ('Charlie', 'Chen'),
   ('Diana', 'Davis');
   ```

5. **Load sample data for vehicles**:
   ```sql
   INSERT INTO vehicles (make, model, year, price, owner_id) VALUES
   ('Toyota', 'Camry', 2020, 24000, 1),
   ('Honda', 'Accord', 2019, 23000, 1),
   ('Ford', 'F-150', 2021, 35000, 2),
   ('Tesla', 'Model 3', 2022, 45000, 3),
   ('BMW', 'X5', 2020, 55000, 3);
   ```

6. **Verify data loaded**:
   ```sql
   SELECT COUNT(*) FROM owners;
   SELECT COUNT(*) FROM vehicles;
   ```
   *Should see 4 and 5*

7. **Exit**:
   ```sql
   \q
   ```

---

## Part 4: Load Sample Data (10 minutes)

**YOU NEED TO HAVE THE FILES FROM MY PREVIOUS RESPONSE!**

Make sure you have:
- `load_playstore_data.sql` (in your SQL-Zoo folder)

### Step 1: Get the Data Loading Script

If you don't have it, I created it for you. Make sure `load_playstore_data.sql` is in your repository folder:
```bash
cd ~/Documents/GitHub/SQL-Zoo/SQL-Zoo
ls -la load_playstore_data.sql
```

### Step 2: Load the Data

```bash
psql -U postgres -d playstore_db -f load_playstore_data.sql
```

**This will take 1-2 minutes** and load hundreds of sample apps.

You should see:
```
INSERT 0 1
INSERT 0 1
...
Total apps loaded: [some number]
```

---

## Part 5: Test Everything Works! (5 minutes)

### Quick Test

1. **Navigate to repository**:
   ```bash
   cd ~/Documents/GitHub/SQL-Zoo/SQL-Zoo
   ```

2. **Test a simple query**:
   ```bash
   psql -U postgres -d playstore_db -c "SELECT COUNT(*) FROM analytics;"
   ```
   
   You should see a number > 0

3. **Test running a full file**:
   ```bash
   psql -U postgres -d playstore_db -c "SELECT * FROM analytics WHERE id = 1880;"
   ```
   
   You should see information about Google Drive

### Run the Test Script (Optional but Recommended)

If you saved the test script I created:

```bash
chmod +x test_sql_zoo.sh
./test_sql_zoo.sh
```

This will run comprehensive tests and tell you if everything is working!

---

## Part 6: Start Learning! 🎓

### Your First Query

1. **Connect to playstore database**:
   ```bash
   psql -U postgres -d playstore_db
   ```

2. **Try a simple query**:
   ```sql
   SELECT * FROM analytics LIMIT 5;
   ```

3. **Try a query from the files**:
   ```sql
   SELECT * FROM analytics WHERE id = 1880;
   ```

4. **Exit when done**:
   ```sql
   \q
   ```

### Running Full Query Files

```bash
# Run all playstore queries
psql -U postgres -d playstore_db -f playstore.sql

# Run products queries
psql -U postgres -d products_db -f products.sql

# Run vehicles queries
psql -U postgres -d vehicles_db -f queries.sql

# Run advanced queries
psql -U postgres -d playstore_db -f study.sql
```

---

## 🎯 You're Done!

### What You Have Now:

✅ PostgreSQL installed and working
✅ Three databases created and configured
✅ Sample data loaded (hundreds of records)
✅ Ready to practice SQL queries!

### What's Next:

1. **Start with products.sql** - Easiest (CRUD operations)
2. **Move to playstore.sql** - Basic queries
3. **Try queries.sql** - JOINs
4. **Challenge yourself with study.sql** - Advanced features

### Quick Reference

**Connect to databases:**
```bash
psql -U postgres -d playstore_db   # Play Store data
psql -U postgres -d products_db    # Products data
psql -U postgres -d vehicles_db    # Owners/Vehicles data
```

**Run query files:**
```bash
psql -U postgres -d [database_name] -f [file.sql]
```

**Inside psql:**
```sql
\l          -- List databases
\dt         -- List tables
\d table    -- Describe table
\q          -- Quit
```

---

## 🆘 Troubleshooting

### "command not found: psql"
**Fix**: Add PostgreSQL to PATH (see Step 3 above)

### "password authentication failed"
**Fix**: Use the correct password you set during installation

### "database does not exist"
**Fix**: Make sure you created the databases (Part 2)

### "relation does not exist"
**Fix**: Make sure you created the tables (Part 3)

### Queries return no data
**Fix**: Load sample data (Part 4)

---

## 📚 Additional Help

- **Main Setup Guide**: `SQL_Zoo_Complete_Setup_Guide.md`
- **Quick Reference**: `SQL_Quick_Reference.md`
- **Test Script**: `test_sql_zoo.sh`

---

**Happy Learning! 🚀**

If you get stuck, check the error message carefully - it usually tells you exactly what's wrong!
