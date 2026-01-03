# 🛠️ Useful Commands - PNAD COVID-19 Project

> **Quick guide** with AWS CLI, PySpark, Athena, Power BI and troubleshooting commands

---

## 📦 Index

1. [AWS CLI - S3](#aws-cli---s3)
2. [AWS Glue - PySpark](#aws-glue---pyspark)
3. [AWS Athena - SQL](#aws-athena---sql)
4. [Power BI - Connectors](#power-bi---connectors)
5. [Jupyter Notebook (Local)](#jupyter-notebook-local)
6. [Git and Versioning](#git-and-versioning)
7. [Data Validation](#data-validation)
8. [Troubleshooting](#troubleshooting)

---

## 🪣 AWS CLI - S3

### Configure AWS Credentials
```bash
# Configure default profile
aws configure

# Configure named profile
aws configure --profile pnad-covid

# Verify configuration
aws sts get-caller-identity --profile pnad-covid
```

### Upload Data to S3
```bash
# Create bucket (once)
aws s3 mb s3://your-pnad-bucket --region sa-east-1

# Upload single file
aws s3 cp data/PNAD_COVID_092020.csv \
  s3://your-pnad-bucket/data-input/microdados/

# Upload entire directory (sync)
aws s3 sync data/ s3://your-pnad-bucket/data-input/microdados/ \
  --exclude "*" \
  --include "*.csv" \
  --storage-class STANDARD_IA

# Check file sizes
aws s3 ls s3://your-pnad-bucket/data-input/microdados/ \
  --recursive --human-readable --summarize
```

### Download Processed Results
```bash
# Download Gold table for local analysis
aws s3 sync s3://your-pnad-bucket/data-output/pnad_covid_gold/ \
  ./local-output/gold/ \
  --exclude "*" \
  --include "*.parquet"

# Check partitioning
aws s3 ls s3://your-pnad-bucket/data-output/pnad_covid_gold/ --recursive
```

### Cost Management
```bash
# Calculate total bucket size
aws s3 ls s3://your-pnad-bucket --recursive \
  | awk '{sum+=$3} END {print "Total: " sum/1024/1024/1024 " GB"}'

# Delete temporary processed data (CAREFUL!)
aws s3 rm s3://your-pnad-bucket/temp/ --recursive

# Move to Glacier (cheap archiving)
aws s3 cp s3://your-pnad-bucket/data-input/ \
  s3://your-pnad-bucket/archive/ \
  --recursive \
  --storage-class GLACIER
```

---

## ⚙️ AWS Glue - PySpark

### Create Glue Job via CLI
```bash
# Create Glue job to execute notebook
aws glue create-job \
  --name pnad-covid-etl \
  --role AWSGlueServiceRole-PnadCovid \
  --command '{
    "Name": "glueetl",
    "ScriptLocation": "s3://your-pnad-bucket/scripts/PNAD_Covid.py",
    "PythonVersion": "3"
  }' \
  --default-arguments '{
    "--job-language": "python",
    "--job-bookmark-option": "job-bookmark-disable",
    "--enable-metrics": "true",
    "--enable-continuous-cloudwatch-log": "true",
    "--TempDir": "s3://your-pnad-bucket/temp/"
  }' \
  --max-retries 1 \
  --timeout 60 \
  --glue-version "4.0" \
  --number-of-workers 5 \
  --worker-type "G.1X"

# Execute job
aws glue start-job-run --job-name pnad-covid-etl

# Monitor execution
aws glue get-job-run --job-name pnad-covid-etl --run-id jr_xxxxx
```

### PySpark - Data Reading
```python
from pyspark.sql import SparkSession
from pyspark.sql import functions as F

# Initialize Spark Session (Glue does this automatically)
spark = SparkSession.builder \
    .appName("PNAD-COVID-Analysis") \
    .getOrCreate()

# Read CSV from S3
df_september = spark.read \
    .option("header", "false") \
    .option("inferSchema", "false") \
    .csv("s3://your-pnad-bucket/data-input/microdados/PNAD_COVID_092020.csv")

# Read Parquet (much faster)
df_gold = spark.read.parquet("s3://your-pnad-bucket/data-output/pnad_covid_gold/")

# Read multiple files
df_all = spark.read.csv("s3://your-pnad-bucket/data-input/microdados/*.csv")
```

### PySpark - Common Transformations
```python
# Add unique ID column
from pyspark.sql.window import Window

df_with_id = df.withColumn(
    "id",
    F.row_number().over(Window.orderBy(F.lit(1)))
)

# Translate codes using mapping
mapping = {"1": "Positive", "2": "Negative", "9": "Ignored"}
mapping_expr = F.create_map([F.lit(x) for x in chain(*mapping.items())])

df_translated = df.withColumn(
    "qual_o_resultado",
    mapping_expr[F.col("B009B")]
)

# Bulk column renaming
rename_map = {
    "B009B": "qual_o_resultado",
    "A003": "sexo",
    "A002": "idade_do_morador"
}

for old_name, new_name in rename_map.items():
    df = df.withColumnRenamed(old_name, new_name)

# Filter data
df_september = df.filter(F.col("mes_da_pesquisa") == 9)

# Group and count
df.groupBy("sexo", "mes_da_pesquisa") \
  .agg(F.count("*").alias("total")) \
  .show()
```

### PySpark - Data Writing
```python
# Write Parquet with Snappy compression
df_gold.write \
    .format("parquet") \
    .mode("overwrite") \
    .option("compression", "snappy") \
    .option("path", "s3://your-pnad-bucket/data-output/pnad_covid_gold/") \
    .saveAsTable("workspace.tb_pnad_covid_gold")

# Partition by state (optimizes regional queries)
df_gold.write \
    .partitionBy("unidade_da_federacao") \
    .parquet("s3://your-pnad-bucket/data-output/pnad_covid_gold_partitioned/")

# Write CSV (for export)
df_result.coalesce(1) \
    .write \
    .mode("overwrite") \
    .option("header", "true") \
    .csv("s3://your-pnad-bucket/exports/result_q1.csv")
```

### Glue Data Catalog - Crawler
```bash
# Create crawler to discover schema automatically
aws glue create-crawler \
  --name pnad-covid-crawler \
  --role AWSGlueServiceRole \
  --database-name pnad_covid \
  --targets '{
    "S3Targets": [{
      "Path": "s3://your-pnad-bucket/data-output/pnad_covid_gold/"
    }]
  }' \
  --schema-change-policy '{
    "UpdateBehavior": "UPDATE_IN_DATABASE",
    "DeleteBehavior": "LOG"
  }'

# Execute crawler
aws glue start-crawler --name pnad-covid-crawler

# Check status
aws glue get-crawler --name pnad-covid-crawler

# List created tables
aws glue get-tables --database-name pnad_covid
```

---

## 🔍 AWS Athena - SQL

### Create Database and Tables
```sql
-- Create database
CREATE DATABASE IF NOT EXISTS pnad_covid
COMMENT 'PNAD COVID-19 - Analytical Data Lake'
LOCATION 's3://your-pnad-bucket/athena-database/';

-- Use database
USE pnad_covid;

-- Create Gold table (external)
CREATE EXTERNAL TABLE IF NOT EXISTS tb_pnad_covid_gold (
  id BIGINT,
  ano_de_referencia INT,
  mes_da_pesquisa INT,
  unidade_da_federacao STRING,
  sexo STRING,
  idade_do_morador INT,
  cor_ou_raca STRING,
  escolaridade STRING,
  qual_o_resultado STRING,
  qual_o_resultado_2 STRING,
  qual_o_resultado_3 STRING,
  na_semana_passada_teve_perda_de_cheiro_ou_sabor STRING,
  tem_algum_plano_de_saude_medico_seja_particular_de_empresa_ou_de_orgao_publico STRING,
  na_semana_passada_o_a_sr_a_estava_em_trabalho_remoto_home_office_ou_teletrabalho STRING,
  auxilios_emergenciais_relacionados_ao_coronavirus STRING
  -- ... (add all 148 columns or the ones you'll use)
)
STORED AS PARQUET
LOCATION 's3://your-pnad-bucket/data-output/pnad_covid_gold/'
TBLPROPERTIES (
  'parquet.compression'='SNAPPY',
  'has_encrypted_data'='false'
);
```

### Exploration Queries
```sql
-- Count total records
SELECT COUNT(*) AS total_records
FROM tb_pnad_covid_gold;

-- Check distribution by month
SELECT 
    mes_da_pesquisa,
    COUNT(*) AS total,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percentage
FROM tb_pnad_covid_gold
GROUP BY mes_da_pesquisa
ORDER BY mes_da_pesquisa;

-- Top 10 states with most records
SELECT 
    unidade_da_federacao,
    COUNT(*) AS total
FROM tb_pnad_covid_gold
GROUP BY unidade_da_federacao
ORDER BY total DESC
LIMIT 10;

-- Age descriptive statistics
SELECT 
    MIN(idade_do_morador) AS min_age,
    MAX(idade_do_morador) AS max_age,
    ROUND(AVG(idade_do_morador), 1) AS avg_age,
    APPROX_PERCENTILE(idade_do_morador, 0.5) AS median
FROM tb_pnad_covid_gold
WHERE idade_do_morador < 120; -- Exclude invalid values
```

### Execute Queries via CLI
```bash
# Execute query and save result
aws athena start-query-execution \
  --query-string "SELECT sexo, COUNT(*) FROM tb_pnad_covid_gold GROUP BY sexo;" \
  --result-configuration "OutputLocation=s3://your-pnad-bucket/athena-results/" \
  --query-execution-context "Database=pnad_covid"

# Check execution status
aws athena get-query-execution --query-execution-id <EXECUTION_ID>

# Download result
aws s3 cp s3://your-pnad-bucket/athena-results/<EXECUTION_ID>.csv ./results/
```

### Performance Optimizations
```sql
-- Partition table by state (create new table)
CREATE TABLE tb_pnad_covid_gold_partitioned
WITH (
  format = 'PARQUET',
  parquet_compression = 'SNAPPY',
  partitioned_by = ARRAY['unidade_da_federacao'],
  external_location = 's3://your-pnad-bucket/data-output/gold_partitioned/'
)
AS
SELECT * FROM tb_pnad_covid_gold;

-- After partitioning, regional queries become much faster:
SELECT * 
FROM tb_pnad_covid_gold_partitioned
WHERE unidade_da_federacao = 'São Paulo'; -- Scan only SP partition
```

---

## 📊 Power BI - Connectors

### Install Athena Driver
```powershell
# Download ODBC driver for Windows
# https://docs.aws.amazon.com/athena/latest/ug/connect-with-odbc.html

# Or via PowerShell (example)
Invoke-WebRequest -Uri "https://s3.amazonaws.com/athena-downloads/drivers/ODBC/SimbaAthenaODBC_1.1.17.1000/Windows/Simba+Athena+1.1+64-bit.msi" `
  -OutFile "AthenaODBC.msi"

# Install silently
msiexec /i AthenaODBC.msi /quiet /norestart
```

### Connect Power BI to Athena
**Step by Step**:
1. Open Power BI Desktop
2. **Get Data** → **More...** → **Amazon Athena**
3. Configure:
   - **Server**: `athena.sa-east-1.amazonaws.com`
   - **Database**: `pnad_covid`
   - **S3 Output Location**: `s3://your-pnad-bucket/athena-results/`
   - **Authentication**: IAM Credentials
   - **Access Key ID**: `<YOUR_ACCESS_KEY>`
   - **Secret Access Key**: `<YOUR_SECRET_KEY>`
4. **OK** → Select table `tb_pnad_covid_gold`
5. **Load** or **Transform Data**

### DAX - Calculated Metrics in Power BI
```dax
// Create calculated column for age group
Age Group = 
SWITCH(
    TRUE(),
    'tb_pnad_covid_gold'[idade_do_morador] < 18, "0-17",
    'tb_pnad_covid_gold'[idade_do_morador] < 30, "18-29",
    'tb_pnad_covid_gold'[idade_do_morador] < 50, "30-49",
    'tb_pnad_covid_gold'[idade_do_morador] < 65, "50-64",
    "65+"
)

// Measure: Positivity Rate
Positivity Rate (%) = 
VAR Positives = 
    CALCULATE(
        COUNTROWS('tb_pnad_covid_gold'),
        OR(
            'tb_pnad_covid_gold'[qual_o_resultado] = "Positivo",
            OR(
                'tb_pnad_covid_gold'[qual_o_resultado_2] = "Positivo",
                'tb_pnad_covid_gold'[qual_o_resultado_3] = "Positivo"
            )
        )
    )
VAR Tested = 
    CALCULATE(
        COUNTROWS('tb_pnad_covid_gold'),
        OR(
            'tb_pnad_covid_gold'[qual_o_resultado] IN {"Positivo", "Negativo"},
            OR(
                'tb_pnad_covid_gold'[qual_o_resultado_2] IN {"Positivo", "Negativo"},
                'tb_pnad_covid_gold'[qual_o_resultado_3] IN {"Positivo", "Negativo"}
            )
        )
    )
RETURN
    DIVIDE(Positives, Tested, 0) * 100

// Measure: Total Cases
Total Cases = COUNTROWS('tb_pnad_covid_gold')
```

---

## 🐙 Git and Versioning

### Initialize Repository
```bash
# Initialize Git
cd TC3/
git init

# Add files
git add README.md docs/ sql/ athena/
git commit -m "Initial commit: PNAD COVID-19 project"

# Connect to GitHub
git remote add origin https://github.com/your-username/pnad-covid-analysis.git
git branch -M main
git push -u origin main
```

### .gitignore (already created)
```gitignore
# Raw data (too large for Git)
data/*.csv
*.parquet

# Notebooks with output
*.ipynb_checkpoints
**/*.ipynb

# AWS credentials
.env
credentials.txt
```

### Best Practices
```bash
# Atomic and descriptive commits
git commit -m "feat: add Q5 query - most frequent symptoms"
git commit -m "docs: update data dictionary with real column names"
git commit -m "fix: correct positivity rate calculation in Q1"

# Branches for features
git checkout -b feature/power-bi-dashboard
# ... work ...
git commit -m "feat: create inequalities dashboard"
git checkout main
git merge feature/power-bi-dashboard
```

---

## ✅ Data Validation

### Check Completeness (% null values)
```sql
-- Athena
SELECT 
    COUNT(*) AS total_records,
    SUM(CASE WHEN sexo IS NULL THEN 1 ELSE 0 END) AS sexo_nulls,
    ROUND(100.0 * SUM(CASE WHEN sexo IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS sexo_pct_nulls,
    SUM(CASE WHEN idade_do_morador IS NULL THEN 1 ELSE 0 END) AS age_nulls,
    ROUND(100.0 * SUM(CASE WHEN idade_do_morador IS NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS age_pct_nulls
FROM tb_pnad_covid_gold;
```

### Check Consistency (invalid values)
```sql
-- Identify suspicious ages
SELECT 
    idade_do_morador,
    COUNT(*) AS total
FROM tb_pnad_covid_gold
WHERE idade_do_morador > 110 OR idade_do_morador < 0
GROUP BY idade_do_morador
ORDER BY total DESC;

-- Check gender domains
SELECT sexo, COUNT(*) 
FROM tb_pnad_covid_gold 
GROUP BY sexo;
-- Expected: only "Homem", "Mulher" or NULL
```

### PySpark - Quality Checks
```python
# Check duplicates
df_gold.groupBy("id").count().filter("count > 1").show()

# Statistics for numeric columns
df_gold.select("idade_do_morador").describe().show()

# Count unique values
df_gold.select("sexo").distinct().show()
```

---

## 🔧 Troubleshooting

### Error: "Access Denied" on S3
```bash
# Check bucket permissions
aws s3api get-bucket-policy --bucket your-pnad-bucket

# Add read permission for Glue
aws s3api put-bucket-policy --bucket your-pnad-bucket --policy '{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "glue.amazonaws.com"},
    "Action": ["s3:GetObject", "s3:PutObject"],
    "Resource": "arn:aws:s3:::your-pnad-bucket/*"
  }]
}'
```

### Error: Glue Job Timeout
```bash
# Increase timeout and workers
aws glue update-job \
  --job-name pnad-covid-etl \
  --job-update '{
    "Timeout": 120,
    "NumberOfWorkers": 10,
    "WorkerType": "G.2X"
  }'
```

### Error: "HIVE_PARTITION_SCHEMA_MISMATCH" in Athena
```sql
-- Repair partitions
MSCK REPAIR TABLE tb_pnad_covid_gold;

-- Or recreate table
DROP TABLE tb_pnad_covid_gold;
-- CREATE TABLE again...
```

### Error: Very slow queries in Athena
```sql
-- Check scanned size
-- After executing query, check console: "Data scanned"

-- If > 100 MB, consider:
-- 1. Partition table by state or month
-- 2. Use LIMIT in test queries
-- 3. Filter columns (specific SELECT, not SELECT *)

-- Optimized example:
SELECT mes_da_pesquisa, sexo, COUNT(*) 
FROM tb_pnad_covid_gold 
WHERE unidade_da_federacao = 'São Paulo' -- Filter reduces scan
  AND mes_da_pesquisa IN (9, 10, 11)
GROUP BY 1, 2;
```

---

## 📚 Official References

- **AWS Glue Developer Guide**: https://docs.aws.amazon.com/glue/
- **PySpark API Docs**: https://spark.apache.org/docs/latest/api/python/
- **AWS Athena User Guide**: https://docs.aws.amazon.com/athena/
- **Power BI + Athena**: https://docs.aws.amazon.com/athena/latest/ug/connect-with-powerbi.html
- **AWS CLI Reference**: https://awscli.amazonaws.com/v2/documentation/api/latest/index.html

---

<div align="center">

**💡 Tip**: Save this file as a bookmark for quick reference!  
**Last update**: January 2026

</div>
