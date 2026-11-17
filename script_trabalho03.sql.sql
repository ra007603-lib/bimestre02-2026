--trabalho 03
SELECT
    c.id_consulta AS codigo_consulta,
    a.nome AS animal,
    c.status AS status_consulta,
    c.data_hora AS data_consulta
FROM consulta c
INNER JOIN animal a
    ON a.id_animal = c.id_animal
WHERE
    (c.status = 'Realizada' OR c.status = 'Agendada')
    AND c.data_hora >= '2026-08-01'
ORDER BY c.data_hora;


-- QUESTÃO 2
SELECT
    c.id_consulta AS codigo_consulta,
    a.nome AS animal,
    c.observacoes AS observacoes
FROM consulta c
INNER JOIN animal a
    ON a.id_animal = c.id_animal
WHERE
    NOT (c.observacoes ILIKE '%vacina%')
    AND c.observacoes IS NOT NULL
ORDER BY c.id_consulta;


-- QUESTÃO 3
SELECT
    id_servico AS codigo_servico,
    descricao AS nome_servico,
    categoria AS categoria_servico,
    valor AS valor_servico
FROM servico
WHERE
    valor BETWEEN 50 AND 200
    AND categoria IN ('Consulta', 'Vacinação', 'Exame')
ORDER BY valor;


-- QUESTÃO 4A
SELECT
    id_tutor AS codigo_tutor,
    nome AS nome_tutor,
    telefone AS telefone_tutor
FROM tutor
WHERE nome ILIKE '%a%'
ORDER BY nome;


-- QUESTÃO 4B
SELECT
    id_veterinario AS codigo_veterinario,
    nome AS nome_veterinario,
    crmv AS registro_crmv
FROM veterinario
WHERE crmv LIKE 'MG-_____'
ORDER BY nome;


-- QUESTÃO 5


SELECT
    descricao AS nome_servico,
    valor AS valor_original,
    ROUND(valor * 1.10, 2) AS valor_arredondado,
    TRUNC(valor * 1.10, 2) AS valor_truncado,
    CEIL(valor * 1.10) AS valor_arredondado_inteiro
FROM servico
ORDER BY descricao;


-- QUESTÃO 6A
SELECT
    id_animal AS codigo_animal,
    nome AS nome_animal,
    especie AS especie_animal,
    CASE
        WHEN MOD(id_animal, 2) = 0 THEN 'Par'
        else 'Ímpar'
    END AS classificacao
FROM animal
ORDER BY id_animal;


-- QUESTÃO 6B


SELECT
    id_veterinario AS codigo_veterinario,
    nome as nome_veterinario,
    especialidade AS especialidade
FROM veterinario
where ativo = TRUE
ORDER BY RANDOM()
LIMIT 1;


-- QUESTÃO 7

select
    CONCAT(
        'Animal: ', COALESCE(a.nome, 'Não informado'),
        ' | Tutor: ', COALESCE(t.nome, 'Não informado'),
        ' | Veterinário: ', COALESCE(v.nome, 'Não informado')
    ) AS descricao_atendimento,
    INITCAP(t.nome) AS tutor_padronizado,
    v.crmv AS registro_completo,
    SPLIT_PART(v.crmv, '-', 2) AS numero_crmv
from animal a
INNER JOIN tutor t
    ON t.id_tutor = a.id_tutor
INNER JOIN consulta c
    ON c.id_animal = a.id_animal
INNER JOIN veterinario v
    ON v.id_veterinario = c.id_veterinario
ORDER BY a.nome;


-- QUESTÃO 8
SELECT
    id_consulta AS codigo_consulta,
    data_hora AS data_hora_consulta,
    extract(YEAR FROM data_hora) AS ano_consulta,
    EXTRACT(MONTH FROM data_hora) AS mes_consulta,
    EXTRACT(HOUR FROM data_hora) AS hora_consulta,
    DATE_TRUNC('month', data_hora) AS inicio_mes
from consulta
WHERE data_hora >= NOW() - INTERVAL '365 days'
ORDER BY data_hora DESC;


-- QUESTÃO 9
SELECT
    id_tutor AS codigo_tutor,
    nome AS nome_tutor,
    data_cadastro AS data_cadastro,
    AGE(NOW(), data_cadastro) AS tempo_desde_cadastro,
    data_cadastro + INTERVAL '1 year' AS data_renovacao
FROM tutor
ORDER BY data_cadastro;


-- QUESTÃO 10
select
    LPAD(c.id_consulta::TEXT, 5, '0') AS codigo_consulta,
    TO_CHAR(c.data_hora, 'DD/MM/YYYY') AS data_consulta,
    a.nome AS nome_animal,
    t.nome AS nome_tutor,
    v.nome AS nome_veterinario,
    v.especialidade AS especialidade,
    TO_CHAR(
        SUM(cs.quantidade * cs.valor_cobrado),
        'FM"R$" 999G999G990D00'
    ) AS valor_total
FROM consulta c
INNER JOIN animal a
    ON a.id_animal = c.id_animal
INNER JOIN tutor t
    ON t.id_tutor = a.id_tutor
INNER JOIN veterinario v
    ON v.id_veterinario = c.id_veterinario
INNER JOIN consulta_servico cs
    ON cs.id_consulta = c.id_consulta
WHERE c.status = 'Realizada'
GROUP BY
    c.id_consulta,
    c.data_hora,
    a.nome,
    t.nome,
    v.nome,
    v.especialidade
ORDER BY c.data_hora;

