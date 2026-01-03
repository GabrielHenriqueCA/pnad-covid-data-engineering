-- =====================================================
-- PNAD COVID-19 - Criação da Tabela Raw (Bronze Layer)
-- =====================================================
--
-- ⚠️ NOTA IMPORTANTE:
--   Este arquivo é EDUCACIONAL/CONCEITUAL.
--   No projeto real, a camada BRONZE é processada via
--   AWS Glue (PySpark) no arquivo: code/PNAD_Covid.ipynb
--
--   Este DDL mostra COMO seria a definição se usássemos
--   apenas Athena para processar os CSVs brutos.
--
-- Descrição:
--   Define a estrutura da tabela externa para leitura dos
--   dados brutos (CSVs) armazenados no S3.
--
-- Pré-requisitos:
--   - Arquivos CSV já carregados no S3
--   - Permissões de leitura no bucket S3
--
-- Camada: BRONZE (Raw Data)
-- ==============================================================================

CREATE EXTERNAL TABLE IF NOT EXISTS pnad_covid_raw (
    -- Identificação
    Ano INTEGER,
    UF CHAR(2),
    CAPITAL INTEGER,
    RM_RIDE INTEGER,
    V1008 INTEGER,           -- Número do domicílio
    V1012 INTEGER,           -- Semana no mês
    V1013 INTEGER,           -- Mês da pesquisa
    V1016 INTEGER,           -- Número de pessoas no domicílio
    
    -- Características do Indivíduo
    A002 INTEGER,            -- Idade
    A003 INTEGER,            -- Sexo (1=Masculino, 2=Feminino)
    A004 INTEGER,            -- Cor ou raça
    A005 INTEGER,            -- Escolaridade
    
    -- Sintomas COVID-19
    B0011 STRING,            -- Na semana passada teve febre?
    B0012 STRING,            -- Na semana passada teve tosse?
    B0013 STRING,            -- Na semana passada teve dor de garganta?
    B0014 STRING,            -- Na semana passada teve dificuldade para respirar?
    B0015 STRING,            -- Na semana passada teve dor de cabeça?
    B0016 STRING,            -- Na semana passada teve dor no peito?
    B0017 STRING,            -- Na semana passada teve náusea?
    B0018 STRING,            -- Na semana passada teve nariz entupido/escorrendo?
    B0019 STRING,            -- Na semana passada teve fadiga?
    B00110 STRING,           -- Na semana passada teve dor nos olhos?
    B00111 STRING,           -- Na semana passada teve perda de cheiro ou sabor?
    B00112 STRING,           -- Na semana passada teve dor muscular?
    
    -- Acesso a Serviços de Saúde
    B002 STRING,             -- Por causa disso, foi a algum estabelecimento de saúde?
    B007 STRING,             -- Teve que ficar internado?
    B009B STRING,            -- Fez exame cotonete?
    B011 STRING,             -- Qual foi o resultado?
    
    -- Aspectos Econômicos
    C001 STRING,             -- Na semana passada, trabalhou (mesmo remotamente)?
    C002 STRING,             -- Qual o principal motivo?
    C007 STRING,             -- Quantas horas trabalhou?
    C008 STRING,             -- Qual era o valor do rendimento bruto?
    C013 STRING,             -- Recebeu auxílio emergencial?
    
    -- Peso e Fatores de Expansão
    V1032 DECIMAL(10,2)      -- Peso
)
COMMENT 'Dados brutos da PNAD COVID-19 - Set/Out/Nov 2020'
ROW FORMAT DELIMITED 
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
STORED AS TEXTFILE
LOCATION 's3://seu-bucket-pnad/raw/pnad-covid/'
TBLPROPERTIES (
    'skip.header.line.count'='1',
    'projection.enabled'='false'
);

-- Validação: Contar registros
SELECT COUNT(*) AS total_registros FROM pnad_covid_raw;
