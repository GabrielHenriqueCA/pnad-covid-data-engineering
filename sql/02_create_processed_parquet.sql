-- =====================================================
-- PNAD COVID-19 - Conversão para Parquet (Silver Layer)
-- =====================================================
--
-- ⚠️ NOTA IMPORTANTE:
--   Este arquivo é EDUCACIONAL/CONCEITUAL.
--   No projeto real, a camada SILVER é processada via
--   AWS Glue (PySpark) no arquivo: code/PNAD_Covid.ipynb
--
--   A transformação Silver inclui:
--   - Unificação de 3 meses de dados
--   - Tradução de códigos → textos legíveis
--   - Renomeação inteligente de colunas
--
-- Descrição:
--   Este DDL mostra COMO seria a conversão se usássemos
--   apenas Athena (CTAS) para transformar os dados.
--
-- Pré-requisitos:
--   - Tabela bronze_pnad_covid já criada (ver 01_create_raw_table.sql)
--   - Permissões de escrita no bucket S3
--
-- Benefícios do Parquet + Snappy:
--   - Redução de ~79% no tamanho dos dados (344 MB → ~70 MB)
--   - Queries 5-6x mais rápidas (formato colunar)
--   - Custos de query reduzidos em ~80%
--
-- Camada: SILVER (Clean Data)
-- ==============================================================================

-- CTAS (Create Table As Select) - Estratégia ELT
CREATE TABLE pnad_covid_processed
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://seu-bucket-pnad/processed/pnad-covid/',
    bucketed_by = ARRAY['UF'],        -- Particionar por estado (opcional)
    bucket_count = 27                  -- 27 UFs do Brasil
)
AS 
SELECT 
    -- Identificação (mantém tipos originais)
    Ano,
    UF,
    CAPITAL,
    RM_RIDE,
    V1008,
    V1012,
    V1013,
    V1016,
    
    -- Características do Indivíduo (mantém tipos originais)
    A002 AS idade,
    A003 AS sexo,
    A004 AS cor_raca,
    A005 AS escolaridade,
    
    -- Sintomas COVID-19 (mantém como STRING para transformação posterior)
    B0011,
    B0012,
    B0013,
    B0014,
    B0015,
    B0016,
    B0017,
    B0018,
    B0019,
    B00110,
    B00111,
    B00112,
    
    -- Acesso a Serviços de Saúde
    B002,
    B007,
    B009B,
    B011,
    
    -- Aspectos Econômicos
    C001,
    C002,
    C007,
    C008,
    C013,
    
    -- Peso
    V1032 AS peso
FROM pnad_covid_raw
WHERE Ano IS NOT NULL;  -- Filtro básico de qualidade

-- ==============================================================================
-- RESULTADOS ESPERADOS
-- ==============================================================================
-- ✅ Redução de armazenamento: ~79% (344 MB → 70 MB)
-- ✅ Performance de query: 5-6x mais rápida
-- ✅ Custo por query: ~80% menor (menos dados escaneados)
-- ✅ Formato colunar: Lê apenas colunas necessárias

-- Validação: Comparar contagem
SELECT 
    (SELECT COUNT(*) FROM pnad_covid_raw) AS count_raw,
    (SELECT COUNT(*) FROM pnad_covid_processed) AS count_processed;
