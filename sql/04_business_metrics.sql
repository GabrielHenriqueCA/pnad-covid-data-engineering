-- ==============================================================================
-- Script: 04_business_metrics.sql
-- Descrição: Métricas de negócio calculadas na camada de dados (Gold Layer)
-- Objetivo: Garantir consistência das regras de negócio para o Power BI
-- Autor: Gabriel Henrique - Data Engineer
-- ==============================================================================

CREATE TABLE pnad_covid_metrics
WITH (
    format = 'PARQUET',
    parquet_compression = 'SNAPPY',
    external_location = 's3://seu-bucket-pnad/gold/pnad-covid-metrics/'
)
AS
SELECT 
    -- =========================================================================
    -- DIMENSÕES
    -- =========================================================================
    Ano,
    UF,
    tipo_municipio,
    faixa_etaria,
    sexo_desc,
    cor_raca_desc,
    
    -- =========================================================================
    -- MÉTRICAS COVID-19
    -- =========================================================================
    
    -- Taxa de Positividade (% de testes positivos sobre total de testes)
    ROUND(
        CAST(SUM(CASE WHEN resultado_teste = 'Positivo' THEN 1 ELSE 0 END) AS DECIMAL) / 
        NULLIF(CAST(SUM(fez_teste) AS DECIMAL), 0) * 100, 
        2
    ) AS taxa_positividade_pct,
    
    -- Taxa de Acesso a Saúde (% que procurou atendimento entre sintomáticos)
    ROUND(
        CAST(SUM(procurou_atendimento) AS DECIMAL) / 
        NULLIF(CAST(SUM(CASE WHEN total_sintomas > 0 THEN 1 ELSE 0 END) AS DECIMAL), 0) * 100,
        2
    ) AS taxa_acesso_saude_pct,
    
    -- Taxa de Internação (% internados entre os que procuraram atendimento)
    ROUND(
        CAST(SUM(foi_internado) AS DECIMAL) / 
        NULLIF(CAST(SUM(procurou_atendimento) AS DECIMAL), 0) * 100,
        2
    ) AS taxa_internacao_pct,
    
    -- =========================================================================
    -- CARACTERÍSTICAS CLÍNICAS (prevalência de sintomas)
    -- =========================================================================
    
    -- Top 5 sintomas mais comuns (em %)
    ROUND(CAST(SUM(teve_febre) AS DECIMAL) / COUNT(*) * 100, 2) AS prevalencia_febre_pct,
    ROUND(CAST(SUM(teve_tosse) AS DECIMAL) / COUNT(*) * 100, 2) AS prevalencia_tosse_pct,
    ROUND(CAST(SUM(teve_dor_cabeca) AS DECIMAL) / COUNT(*) * 100, 2) AS prevalencia_dor_cabeca_pct,
    ROUND(CAST(SUM(teve_perda_olfato) AS DECIMAL) / COUNT(*) * 100, 2) AS prevalencia_perda_olfato_pct,
    ROUND(CAST(SUM(teve_dificuldade_respirar) AS DECIMAL) / COUNT(*) * 100, 2) AS prevalencia_dificuldade_respirar_pct,
    
    -- Média de sintomas por pessoa
    ROUND(AVG(total_sintomas), 2) AS media_sintomas_por_pessoa,
    
    -- =========================================================================
    -- IMPACTO ECONÔMICO
    -- =========================================================================
    
    -- Taxa de pessoas trabalhando
    ROUND(
        CAST(SUM(trabalhou_semana) AS DECIMAL) / COUNT(*) * 100,
        2
    ) AS taxa_emprego_pct,
    
    -- Média de horas trabalhadas (entre quem trabalhou)
    ROUND(
        AVG(CASE WHEN trabalhou_semana = 1 THEN horas_trabalhadas ELSE NULL END),
        1
    ) AS media_horas_trabalhadas,
    
    -- Rendimento médio mensal
    ROUND(
        AVG(rendimento_mensal),
        2
    ) AS rendimento_medio_mensal,
    
    -- Taxa de cobertura do Auxílio Emergencial
    ROUND(
        CAST(SUM(recebeu_auxilio_emergencial) AS DECIMAL) / COUNT(*) * 100,
        2
    ) AS taxa_auxilio_emergencial_pct,
    
    -- =========================================================================
    -- CONTADORES
    -- =========================================================================
    COUNT(*) AS total_pessoas,
    SUM(peso) AS populacao_expandida,
    SUM(CASE WHEN resultado_teste = 'Positivo' THEN 1 ELSE 0 END) AS total_casos_positivos,
    SUM(foi_internado) AS total_internacoes

FROM pnad_covid_clean
GROUP BY 
    Ano,
    UF,
    tipo_municipio,
    faixa_etaria,
    sexo_desc,
    cor_raca_desc;

-- ==============================================================================
-- VALIDAÇÃO DE MÉTRICAS
-- ==============================================================================

-- Verificar taxa de positividade geral (espera-se ~15-25% no período)
SELECT 
    ROUND(
        CAST(SUM(CASE WHEN resultado_teste = 'Positivo' THEN 1 ELSE 0 END) AS DECIMAL) / 
        NULLIF(CAST(SUM(fez_teste) AS DECIMAL), 0) * 100, 
        2
    ) AS taxa_positividade_geral
FROM pnad_covid_clean;

-- Top 5 UFs com maior taxa de positividade
SELECT 
    UF,
    taxa_positividade_pct,
    total_pessoas
FROM pnad_covid_metrics
WHERE taxa_positividade_pct IS NOT NULL
ORDER BY taxa_positividade_pct DESC
LIMIT 5;

-- ==============================================================================
-- BENEFÍCIOS DE CALCULAR NA ORIGEM:
-- ==============================================================================
-- ✅ Consistência: Uma única definição de regra de negócio (single source of truth)
-- ✅ Performance: Power BI não precisa fazer cálculos pesados
-- ✅ Reuso: Mesmas métricas disponíveis para outros consumidores (Tableau, Python, etc.)
-- ✅ Governança: Métricas certificadas e auditáveis
