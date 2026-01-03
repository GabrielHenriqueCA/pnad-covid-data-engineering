-- =====================================================
-- PNAD COVID-19 - Transformações de Qualidade de Dados
-- =====================================================
--
-- ⚠️ NOTA IMPORTANTE:
--   Este arquivo é EDUCACIONAL/CONCEITUAL.
--   No projeto real, TODAS as transformações de dados
--   (tradução, tipagem, renomeação) são feitas via
--   AWS Glue (PySpark) no arquivo: code/PNAD_Covid.ipynb
--
--   Este SQL demonstra COMO seriam as transformações
--   se fossem implementadas puramente em SQL/Athena.
--
-- Descrição:
--   Exemplos de transformações aplicadas no Glue:
--   - Tipagem correta (CAST string → int/decimal)
--   - Tradução códigos → textos (ex: "1" → "Positivo")
--   - Renomeação de colunas (ex: B009B → qual_o_resultado)
--   - Criação de colunas calculadas (ID, faixa_etaria)
--
-- Detalhes na Seção Silver do Glue Notebook (células 12-16)
--
-- Camada: SILVER → GOLD (Data Quality)
-- ==============================================================================

CREATE TABLE pnad_covid_clean
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://seu-bucket-pnad/refined/pnad-covid/'
)
AS
SELECT 
    -- =========================================================================
    -- DIMENSÕES DEMOGRÁFICAS (com limpeza e decodificação)
    -- =========================================================================
    Ano,
    UF,
    CASE 
        WHEN CAPITAL = 1 THEN 'Capital'
        WHEN CAPITAL = 2 THEN 'Interior'
        ELSE 'Não Informado'
    END AS tipo_municipio,
    
    -- Idade com validação
    CASE 
        WHEN idade BETWEEN 0 AND 120 THEN idade
        ELSE NULL 
    END AS idade_validada,
    
    -- Faixa etária
    CASE 
        WHEN idade < 18 THEN '0-17 anos'
        WHEN idade BETWEEN 18 AND 29 THEN '18-29 anos'
        WHEN idade BETWEEN 30 AND 59 THEN '30-59 anos'
        WHEN idade >= 60 THEN '60+ anos'
        ELSE 'Não Informado'
    END AS faixa_etaria,
    
    -- Sexo decodificado
    CASE 
        WHEN sexo = 1 THEN 'Masculino'
        WHEN sexo = 2 THEN 'Feminino'
        ELSE 'Não Informado'
    END AS sexo_desc,
    
    -- Cor/Raça decodificada
    CASE 
        WHEN cor_raca = 1 THEN 'Branca'
        WHEN cor_raca = 2 THEN 'Preta'
        WHEN cor_raca = 3 THEN 'Amarela'
        WHEN cor_raca = 4 THEN 'Parda'
        WHEN cor_raca = 5 THEN 'Indígena'
        ELSE 'Não Informado'
    END AS cor_raca_desc,
    
    -- =========================================================================
    -- SINTOMAS COVID-19 (tipagem correta: String -> Integer)
    -- =========================================================================
    CAST(B0011 AS INTEGER) AS teve_febre,
    CAST(B0012 AS INTEGER) AS teve_tosse,
    CAST(B0013 AS INTEGER) AS teve_dor_garganta,
    CAST(B0014 AS INTEGER) AS teve_dificuldade_respirar,
    CAST(B0015 AS INTEGER) AS teve_dor_cabeca,
    CAST(B0016 AS INTEGER) AS teve_dor_peito,
    CAST(B0017 AS INTEGER) AS teve_nausea,
    CAST(B0018 AS INTEGER) AS teve_nariz_entupido,
    CAST(B0019 AS INTEGER) AS teve_fadiga,
    CAST(B00110 AS INTEGER) AS teve_dor_olhos,
    CAST(B00111 AS INTEGER) AS teve_perda_olfato,
    CAST(B00112 AS INTEGER) AS teve_dor_muscular,
    
    -- Contagem de sintomas por pessoa
    COALESCE(CAST(B0011 AS INTEGER), 0) +
    COALESCE(CAST(B0012 AS INTEGER), 0) +
    COALESCE(CAST(B0013 AS INTEGER), 0) +
    COALESCE(CAST(B0014 AS INTEGER), 0) +
    COALESCE(CAST(B0015 AS INTEGER), 0) +
    COALESCE(CAST(B0016 AS INTEGER), 0) +
    COALESCE(CAST(B0017 AS INTEGER), 0) +
    COALESCE(CAST(B0018 AS INTEGER), 0) +
    COALESCE(CAST(B0019 AS INTEGER), 0) +
    COALESCE(CAST(B00110 AS INTEGER), 0) +
    COALESCE(CAST(B00111 AS INTEGER), 0) +
    COALESCE(CAST(B00112 AS INTEGER), 0) AS total_sintomas,
    
    -- =========================================================================
    -- ACESSO A SAÚDE (tipagem + limpeza)
    -- =========================================================================
    CAST(B002 AS INTEGER) AS procurou_atendimento,
    CAST(B007 AS INTEGER) AS foi_internado,
    CAST(B009B AS INTEGER) AS fez_teste,
    
    -- Resultado do teste (limpeza de strings)
    CASE 
        WHEN CAST(B011 AS INTEGER) = 1 THEN 'Positivo'
        WHEN CAST(B011 AS INTEGER) = 2 THEN 'Negativo'
        WHEN CAST(B011 AS INTEGER) = 3 THEN 'Inconclusivo'
        WHEN CAST(B011 AS INTEGER) = 4 THEN 'Aguardando Resultado'
        ELSE 'Não Testou'
    END AS resultado_teste,
    
    -- =========================================================================
    -- ASPECTOS ECONÔMICOS (tipagem + validação)
    -- =========================================================================
    CAST(C001 AS INTEGER) AS trabalhou_semana,
    CAST(C007 AS DECIMAL(5,1)) AS horas_trabalhadas,
    
    -- Rendimento (remover valores absurdos)
    CASE 
        WHEN TRY_CAST(C008 AS DECIMAL(12,2)) BETWEEN 0 AND 999999 
        THEN CAST(C008 AS DECIMAL(12,2))
        ELSE NULL 
    END AS rendimento_mensal,
    
    CAST(C013 AS INTEGER) AS recebeu_auxilio_emergencial,
    
    -- =========================================================================
    -- PESO AMOSTRAL
    -- =========================================================================
    peso

FROM pnad_covid_processed
WHERE Ano IS NOT NULL 
  AND UF IS NOT NULL;

-- ==============================================================================
-- REGRAS DE QUALIDADE APLICADAS:
-- ==============================================================================
-- ✅ Tipagem: String → Integer/Decimal onde aplicável
-- ✅ Validação: Ranges de idade, rendimento
-- ✅ Decodificação: Códigos → Labels descritivos
-- ✅ Enriquecimento: Faixa etária, total de sintomas
-- ✅ Limpeza: Filtros de valores nulos críticos
