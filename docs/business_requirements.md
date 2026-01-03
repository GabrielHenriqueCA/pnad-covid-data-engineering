# 📋 Business Requirements - PNAD COVID-19

> **Client**: Large Hospital (fictional)  
> **Analysis Period**: September, October and November 2020  
> **Data Source**: PNAD COVID-19 (IBGE)  
> **Objective**: Provide intelligence for strategic decision-making during the pandemic

---

## 🏥 Business Problem

### Context
A large hospital needs to understand Brazilian population behavior during the COVID-19 pandemic to plan its operations and resources more efficiently. The institution faces the following challenges:

- **Bed Allocation**: Uncertainty about future ICU bed demand
- **Testing Management**: Doubts about which symptoms to prioritize for testing
- **Human Resources Planning**: Need to predict impact of remote work on staff health
- **Equity in Care**: Concern about inequalities in access to tests and treatment

### Proposed Solution
Develop an **analytical Data Lake** processing PNAD COVID-19 microdata through an **ELT pipeline** (AWS Glue + PySpark), providing **clean and structured data** for ad-hoc analysis in **AWS Athena** and dashboards in **Power BI**.

---

## 🎯 Strategic Objectives

### 1. Clinical Characterization
Identify the most frequent and specific COVID-19 symptoms to optimize triage protocols.

### 2. Behavioral Analysis
Understand how the population reacted to the pandemic (isolation, remote work, seeking care).

### 3. Socioeconomic Profile
Assess the economic impact of the pandemic and the effectiveness of public policies (emergency aid).

### 4. Structural Inequalities
Evidence differences in access to tests and treatment by race, education and income.

---

## 📊 15 Key Business Questions

Based on file **`athena/business_queries.sql`** (real queries executed in Athena):

### 🔬 Block 1: Descriptive Epidemiology

#### **Q1: Difference in positivity rate between men and women?**
**Motivation**: Identify if there is differentiated vulnerability by gender.

**Query**: `athena/business_queries.sql` - Question 1

**Metrics**:
- Positivity rate by gender (%)
- Total positives by gender
- Total tested by gender

**Expected Insight**: Do men or women have a higher positivity rate? This may indicate differences in occupational exposure or risk behavior.

---

#### **Q2: Which age group has the highest positive rate?**
**Motivation**: Prioritize protection for most vulnerable age groups.

**Query**: `athena/business_queries.sql` - Question 2

**Age Groups**:
- 0-17 years (children and adolescents)
- 18-29 years (young adults)
- 30-49 years (adults)
- 50-64 years (middle-aged)
- 65+ years (elderly)

**Metrics**:
- Positivity rate by age group
- Case distribution by age

**Expected Insight**: Young adults may have greater exposure (on-site work), while elderly have greater severity.

---

#### **Q13: Regional difference (state) in infection rate?**
**Motivation**: Map geographic "hot spots" to allocate resources.

**Query**: `athena/business_queries.sql` - Question 13

**Metrics**:
- Positivity rate by state
- Ranking of most affected states

**Expected Insight**: States with higher population density or lower adherence to isolation tend to have higher rates.

---

### 🔍 Block 2: Social Inequalities

#### **Q3: Racial inequality in testing and positivity?**
**Motivation**: Evidence structural racism in health access.

**Query**: `athena/business_queries.sql` - Question 3

**Variables**:
- `cor_ou_raca`: `"Branca"`, `"Preta"`, `"Parda"`, `"Amarela"`, `"Indígena"`

**Metrics**:
- Test access rate by race
- Positivity rate by race
- Proportion of untested cases by race

**Expected Insight**: Black and brown population tends to have lower access to tests, but higher positivity rate (greater exposure + lower access to protection).

---

#### **Q4: Does education influence the chance of testing positive?**
**Motivation**: Assess if educational level is associated with preventive behaviors.

**Query**: `athena/business_queries.sql` - Question 4

**Variables**:
- `escolaridade`: `"Sem instrução"`, `"Fundamental"`, `"Médio"`, `"Superior"`

**Metrics**:
- Positivity rate by education
- Isolation rate by education

**Expected Insight**: Lower education may be associated with greater exposure (manual/on-site work) and lower ability to isolate.

---

#### **Q11: Does health plan influence testing?**
**Motivation**: Quantify inequality in access between public and private systems.

**Query**: `athena/business_queries.sql` - Question 11

**Variable**: `tem_algum_plano_de_saude_medico_seja_particular_de_empresa_ou_de_orgao_publico`

**Metrics**:
- % tested with health plan vs. without plan
- Positivity rate: private plan vs. public system

**Expected Insight**: People with health plans have higher testing rate (easier access), but not necessarily higher positivity.

---

### 🩺 Block 3: Symptoms and Triage

#### **Q5: Which symptoms are most frequent in positive cases?**
**Motivation**: Create triage protocols based on most common symptoms.

**Query**: `athena/business_queries.sql` - Question 5

**Evaluated Symptoms** (13 total):
- Fever
- Cough
- Sore throat
- Difficulty breathing
- **Loss of smell/taste** ⭐
- Fatigue
- Diarrhea
- etc.

**Metric**:
- Frequency of each symptom among positives (%)

**Expected Insight**: Ranking of most prevalent symptoms in infected individuals.

---

#### **Q6: Is loss of smell/taste the best COVID-19 predictor?**
**Motivation**: Validate if this specific symptom justifies priority testing.

**Query**: `athena/business_queries.sql` - Question 6

**Key Variable**: `na_semana_passada_teve_perda_de_cheiro_ou_sabor`

**Metric**:
- **Positive Predictive Value (PPV)**: % of people with loss of smell/taste who tested positive

**Expected Insight**: PPV above 70% would indicate high specificity of the symptom.

---

#### **Q7: Proportion of asymptomatic among infected?**
**Motivation**: Plan preventive testing even without symptoms.

**Query**: `athena/business_queries.sql` - Question 7

**Asymptomatic Definition**:
```sql
-- None of the 13 symptoms = "Yes" AND tested positive
```

**Metric**:
- % of positives without symptoms

**Expected Insight**: 20-40% of positives may be asymptomatic, reinforcing importance of mass testing.

---

### 🏢 Block 4: Work and Social Distancing

#### **Q8 and Q14: Do remote workers have lower infection rate?**
**Motivation**: Evaluate effectiveness of home office as protective measure.

**Query**: `athena/business_queries.sql` - Questions 8 and 14 (duplicates)

**Key Variable**: `na_semana_passada_o_a_sr_a_estava_em_trabalho_remoto_home_office_ou_teletrabalho`

**Comparison Groups**:
- Remote work
- On-site work
- Not working

**Metric**:
- Positivity rate: remote vs. on-site

**Expected Insight**: Remote work should show ~50-70% reduction in infection rate.

---

#### **Q15: Is receiving emergency aid associated with higher infection?**
**Motivation**: Correlate social vulnerability with infection risk.

**Query**: `athena/business_queries.sql` - Question 15

**Variable**: `auxilios_emergenciais_relacionados_ao_coronavirus`

**Hypothesis**:
- Those receiving aid tend to have:
  - Lower income
  - Informal/on-site work
  - Precarious housing (higher density)
  - **Therefore, greater exposure**

**Metric**:
- Positivity rate: receives aid vs. doesn't receive

**Expected Insight**: Aid recipients tend to have positivity rate ~30-50% higher (vulnerability proxy).

---

### 🏥 Block 5: Health System

#### **Q9: Difference between capitals and interior?**
**Motivation**: Plan resource distribution between capital and interior.

**Query**: `athena/business_queries.sql` - Question 9

**Variable**: `capital` (`"Capital"` vs. `"Resto da RM"` vs. `null`)

**Metrics**:
- Positivity rate: capital vs. interior
- Testing rate: capital vs. interior

**Expected Insight**: Capitals tend to have higher testing (infrastructure) but also higher transmission (density).

---

#### **Q10: Which test type had highest positive rate?**
**Motivation**: Evaluate relative sensitivity of different available tests.

**Query**: `athena/business_queries.sql` - Question 10

**Test Types**:
1. **SWAB (RT-PCR)**: `qual_o_resultado` - gold standard
2. **Rapid Test (finger)**: `qual_o_resultado_2` - antibodies
3. **Serology (vein)**: `qual_o_resultado_3` - antibodies

**Metric**:
- Positivity rate by test type

**Expected Insight**: RT-PCR should have higher rate (greater sensitivity), rapid tests may have false negatives.

---

#### **Q12: Did those seeking care have higher positivity rate?**
**Motivation**: Evaluate if seeking care is a good severity indicator.

**Query**: `athena/business_queries.sql` - Question 12

**Variable**: `por_causa_disso_foi_a_algum_estabelecimento_de_saude`

**Metric**:
- Positivity rate: sought care vs. didn't seek

**Expected Insight**: Those seeking care have higher probability of positive test (more severe/evident symptoms).

---

## 📈 Requested Dashboards (Power BI)

### 1. **Executive Dashboard - Overview**
- Card: Total records analyzed (~1.1M)
- Card: Overall positivity rate
- Line chart: Temporal evolution (sep/oct/nov)
- Map: Positivity rate by state

### 2. **Inequalities Dashboard**
- Bar chart: Testing rate by race
- Bar chart: Positivity rate by education
- Scatter plot: Income vs. positivity rate
- Table: Health plan comparison (public vs. private)

### 3. **Clinical Dashboard**
- Horizontal bar chart: Symptom frequency
- Matrix: Symptom x Positivity rate (heatmap)
- Card: % asymptomatic
- Filter: Age group

### 4. **Economic Dashboard**
- Bar chart: Positivity rate by work type
- Line chart: Emergency aid impact
- Table: Remote vs. on-site work
- Card: % who lost job

---

## 🎯 Use Cases

### Use Case 1: ICU Bed Planning
**Actor**: Medical Director  
**Objective**: Predict bed demand for next quarter

**Flow**:
1. Analyze case growth rate by state
2. Identify age groups with highest hospitalization rate
3. Cross with comorbidity data
4. Project future demand based on trend

**Queries Used**: Q2 (age group), Q13 (regional)

---

### Use Case 2: Triage Protocol Optimization
**Actor**: Emergency Nursing Team  
**Objective**: Reduce triage time without losing sensitivity

**Flow**:
1. Identify top 3 most specific symptoms (Q5, Q6)
2. Create decision tree for priority testing
3. Implement simplified questionnaire
4. Monitor false negative rate

**Queries Used**: Q5, Q6, Q7

---

### Use Case 3: Testing Campaign in Peripheries
**Actor**: Social Responsibility Advisory  
**Objective**: Bring free testing to vulnerable populations

**Flow**:
1. Identify neighborhoods with lowest testing rate (Q3, Q11)
2. Cross with emergency aid data (Q15)
3. Plan mobile testing units
4. Track testing increase post-campaign

**Queries Used**: Q3, Q11, Q15

---

### Use Case 4: Home Office Policy for Employees
**Actor**: Hospital HR  
**Objective**: Define which sectors can work remotely

**Flow**:
1. Analyze infection reduction in remote workers (Q8)
2. Map eligible administrative functions
3. Implement hybrid work
4. Monitor productivity and mental health

**Queries Used**: Q8, Q14

---

## 📊 Technical Requirements

### Performance
- ⚡ Queries must return in **< 10 seconds**
- 📊 Dashboards must load in **< 5 seconds**
- 💾 Data must be available for **ad-hoc queries** 24/7

### Data Quality
- ✅ **Completeness**: < 5% null values in key columns
- ✅ **Consistency**: Domain validation (e.g., `sexo` can only be `"Homem"` or `"Mulher"`)
- ✅ **Accuracy**: Correct code translation using IBGE dictionary

### Governance
- 🔐 **Privacy**: Anonymized data (no CPF, address)
- 📝 **Audit**: Logs of all transformations (Glue Job Logs)
- 📚 **Documentation**: Complete data dictionary

---

## 🚀 Delivery Timeline (Retrospective)

| Phase | Activities | Duration | Status |
|------|-----------|---------|--------|
| **1. Ingestion** | Manual CSV upload → S3 | 1 day | ✅ Completed |
| **2. Processing** | Glue Pipeline (Bronze→Silver→Gold) | 3 days | ✅ Completed |
| **3. Cataloging** | Glue Crawler + Data Catalog | 1 day | ✅ Completed |
| **4. Analysis** | 15 SQL queries in Athena | 2 days | ✅ Completed |
| **5. Visualization** | Power BI Dashboards | 3 days | ✅ Completed |
| **6. Documentation** | README + Dictionary + Walkthrough | 2 days | ✅ Completed |

**Total**: ~12 business days

---

## 📝 Definition of Done (DoD)

A business question is considered **answered** when:

- [x] SQL query was written and validated in Athena
- [x] Result was exported to CSV (optional)
- [x] Insight was documented in SQL comment
- [x] Metric was added to dashboard (if applicable)
- [x] Execution time < 10 seconds

---

## 🎓 Learnings and Next Steps

### Lessons Learned
1. **Data Quality**: ~15% of records have invalid birth data (`9999`) - requires special treatment
2. **Performance**: Parquet + Snappy reduced query cost by **80%** vs. CSV
3. **Complexity**: Multiple test results (`qual_o_resultado`, `_2`, `_3`) require careful `OR` logic

### Future Improvements
- 🔄 **Automation**: Create pipeline with AWS Step Functions
- 📊 **More Periods**: Include all 9 months of PNAD COVID (May/2020 to Apr/2021)
- 🤖 **ML**: Predictive model of positivity based on symptoms
- 🔗 **Enrichment**: Cross with SUS data (DATASUS)

---

## 📚 References

- [PNAD COVID-19 - Official IBGE Page](https://covid19.ibge.gov.br/pnad-covid/)
- [Variable Dictionary (PDF)](https://ftp.ibge.gov.br/Trabalho_e_Rendimento/Pesquisa_Nacional_por_Amostra_de_Domicilios_PNAD_COVID19/Microdados/Documentacao/PNAD_COVID19_dicionario_de_variaveis.xls)
- [AWS Glue - Best Practices](https://docs.aws.amazon.com/glue/latest/dg/best-practices.html)
- [Athena - Performance Tuning](https://docs.aws.amazon.com/athena/latest/ug/performance-tuning.html)

---

<div align="center">

**Developed as part of Tech Challenge - Phase 3 (FIAP)**

</div>
