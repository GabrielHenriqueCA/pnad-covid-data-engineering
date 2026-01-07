-- P1: 
SELECT 
    -- Tratamento para exibir o nome do mês (ajuste os números conforme sua base, ex: 9=Set, 10=Out)
    CASE 
        WHEN mes_da_pesquisa = 9 THEN 'Setembro'
        WHEN mes_da_pesquisa = 10 THEN 'Outubro'
        WHEN mes_da_pesquisa = 11 THEN 'Novembro'
        ELSE CAST(mes_da_pesquisa AS VARCHAR)
    END AS mes,

    sexo,

    -- Cálculo da Taxa %
    ROUND(
        100.0 * SUM(CASE 
            WHEN qual_o_resultado = 'Positivo' OR qual_o_resultado_2 = 'Positivo' OR qual_o_resultado_3 = 'Positivo' 
            THEN 1 ELSE 0 END) 
        / 
        NULLIF(SUM(CASE 
            WHEN qual_o_resultado IN ('Positivo', 'Negativo') OR qual_o_resultado_2 IN ('Positivo', 'Negativo') OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
            THEN 1 ELSE 0 END), 0)
    , 1) AS taxa_percentual,

    -- Contagem de Positivos
    SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' OR qual_o_resultado_2 = 'Positivo' OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) AS total_positivos,

    -- Contagem de Testados (Conclusivos)
    SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') OR qual_o_resultado_2 IN ('Positivo', 'Negativo') OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) AS total_testados

FROM tb_pnad_covid_gold
WHERE 
    sexo IS NOT NULL 
    AND mes_da_pesquisa IN (9, 10, 11) -- Filtro para os meses desejados
GROUP BY 
    mes_da_pesquisa, 
    sexo
ORDER BY 
    mes_da_pesquisa, 
    sexo;

---------------------------------------------
-- P2:

SELECT 
    CASE 
        WHEN mes_da_pesquisa = 9 THEN 'Setembro'
        WHEN mes_da_pesquisa = 10 THEN 'Outubro'
        WHEN mes_da_pesquisa = 11 THEN 'Novembro'
        ELSE CAST(mes_da_pesquisa AS VARCHAR)
    END AS mes,

    CASE 
        WHEN idade_do_morador <= 19 THEN '00-19 Anos'
        WHEN idade_do_morador BETWEEN 20 AND 29 THEN '20-29 Anos'
        WHEN idade_do_morador BETWEEN 30 AND 39 THEN '30-39 Anos'
        WHEN idade_do_morador BETWEEN 40 AND 49 THEN '40-49 Anos'
        WHEN idade_do_morador BETWEEN 50 AND 59 THEN '50-59 Anos'
        WHEN idade_do_morador >= 60 THEN '60+ Anos'
        ELSE 'Indefinido'
    END AS faixa_etaria,

    -- Taxa %
    ROUND(
        100.0 * SUM(CASE 
            WHEN qual_o_resultado = 'Positivo' OR qual_o_resultado_2 = 'Positivo' OR qual_o_resultado_3 = 'Positivo' 
            THEN 1 ELSE 0 END) 
        / 
        NULLIF(SUM(CASE 
            WHEN qual_o_resultado IN ('Positivo', 'Negativo') OR qual_o_resultado_2 IN ('Positivo', 'Negativo') OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
            THEN 1 ELSE 0 END), 0)
    , 1) AS taxa_percentual,

    -- Totais para o texto
    SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' OR qual_o_resultado_2 = 'Positivo' OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) AS total_positivos,

    SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') OR qual_o_resultado_2 IN ('Positivo', 'Negativo') OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) AS total_testados

FROM tb_pnad_covid_gold
WHERE 
    mes_da_pesquisa IN (9, 10, 11)
    AND sexo IS NOT NULL
GROUP BY 
    mes_da_pesquisa, 
    2 -- Agrupa pelo CASE da faixa etária
ORDER BY 
    mes_da_pesquisa, 
    faixa_etaria;

---------------------------------------------
-- P3: 

SELECT 
    CASE 
        WHEN mes_da_pesquisa = 9 THEN 'Setembro'
        WHEN mes_da_pesquisa = 10 THEN 'Outubro'
        WHEN mes_da_pesquisa = 11 THEN 'Novembro'
        ELSE CAST(mes_da_pesquisa AS VARCHAR)
    END AS mes,

    cor_ou_raca AS raca,

    -- 1. Contexto Populacional
    COUNT() AS populacao_total,

    -- 2. Análise de ACESSO (Quem conseguiu testar?)
    SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') OR qual_o_resultado_2 IN ('Positivo', 'Negativo') OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) AS total_testados,

    -- Taxa de Acesso %
    ROUND(100.0 SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') OR qual_o_resultado_2 IN ('Positivo', 'Negativo') OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(), 0), 2) AS taxa_acesso_exame,

    -- 3. Análise de VULNERABILIDADE (Quem testou positivo?)
    SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' OR qual_o_resultado_2 = 'Positivo' OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) AS total_positivos,

    -- Taxa de Positividade %
    ROUND(100.0 SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' OR qual_o_resultado_2 = 'Positivo' OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) 
        / 
        NULLIF(SUM(CASE 
            WHEN qual_o_resultado IN ('Positivo', 'Negativo') OR qual_o_resultado_2 IN ('Positivo', 'Negativo') OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
            THEN 1 ELSE 0 END), 0)
    , 2) AS taxa_positividade_resultante

FROM tb_pnad_covid_gold
WHERE 
    cor_ou_raca <> 'Ignorado' 
    AND mes_da_pesquisa IN (9, 10, 11)
GROUP BY 
    mes_da_pesquisa, 
    cor_ou_raca
ORDER BY 
    mes_da_pesquisa, 
    taxa_positividade_resultante DESC;

---------------------------------------------
-- P4: 

SELECT 
    escolaridade,

    -- 1. Volume da População (Quem são?)
    COUNT() AS populacao_total,

    -- 2. Quem testou?
    SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') OR qual_o_resultado_2 IN ('Positivo', 'Negativo') OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) AS total_testados,

    -- Taxa de Acesso aos Exames
    ROUND(100.0 SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') OR qual_o_resultado_2 IN ('Positivo', 'Negativo') OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(), 0), 2) AS taxa_acesso_exame,

    -- 3. Quem deu Positivo?
    SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' OR qual_o_resultado_2 = 'Positivo' OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) AS total_positivos,

    -- Taxa de Positividade (O Risco Real)
    ROUND(100.0 SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' OR qual_o_resultado_2 = 'Positivo' OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) 
        / 
        NULLIF(SUM(CASE 
            WHEN qual_o_resultado IN ('Positivo', 'Negativo') OR qual_o_resultado_2 IN ('Positivo', 'Negativo') OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
            THEN 1 ELSE 0 END), 0)
    , 2) AS taxa_positividade_resultante

FROM tb_pnad_covid_gold
WHERE escolaridade <> 'Ignorado' -- Limpando sujeira
GROUP BY escolaridade
ORDER BY taxa_positividade_resultante DESC;

---------------------------------------------
-- P5:

WITH CasosPositivos AS (
    SELECT
    FROM tb_pnad_covid_gold
    WHERE qual_o_resultado = 'Positivo' 
       OR qual_o_resultado_2 = 'Positivo' 
       OR qual_o_resultado_3 = 'Positivo'
)

SELECT '1. Perda de Cheiro ou Sabor' as sintoma, COUNT() as qtd FROM CasosPositivos WHERE na_semana_passada_teve_perda_de_cheiro_ou_sabor = 'Sim'
UNION ALL
SELECT '2. Dor de Cabeça', COUNT() FROM CasosPositivos WHERE na_semana_passada_teve_dor_de_cabeca = 'Sim'
UNION ALL
SELECT '3. Febre', COUNT() FROM CasosPositivos WHERE na_semana_passada_teve_febre = 'Sim'
UNION ALL
SELECT '4. Tosse', COUNT() FROM CasosPositivos WHERE na_semana_passada_teve_tosse = 'Sim'
UNION ALL
SELECT '5. Dor de Garganta', COUNT() FROM CasosPositivos WHERE na_semana_passada_teve_dor_de_garganta = 'Sim'
UNION ALL
SELECT '6. Dor Muscular', COUNT() FROM CasosPositivos WHERE na_semana_passada_teve_dor_muscular = 'Sim'
UNION ALL
SELECT '7. Nariz Entupido', COUNT() FROM CasosPositivos WHERE na_semana_passada_teve_nariz_entupido_ou_escorrendo = 'Sim'
UNION ALL
SELECT '8. Fadiga', COUNT() FROM CasosPositivos WHERE na_semana_passada_teve_fadiga = 'Sim'
UNION ALL
SELECT '9. Dificuldade de Respirar', COUNT() FROM CasosPositivos WHERE na_semana_passada_teve_dificuldade_para_respirar = 'Sim'
UNION ALL
SELECT '10. Dor nos Olhos', COUNT() FROM CasosPositivos WHERE na_semana_passada_teve_dor_nos_olhos = 'Sim'
UNION ALL
SELECT '11. Diarreia', COUNT() FROM CasosPositivos WHERE na_semana_passada_teve_diarreia = 'Sim'
UNION ALL
SELECT '12. Nausea', COUNT() FROM CasosPositivos WHERE na_semana_passada_teve_nausea = 'Sim'
UNION ALL
SELECT '13. Dor no Peito', COUNT(*) FROM CasosPositivos WHERE na_semana_passada_teve_dor_no_peito = 'Sim'

ORDER BY qtd DESC;

---------------------------------------------
-- P6:

/* Query: Qual sintoma é o melhor preditor de Covid? (Maior Taxa de Positividade) */

WITH BaseTestada AS (
    -- Filtramos apenas quem fez teste com resultado conclusivo
    SELECT *
    FROM tb_pnad_covid_gold
    WHERE qual_o_resultado IN ('Positivo', 'Negativo') 
       OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
       OR qual_o_resultado_3 IN ('Positivo', 'Negativo')
)

SELECT 'Perda de Cheiro/Sabor' as sintoma, 
       COUNT(*) as total_pessoas_com_sintoma,
       SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END) as positivos,
       ROUND(100.0 * SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END) / COUNT(*), 2) as chance_de_ser_covid
FROM BaseTestada WHERE na_semana_passada_teve_perda_de_cheiro_ou_sabor = 'Sim'

UNION ALL

SELECT 'Febre', COUNT(*) , SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM BaseTestada WHERE na_semana_passada_teve_febre = 'Sim'

UNION ALL

SELECT 'Dificuldade Respirar', COUNT(*) , SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM BaseTestada WHERE na_semana_passada_teve_dificuldade_para_respirar = 'Sim'

UNION ALL

SELECT 'Dor de Cabeça', COUNT(*) , SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM BaseTestada WHERE na_semana_passada_teve_dor_de_cabeca = 'Sim'

UNION ALL

SELECT 'Tosse', COUNT(*) , SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM BaseTestada WHERE na_semana_passada_teve_tosse = 'Sim'

UNION ALL

SELECT 'Dor Muscular', COUNT(*) , SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END),
       ROUND(100.0 * SUM(CASE WHEN qual_o_resultado='Positivo' OR qual_o_resultado_2='Positivo' OR qual_o_resultado_3='Positivo' THEN 1 ELSE 0 END) / COUNT(*), 2)
FROM BaseTestada WHERE na_semana_passada_teve_dor_muscular = 'Sim'

ORDER BY chance_de_ser_covid DESC;

---------------------------------------------
-- P7:

SELECT 
    CASE 
        WHEN na_semana_passada_teve_febre = 'Sim'
          OR na_semana_passada_teve_tosse = 'Sim'
          OR na_semana_passada_teve_dor_de_garganta = 'Sim'
          OR na_semana_passada_teve_dificuldade_para_respirar = 'Sim'
          OR na_semana_passada_teve_dor_de_cabeca = 'Sim'
          OR na_semana_passada_teve_dor_no_peito = 'Sim'
          OR na_semana_passada_teve_nausea = 'Sim'
          OR na_semana_passada_teve_nariz_entupido_ou_escorrendo = 'Sim'
          OR na_semana_passada_teve_fadiga = 'Sim'
          OR na_semana_passada_teve_dor_nos_olhos = 'Sim'
          OR na_semana_passada_teve_perda_de_cheiro_ou_sabor = 'Sim'
          OR na_semana_passada_teve_dor_muscular = 'Sim'
          OR na_semana_passada_teve_diarreia = 'Sim'
        THEN 'Sintomático'
        ELSE 'Assintomático'
    END AS quadro_clinico,

    COUNT(*) AS total_infectados,

    -- Cálculo da porcentagem do grupo em relação ao total de positivos
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS porcentagem_do_total

FROM tb_pnad_covid_gold
WHERE 
    qual_o_resultado = 'Positivo' 
    OR qual_o_resultado_2 = 'Positivo' 
    OR qual_o_resultado_3 = 'Positivo'
GROUP BY 1
ORDER BY total_infectados DESC;

---------------------------------------------
-- P8:

SELECT 
    na_semana_passada_o_a_sr_a_estava_em_trabalho_remoto_home_office_ou_teletrabalho AS fez_home_office,

    -- 1. Volume (Quantos trabalhadores em cada grupo?)
    COUNT(*) AS total_trabalhadores,

    -- 2. Quem testou?
    SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) AS total_testados,

    -- 3. Taxa de Positividade (O Risco Real)
    ROUND(100.0 * SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' 
          OR qual_o_resultado_2 = 'Positivo' 
          OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) 
        / 
        NULLIF(SUM(CASE 
            WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
            THEN 1 ELSE 0 END), 0)
    , 2) AS taxa_positividade_percentual

FROM tb_pnad_covid_gold
-- Filtramos apenas Sim/Não para pegar a força de trabalho ativa
WHERE na_semana_passada_o_a_sr_a_estava_em_trabalho_remoto_home_office_ou_teletrabalho IN ('Sim', 'Não')
GROUP BY 1
ORDER BY taxa_positividade_percentual DESC;

---------------------------------------------
-- P9:

SELECT 
    capital,

    -- 1. Contexto (Quantos testes foram feitos?)
    SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) AS total_testados,

    -- Taxa de Acesso (Do total de pessoas nessa área, quantas testaram?)
    ROUND(100.0 * SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(*), 0), 2) AS taxa_acesso_populacao,

    -- 2. Positivos (Quantos doentes?)
    SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' 
          OR qual_o_resultado_2 = 'Positivo' 
          OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) AS total_positivos,

    -- 3. Taxa de Positividade (O Risco Real)
    ROUND(100.0 * SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' 
          OR qual_o_resultado_2 = 'Positivo' 
          OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) 
        / 
        NULLIF(SUM(CASE 
            WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
            THEN 1 ELSE 0 END), 0)
    , 2) AS taxa_positividade_percentual

FROM tb_pnad_covid_gold
WHERE capital IS NOT NULL -- Garantindo dados limpos
GROUP BY capital
ORDER BY taxa_positividade_percentual DESC;

-----------------------------------------------------------
-- P10:

WITH MetricasTestes AS (
    -- 1. Exame do Cotonete (SWAB)
    SELECT 
        '1. SWAB (Cotonete/Nariz)' AS tipo_teste,
        qual_o_resultado AS resultado
    FROM tb_pnad_covid_gold
    WHERE fez_o_exame_coletado_com_cotonete_na_boca_e_ou_nariz_swab = 'Sim'

    UNION ALL

    -- 2. Exame Rápido (Furo no Dedo)
    SELECT 
        '2. RÁPIDO (Furo no Dedo)' AS tipo_teste,
        qual_o_resultado_2 AS resultado
    FROM tb_pnad_covid_gold
    WHERE fez_o_exame_de_coleta_de_sangue_atraves_de_furo_no_dedo = 'Sim'

    UNION ALL

    -- 3. Exame Sorológico (Veia do Braço)
    SELECT 
        '3. SOROLOGIA (Veia do Braço)' AS tipo_teste,
        qual_o_resultado_3 AS resultado
    FROM tb_pnad_covid_gold
    WHERE fez_o_exame_de_coleta_de_sangue_atraves_da_veia_da_braco = 'Sim'
)

SELECT 
    tipo_teste,
    
    -- Volume (Qual teste foi mais usado?)
    COUNT(*) AS total_realizados,

    -- Quantidade de Positivos
    SUM(CASE WHEN resultado = 'Positivo' THEN 1 ELSE 0 END) AS total_positivos,

    -- Taxa de Positividade
    ROUND(100.0 * SUM(CASE WHEN resultado = 'Positivo' THEN 1 ELSE 0 END) 
    / 
    NULLIF(COUNT(*), 0), 2) AS taxa_positividade

FROM MetricasTestes
WHERE resultado IN ('Positivo', 'Negativo') -- Filtramos apenas resultados conclusivos
GROUP BY tipo_teste
ORDER BY taxa_positividade DESC;

---------------------------------------------
-- P11:

SELECT 
    tem_algum_plano_de_saude_medico_seja_particular_de_empresa_ou_de_orgao_publico AS possui_plano,

    -- 1. Contexto (Tamanho dos grupos)
    COUNT(*) AS populacao_total,

    -- 2. Análise de ACESSO (Taxa de Testagem)
    SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) AS total_testados,
    
    -- % da população do grupo que conseguiu fazer o teste
    ROUND(100.0 * SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(*), 0), 2) AS taxa_acesso_exame,

    -- 3. Análise de RISCO (Taxa de Positividade)
    SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' 
          OR qual_o_resultado_2 = 'Positivo' 
          OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) AS total_positivos,

    -- % dos testes que deram positivo
    ROUND(100.0 * SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' 
          OR qual_o_resultado_2 = 'Positivo' 
          OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) 
        / 
        NULLIF(SUM(CASE 
            WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
            THEN 1 ELSE 0 END), 0)
    , 2) AS taxa_positividade_percentual

FROM tb_pnad_covid_gold
WHERE tem_algum_plano_de_saude_medico_seja_particular_de_empresa_ou_de_orgao_publico IN ('Sim', 'Não ')
GROUP BY 1
ORDER BY taxa_acesso_exame DESC;

---------------------------------------------
-- P12:

SELECT 
    unidade_da_federacao AS uf,

    -- 1. Contexto (População na Amostra)
    COUNT(*) AS populacao_amostra,

    -- 2. Quem testou?
    SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) AS total_testados,
    
    -- Taxa de Acesso (Quantos % da população do estado conseguiram testar?)
    ROUND(100.0 * SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(*), 0), 2) AS taxa_acesso,

    -- 3. Quem deu Positivo?
    SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' 
          OR qual_o_resultado_2 = 'Positivo' 
          OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) AS total_positivos,

    -- Taxa de Positividade (Gravidade)
    ROUND(100.0 * SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' 
          OR qual_o_resultado_2 = 'Positivo' 
          OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) 
        / 
        NULLIF(SUM(CASE 
            WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
            THEN 1 ELSE 0 END), 0)
    , 2) AS taxa_positividade_percentual

FROM tb_pnad_covid_gold
WHERE unidade_da_federacao IS NOT NULL
GROUP BY 1
ORDER BY taxa_positividade_percentual DESC;

---------------------------------------------
-- P13:

SELECT 
    na_semana_passada_o_a_sr_a_estava_em_trabalho_remoto_home_office_ou_teletrabalho AS fez_home_office,

    -- 1. População (Quantos estão em cada regime?)
    COUNT(*) AS total_trabalhadores,

    -- 2. Quem conseguiu testar?
    SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) AS total_testados,
    
    -- Taxa de Acesso (Quem teve o "privilégio" de testar?)
    ROUND(100.0 * SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(*), 0), 2) AS taxa_acesso_exame,

    -- 3. Quem deu positivo?
    SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' 
          OR qual_o_resultado_2 = 'Positivo' 
          OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) AS total_positivos,

    -- Taxa de Positividade (O Risco Real)
    ROUND(100.0 * SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' 
          OR qual_o_resultado_2 = 'Positivo' 
          OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) 
        / 
        NULLIF(SUM(CASE 
            WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
            THEN 1 ELSE 0 END), 0)
    , 2) AS taxa_positividade_percentual

FROM tb_pnad_covid_gold
-- Filtramos apenas Sim/Não para pegar a força de trabalho ativa e excluir desempregados/afastados
WHERE na_semana_passada_o_a_sr_a_estava_em_trabalho_remoto_home_office_ou_teletrabalho IN ('Sim', 'Não')
GROUP BY 1
ORDER BY taxa_positividade_percentual DESC;

---------------------------------------------
-- P14:

SELECT 
    auxilios_emergenciais_relacionados_ao_coronavirus AS recebeu_auxilio,

    -- 1. Tamanho do Grupo
    COUNT(*) AS populacao_total,

    -- 2. Quem conseguiu testar?
    SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) AS total_testados,
    
    -- Taxa de Acesso (Quem teve chance de diagnóstico?)
    ROUND(100.0 * SUM(CASE 
        WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
          OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
        THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(*), 0), 2) AS taxa_acesso_exame,

    -- 3. Quem testou Positivo?
    SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' 
          OR qual_o_resultado_2 = 'Positivo' 
          OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) AS total_positivos,

    -- Taxa de Positividade (O Risco Real)
    ROUND(100.0 * SUM(CASE 
        WHEN qual_o_resultado = 'Positivo' 
          OR qual_o_resultado_2 = 'Positivo' 
          OR qual_o_resultado_3 = 'Positivo' 
        THEN 1 ELSE 0 END) 
        / 
        NULLIF(SUM(CASE 
            WHEN qual_o_resultado IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_2 IN ('Positivo', 'Negativo') 
              OR qual_o_resultado_3 IN ('Positivo', 'Negativo') 
            THEN 1 ELSE 0 END), 0)
    , 2) AS taxa_positividade_percentual

FROM tb_pnad_covid_gold
WHERE auxilios_emergenciais_relacionados_ao_coronavirus IN ('Sim', 'Não')
GROUP BY 1
ORDER BY taxa_positividade_percentual DESC;
