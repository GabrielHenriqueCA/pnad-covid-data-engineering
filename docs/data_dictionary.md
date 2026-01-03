# 📖 Data Dictionary - PNAD COVID-19

> **Source**: IBGE - National Household Sample Survey COVID-19  
> **Period**: September, October and November 2020  
> **Pipeline**: AWS Glue (PySpark) → Bronze → Silver → Gold  
> **Final Table**: `workspace.tb_pnad_covid_gold`

---

## 📊 Layer Overview

| Layer | Total Columns | Description | Format |
|--------|------------------|-----------|---------|
| **Bronze** | 148 | Unified raw data (3 months) | Parquet + Snappy |
| **Silver** | 148 | Translated codes → readable text | Parquet + Snappy |
| **Gold** | 148+ | Optimized analytical table | Parquet + Snappy |

---

## 🔑 Key Columns (Most Used in Analysis)

### 📍 Identification and Location

| Original Column | Gold Layer Name | Type | Description | Example |
|-----------------|-------------------|------|-----------|---------|
| `ID` | `id` | `BIGINT` | Unique record identifier (generated in Glue) | `1`, `2`, `3` |
| `Ano` | `ano_de_referencia` | `INT` | Survey year | `2020` |
| `V1012` | `semana_no_mes` | `INT` | Week of month (1-4) | `1`, `2`, `3`, `4` |
| `V1013` | `mes_da_pesquisa` | `INT` | Survey month | `9` (sep), `10` (oct), `11` (nov) |
| `UF` | `unidade_da_federacao` | `STRING` | Brazilian state | `"Rondônia"`, `"São Paulo"` |
| `CAPITAL` | `capital` | `STRING` | State capital | `"Município de Porto Velho (RO)"` |
| `V1022` | `situacao_do_domicilio` | `STRING` | Urban/Rural | `"Urbana"`, `"Rural"` |
| `V1023` | `tipo_de_area` | `STRING` | Capital, metropolitan area or interior | `"Capital"`, `"Resto da RM"` |

---

### 👤 Demographic Data

| Original Column | Gold Layer Name | Type | Description | Possible Values |
|-----------------|-------------------|------|-----------|-------------------|
| `A001` | `numero_de_ordem` | `INT` | Household member order | `1`, `2`, `3`... |
| `A001A` | `condicao_no_domicilio` | `STRING` | Relationship to household head | `"Pessoa responsável pelo domicílio"`, `"Cônjuge"`, `"Filho(a)"` |
| `A001B1` | `dia_de_nascimento` | `INT` | Day of birth | `1` to `31` |
| `A001B2` | `mes_de_nascimento` | `INT` | Month of birth | `1` to `12` |
| `A001B3` | `ano_de_nascimento` | `INT` | Year of birth | `1920` to `2020` |
| `A002` | `idade_do_morador` | `INT` | Age in complete years | `0` to `120` |
| `A003` | `sexo` | `STRING` | Biological gender | `"Homem"`, `"Mulher"` |
| `A004` | `cor_ou_raca` | `STRING` | Self-declared race/color | `"Branca"`, `"Preta"`, `"Parda"`, `"Amarela"`, `"Indígena"` |
| `A005` | `escolaridade` | `STRING` | Education level | `"Sem instrução"`, `"Fundamental incompleto"`, `"Médio completo"`, `"Superior completo"` |

---

### 🎓 Education (Section A - Continuation)

| Original Column | Gold Layer Name | Type | Description |
|-----------------|-------------------|------|-----------|
| `A006` | `frequenta_escola` | `STRING` | Attends school | `"Sim"`, `"Não"` |
| `A006A` | `a_escola_e_publica_ou_privada` | `STRING` | School type | `"Pública"`, `"Privada"` |
| `A006B` | `voce_esta_tendo_aulas_presenciais` | `STRING` | Teaching modality | `"Sim"`, `"Não"` |
| `A007` | `na_semana_passada_foram_disponibilizadas_atividades_escolares` | `STRING` | Remote activities | `"Sim, e realizou pelo menos parte delas"`, `"Não, porque estava de férias"` |
| `A007A` | `na_semana_passada_em_quantos_dias_dedicou_se_as_atividades` | `STRING` | Days dedicated | `"1 dia"` to `"7 dias"` |
| `A007B` | `na_semana_passada_quanto_tempo_por_dia` | `STRING` | Hours dedicated | `"Menos de 1 hora"`, `"De 1 a menos de 2 horas"`, ... |

---

### 🏥 COVID-19 Symptoms (Section B001-B0013)

> **IMPORTANT**: All questions refer to the **previous week** of the survey.

| Original Column | Gold Layer Name | Type | Description |
|-----------------|-------------------|------|-----------|
| `B0011` | `na_semana_passada_teve_febre` | `STRING` | Fever presence | `"Sim"`, `"Não"` |
| `B0012` | `na_semana_passada_teve_tosse` | `STRING` | Cough presence | `"Sim"`, `"Não"` |
| `B0013` | `na_semana_passada_teve_dor_de_garganta` | `STRING` | Sore throat | `"Sim"`, `"Não"` |
| `B0014` | `na_semana_passada_teve_dificuldade_para_respirar` | `STRING` | Dyspnea | `"Sim"`, `"Não"` |
| `B0015` | `na_semana_passada_teve_dor_de_cabeca` | `STRING` | Headache | `"Sim"`, `"Não"` |
| `B0016` | `na_semana_passada_teve_dor_no_peito` | `STRING` | Chest pain | `"Sim"`, `"Não"` |
| `B0017` | `na_semana_passada_teve_nausea` | `STRING` | Nausea | `"Sim"`, `"Não"` |
| `B0018` | `na_semana_passada_teve_nariz_entupido_ou_escorrendo` | `STRING` | Nasal congestion | `"Sim"`, `"Não"` |
| `B0019` | `na_semana_passada_teve_fadiga` | `STRING` | Extreme tiredness | `"Sim"`, `"Não"` |
| `B00110` | `na_semana_passada_teve_dor_nos_olhos` | `STRING` | Eye pain | `"Sim"`, `"Não"` |
| `B00111` | **`na_semana_passada_teve_perda_de_cheiro_ou_sabor`** ⭐ | `STRING` | **Anosmia/Ageusia (most specific symptom)** | `"Sim"`, `"Não"` |
| `B00112` | `na_semana_passada_teve_dor_muscular` | `STRING` | Myalgia | `"Sim"`, `"Não"` |
| `B00113` | `na_semana_passada_teve_diarreia` | `STRING` | Diarrhea | `"Sim"`, `"Não"` |

---

### 💊 Care and Testing (Section B002-B011)

| Original Column | Gold Layer Name | Type | Description |
|-----------------|-------------------|------|-----------|
| `B002` | `por_causa_disso_foi_a_algum_estabelecimento_de_saude` | `STRING` | Sought medical care | `"Sim"`, `"Não"` |
| `B005` | `ao_procurar_o_hospital_teve_que_ficar_internado` | `STRING` | Hospital admission | `"Sim"`, `"Não"` |
| `B006` | `durante_a_internacao_foi_sedado_entubado` | `STRING` | Mechanical ventilation | `"Sim"`, `"Não"` |
| `B007` | `tem_algum_plano_de_saude_medico` | `STRING` | Private health plan | `"Sim"`, `"Não"` |
| `B008` | `o_a_sr_a_fez_algum_teste_para_saber_se_estava_infectado` | `STRING` | Performed COVID test | `"Sim"`, `"Não"` |
| `B009A` | **`fez_o_exame_coletado_com_cotonete_na_boca_e_ou_nariz_swab`** | `STRING` | **RT-PCR test (SWAB)** | `"Sim"`, `"Não"` |
| `B009B` | **`qual_o_resultado`** ⭐ | `STRING` | **SWAB result** | `"Positivo"`, `"Negativo"`, `"Inconclusivo"`, `"Ainda não recebeu"` |
| `B009C` | `fez_o_exame_de_coleta_de_sangue_atraves_de_furo_no_dedo` | `STRING` | Rapid test (finger) | `"Sim"`, `"Não"` |
| `B009D` | **`qual_o_resultado_2`** | `STRING` | Rapid test result | `"Positivo"`, `"Negativo"`, ... |
| `B009E` | `fez_o_exame_de_coleta_de_sangue_atraves_da_veia_do_braco` | `STRING` | Serology (vein) | `"Sim"`, `"Não"` |
| `B009F` | **`qual_o_resultado_3`** | `STRING` | Serology result | `"Positivo"`, `"Negativo"`, ... |
| `B011` | `na_semana_passada_devido_a_pandemia_em_que_medida_restringiu_contato` | `STRING` | Social isolation | `"Ficou rigorosamente em casa"`, `"Reduziu o contato..."`, ... |

---

### 🏢 Work and Occupation (Section C)

| Original Column | Gold Layer Name | Type | Description |
|-----------------|-------------------|------|-----------|
| `C001` | `na_semana_passada_por_pelo_menos_uma_hora_trabalhou` | `STRING` | Worked during the week | `"Sim"`, `"Não"` |
| `C002` | `na_semana_passada_estava_temporariamente_afastado` | `STRING` | Temporary leave | `"Sim"`, `"Não"` |
| `C006` | `no_trabalho_unico_ou_principal_que_tinha_era` | `STRING` | Employment type | `"Empregado do setor privado"`, `"Conta própria"`, `"Empregador"` |
| `C007` | `esse_trabalho_era_na_area` | `STRING` | Work location | `"Urbana"`, `"Rural"` |
| `C007B` | `tem_carteira_de_trabalho_assinada` | `STRING` | Formalization | `"Sim, tem carteira assinada"`, `"Não"` |
| `C007C` | `que_tipo_de_trabalho_cargo_ou_funcao_realiza` | `STRING` | Coded occupation | `"Técnico, profissional da saúde"`, `"Pedreiro, servente..."` |
| `C007D` | `qual_e_a_principal_atividade_do_local_ou_empresa` | `STRING` | Economic sector | `"Saúde humana"`, `"Construção"`, `"Comércio"` |
| `C013` | **`na_semana_passada_o_a_sr_a_estava_em_trabalho_remoto_home_office`** ⭐ | `STRING` | **Remote work** | `"Sim"`, `"Não"` |
| `C015` | `qual_o_principal_motivo_de_nao_ter_procurado_trabalho` | `STRING` | Inactivity reason | `"Estava estudando"`, `"Devido à pandemia"`, ... |

---

### 💰 Income and Aid (Section D and E)

| Original Column | Gold Layer Name | Type | Description |
|-----------------|-------------------|------|-----------|
| `D0011` | `rendimento_de_aposentadoria_e_pensao` | `STRING` | Received retirement pension | `"Sim"`, `"Não"` |
| `D0013` | `somatorio_dos_valores_aposentadoria` | `INT` | Total amount received | `0` to `999999` |
| `D0031` | `rendimentos_de_programa_bolsa_familia` | `STRING` | Received Bolsa Família | `"Sim"`, `"Não"` |
| `D0033` | `somatorio_dos_valores_bolsa_familia` | `INT` | Bolsa Família amount | `89` (typical) |
| `D0051` | **`auxilios_emergenciais_relacionados_ao_coronavirus`** ⭐ | `STRING` | **Received emergency aid** | `"Sim"`, `"Não"` |
| `D0053` | **`somatorio_dos_valores_auxilio_emergencial`** | `INT` | **Aid amount** | `600`, `1200` (common values) |
| `D0061` | `seguro_desemprego` | `STRING` | Received unemployment insurance | `"Sim"`, `"Não"` |
| `E001` | `durante_a_pandemia_alguem_deste_domicilio_solicitou_emprestimo` | `STRING` | Requested loan | `"Sim"`, `"Não"`, `"Não solicitou"` |

---

### 🏠 Household Characteristics (Section F)

| Original Column | Gold Layer Name | Type | Description |
|-----------------|-------------------|------|-----------|
| `F001` | `este_domicilio_e` | `STRING` | Housing type | `"Próprio - já pago"`, `"Alugado"`, `"Cedido"` |
| `F002A1` | `no_seu_domicilio_ha_sabao_ou_detergente` | `STRING` | Hygiene item | `"Sim"`, `"Não"` |
| `F002A2` | `no_seu_domicilio_ha_alcool_70_ou_superior` | `STRING` | Alcohol gel | `"Sim"`, `"Não"` |
| `F002A3` | `no_seu_domicilio_ha_mascaras` | `STRING` | Masks | `"Sim"`, `"Não"` |
| `F002A4` | `no_seu_domicilio_ha_luvas_descartaveis` | `STRING` | Gloves | `"Sim"`, `"Não"` |
| `F002A5` | `no_seu_domicilio_ha_agua_sanitaria_ou_desinfetante` | `STRING` | Disinfectant | `"Sim"`, `"Não"` |
| `F006` | `quem_respondeu_ao_questionario` | `STRING` | Survey respondent | `"Pessoa moradora"`, `"Responsável"` |

---

## 🔢 Calculated Variables in Glue (Silver/Gold Layer)

These columns are **created** during Glue PySpark processing:

| Calculated Column | Type | Formula/Logic | Use |
|------------------|------|----------------|-----|
| `id` | `BIGINT` | `row_number() OVER (ORDER BY ano, mes, uf)` | Unique primary key |
| `mes_nome` | `STRING` | `CASE WHEN mes_da_pesquisa = 9 THEN 'September'...` | Facilitate visualization |
| `faixa_etaria` | `STRING` | `CASE WHEN idade < 18 THEN '0-17' WHEN idade < 30 THEN '18-29'...` | Age grouping |
| `possui_sintomas` | `BOOLEAN` | `B0011='Sim' OR B0012='Sim' OR ... OR B00113='Sim'` | Symptomatic flag |
| `testou_positivo` | `BOOLEAN` | `qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo'` | Confirmed infection flag |
| `fez_algum_teste` | `BOOLEAN` | `B009A='Sim' OR B009C='Sim' OR B009E='Sim'` | Testing flag |

---

## 📐 Analytical Metrics (SQL Queries in Athena)

These metrics are **calculated** in queries from file `athena/business_queries.sql`:

### Positivity Rate
```sql
ROUND(
    100.0 * SUM(CASE WHEN testou_positivo THEN 1 ELSE 0 END) 
    / NULLIF(SUM(CASE WHEN fez_algum_teste THEN 1 ELSE 0 END), 0)
, 1) AS positivity_rate_pct
```

### Test Access Rate
```sql
ROUND(
    100.0 * COUNT(CASE WHEN B009A='Sim' OR B009C='Sim' OR B009E='Sim' THEN 1 END)
    / COUNT(*)
, 1) AS test_access_rate
```

### COVID Chance (given specific symptom)
```sql
ROUND(
    100.0 * SUM(CASE WHEN symptom='Sim' AND testou_positivo THEN 1 END)
    / NULLIF(SUM(CASE WHEN symptom='Sim' THEN 1 END), 0)
, 1) AS covid_chance_given_symptom
```

---

## 🎯 Top 20 Most Used Columns in Analysis

Based on the **15 business questions** (`athena/business_queries.sql`):

1. ⭐ `mes_da_pesquisa` - Group by period
2. ⭐ `sexo` - Gender analysis
3. ⭐ `idade_do_morador` - Age stratification
4. ⭐ `cor_ou_raca` - Racial inequality
5. ⭐ `escolaridade` - Education influence
6. ⭐ `qual_o_resultado` - SWAB result (main)
7. ⭐ `qual_o_resultado_2` - Rapid test result
8. ⭐ `qual_o_resultado_3` - Serology result
9. ⭐ `na_semana_passada_teve_perda_de_cheiro_ou_sabor` - Most specific symptom
10. ⭐ `fez_o_exame_coletado_com_cotonete_na_boca_e_ou_nariz_swab` - Testing rate
11. ⭐ `tem_algum_plano_de_saude_medico` - Access inequality
12. ⭐ `na_semana_passada_o_a_sr_a_estava_em_trabalho_remoto_home_office` - Distancing impact
13. ⭐ `unidade_da_federacao` - Regional analysis
14. ⭐ `auxilios_emergenciais_relacionados_ao_coronavirus` - Social vulnerability
15. ⭐ `capital` - Capital vs. interior
16. `na_semana_passada_teve_febre` - Classic symptom
17. `na_semana_passada_teve_tosse` - Classic symptom
18. `na_semana_passada_teve_dificuldade_para_respirar` - Severe symptom
19. `por_causa_disso_foi_a_algum_estabelecimento_de_saude` - Severity
20. `no_trabalho_unico_ou_principal_que_tinha_era` - Employment type

---

## 📚 References

- **Official Source**: [PNAD COVID-19 - IBGE](https://covid19.ibge.gov.br/pnad-covid/)
- **Original Dictionary**: `data/Dicionario_PNAD_COVID_*.csv`
- **Processing Notebook**: `code/PNAD_Covid.ipynb`
- **Analytical Queries**: `athena/business_queries.sql` (15 key questions)
- **Gold Table (S3)**: `s3://your-pnad-bucket/data-output/pnad_covid_gold/`

---

## 💡 Usage Tips

### For Analysts:
```sql
-- Basic query for exploration
SELECT 
    mes_da_pesquisa,
    sexo,
    COUNT(*) AS total_records,
    SUM(CASE WHEN qual_o_resultado = 'Positivo' THEN 1 ELSE 0 END) AS positives
FROM tb_pnad_covid_gold
WHERE mes_da_pesquisa IN (9, 10, 11)
GROUP BY mes_da_pesquisa, sexo
ORDER BY mes_da_pesquisa, sexo;
```

### For Data Engineers:
```python
# Read Gold table in PySpark
df_gold = spark.read.parquet("s3://your-pnad-bucket/data-output/pnad_covid_gold/")

# Verify schema
df_gold.printSchema()

# Count records per month
df_gold.groupBy("mes_da_pesquisa").count().show()
```

---

<div align="center">

**📖 Document generated from analysis of the real data pipeline**  
**Last update**: January 2026

</div>
