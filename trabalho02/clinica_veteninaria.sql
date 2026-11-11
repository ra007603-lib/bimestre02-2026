
/* JULIANO LEIA ESSE COMENTÁRIO */

	-- Como na ultima aula eu mandei os códigos em pdf, para resolver o problema estão aqui os códigos da 1 e 2 aula


-- Apaga tudo antes de criar
DROP TABLE IF EXISTS consulta_servico CASCADE;
DROP TABLE IF EXISTS consulta CASCADE;
DROP TABLE IF EXISTS servico CASCADE;
DROP TABLE IF EXISTS animal CASCADE;
DROP TABLE IF EXISTS veterinario CASCADE;
DROP TABLE IF EXISTS tutor CASCADE;
-- TUTOR: aqui ficam os responsáveis pelos animais. O CPF não pode repetir.
CREATE TABLE tutor (
id_tutor INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
nome VARCHAR(100) NOT NULL,
cpf CHAR(14) NOT NULL UNIQUE,
telefone VARCHAR(15) NOT NULL,
email VARCHAR(100) UNIQUE,
cidade VARCHAR(60) NOT NULL DEFAULT 'São Sebastião do Paraíso',
data_cadastro DATE NOT NULL DEFAULT CURRENT_DATE,
CONSTRAINT ck_tutor_cpf_formato CHECK (cpf ~ '^\d{3}\.\d{3}\.\d{3}-\d{2}$')
);
-- VETERINARIO: os profissionais que atendem CRMV é único para cada um.
CREATE TABLE veterinario (
id_veterinario INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
nome VARCHAR(100) NOT NULL,
crmv VARCHAR(12) NOT NULL UNIQUE,
especialidade VARCHAR(50) NOT NULL DEFAULT 'Clínica Geral',
valor_consulta NUMERIC(8,2) NOT NULL,
ativo BOOLEAN NOT NULL DEFAULT TRUE,
CONSTRAINT ck_vet_valor_consulta CHECK (valor_consulta > 0)
);
-- ANIMAL: os pacientes da clínica, cada um precisa ter um tutor cadastrado.
CREATE TABLE animal (
id_animal INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
id_tutor INTEGER NOT NULL,
nome VARCHAR(50) NOT NULL,
especie VARCHAR(30) NOT NULL,
raca VARCHAR(50) NOT NULL DEFAULT 'Sem raça definida',
sexo CHAR(1) NOT NULL,
data_nascimento DATE NOT NULL,
peso_kg NUMERIC(5,2) NOT NULL,
CONSTRAINT fk_animal_tutor FOREIGN KEY (id_tutor)
REFERENCES tutor (id_tutor) ON DELETE RESTRICT,
CONSTRAINT ck_animal_sexo CHECK (sexo IN ('M', 'F')),
CONSTRAINT ck_animal_peso CHECK (peso_kg > 0 AND peso_kg <= 100),
CONSTRAINT ck_animal_nascimento CHECK (data_nascimento <= CURRENT_DATE)
);
-- SERVICO: o catálogo do que a clínica oferece, com o preço de tabela.
CREATE TABLE servico (
id_servico INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
descricao VARCHAR(80) NOT NULL UNIQUE,
categoria VARCHAR(30) NOT NULL,
valor NUMERIC(8,2) NOT NULL,
CONSTRAINT ck_servico_categoria CHECK
(categoria IN ('Consulta', 'Vacinação', 'Exame', 'Procedimento', 'Cirurgia')),
CONSTRAINT ck_servico_valor CHECK (valor >= 0)
);
-- CONSULTA: cada atendimento (marcado, feito ou cancelado). O mesmo
-- veterinário não pode ter duas consultas no mesmo horário.
CREATE TABLE consulta (
id_consulta INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
id_animal INTEGER NOT NULL,
id_veterinario INTEGER NOT NULL,
data_hora TIMESTAMP NOT NULL,
status VARCHAR(10) NOT NULL DEFAULT 'Agendada',
observacoes VARCHAR(200),
CONSTRAINT fk_consulta_animal FOREIGN KEY (id_animal)
REFERENCES animal (id_animal) ON DELETE RESTRICT,
CONSTRAINT fk_consulta_veterinario FOREIGN KEY (id_veterinario)
REFERENCES veterinario (id_veterinario) ON DELETE RESTRICT,
CONSTRAINT ck_consulta_status CHECK
(status IN ('Agendada', 'Realizada', 'Cancelada')),
CONSTRAINT uq_consulta_vet_horario UNIQUE (id_veterinario, data_hora)
);
-- CONSULTA_SERVICO: o que foi feito em cada consulta e quanto foi cobrado.
-- A chave primária é composta, então o mesmo serviço não repete na consulta.
CREATE TABLE consulta_servico (
id_consulta INTEGER NOT NULL,
id_servico INTEGER NOT NULL,
quantidade INTEGER NOT NULL DEFAULT 1,
valor_cobrado NUMERIC(8,2) NOT NULL,
CONSTRAINT pk_consulta_servico PRIMARY KEY (id_consulta, id_servico),
CONSTRAINT fk_cs_consulta FOREIGN KEY (id_consulta)
REFERENCES consulta (id_consulta) ON DELETE CASCADE,
CONSTRAINT fk_cs_servico FOREIGN KEY (id_servico)
REFERENCES servico (id_servico) ON DELETE RESTRICT,
CONSTRAINT ck_cs_quantidade CHECK (quantidade >= 1),
CONSTRAINT ck_cs_valor CHECK (valor_cobrado >= 0)
);
-- Agora os dados. Os IDs são gerados sozinhos (1, 2, 3...), então os
-- números usados nas chaves estrangeiras valem para um banco recém-criado.
-- 10 tutores, de várias cidades da região
INSERT INTO tutor (nome, cpf, telefone, email, cidade, data_cadastro) VALUES
('Mariana Souza Lima', '111.222.333-01', '(35) 99811-0001',
'mariana.lima@email.com', 'São Sebastião do Paraíso', '2025-01-15'),
('Carlos Eduardo ', '222.333.444-02', '(35) 99811-0002', 'carlos.ribeiro@email.com', 'São
Sebastião do Paraíso', '2025-02-03'),
('Fernanda ', '333.444.555-03', '(35) 99811-0003', 'fernanda.costa@email.com',
'Passos', '2025-03-20'),
('Roberto Pereira', '444.555.666-04', '(35) 99811-0004', 'roberto.pereira@email.com',
'Guaxupé', '2025-04-11'),
('Juliana Rocha', '555.666.777-05', '(35) 99811-0005', 'juliana.rocha@email.com', 'São
Sebastião do Paraíso', '2025-05-07'),
('Paulo Duarte', '666.777.888-06', '(35) 99811-0006', 'paulo.duarte@email.com',
'Capetinga', '2025-06-25'),
('Aline Cristina Barbosa', '777.888.999-07', '(35) 99811-0007', 'aline.barbosa@email.com',
'São Sebastião do Paraíso', '2025-08-14'),
(' Vinícius Teixeira','888.999.000-08', '(35) 99811-0008', 'marcos.teixeira@email.com',
'Itamogi', '2025-09-30'),
('Patrícia Gomes Ferreira', '999.000.111-09', '(35) 99811-0009',
'patricia.ferreira@email.com','São Sebastião do Paraíso','2026-01-12'),
('Lucas Andrade Moreira', '000.111.222-10', '(35) 99811-0010',
'lucas.moreira@email.com', 'Passos', '2026-03-05');
-- 10 veterinários de especialidades diferentes (o último está inativo)
INSERT INTO veterinario (nome, crmv, especialidade, valor_consulta, ativo) VALUES
('Dra. Helena Prado', 'MG-10001', 'Clínica Geral', 120.00, TRUE),
('Dr. Rafael Monteiro', 'MG-10002', 'Ortopedia', 180.00, TRUE),
('Dra. Beatriz Campos', 'MG-10003', 'Dermatologia', 160.00, TRUE),
('Dr. André Figueiredo', 'MG-10004', 'Cardiologia', 200.00, TRUE),
('Dra. Camila Torres', 'MG-10005', 'Felinos', 150.00, TRUE),
('Dr. Thiago Barros', 'MG-10006', 'Oftalmologia', 170.00, TRUE),
('Dra. Larissa Medeiros', 'MG-10007', 'Odontologia', 140.00, TRUE),
('Dr. Gustavo Henrique Reis','MG-10008','Animais Silvestres', 190.00, TRUE),
('Dra. Renata Vasconcelos', 'MG-10009', 'Oncologia', 210.00, TRUE),
('Dr. Eduardo Salles', 'MG-10010', 'Anestesiologia', 130.00, FALSE);
-- 10 animais. Os tutores 1 e 2 têm dois cada, e os tutores 9 e 10 ainda
-- não cadastraram nenhum (de propósito, para testar os LEFT JOIN depois).
INSERT INTO animal (id_tutor, nome, especie, raca, sexo, data_nascimento, peso_kg)
VALUES
(1, 'Thor', 'Cachorro', 'Labrador', 'M', '2019-04-10', 32.50),
(1, 'Mel', 'Gato', 'Siamês', 'F', '2021-08-22', 4.20),
(2, 'Bob', 'Cachorro', 'Golden Retriever', 'M', '2018-11-05', 30.80),
(2, 'Luna', 'Cachorro', 'Poodle', 'F', '2020-02-18', 6.10),
(3, 'Mimi', 'Gato', 'Persa', 'F', '2022-06-30', 3.90),
(4, 'Rex', 'Cachorro', 'Pastor Alemão', 'M', '2017-09-12', 36.00),
(5, 'Pipoca', 'Coelho', 'Mini Lop', 'F', '2023-03-01', 1.80),
(6, 'Fred', 'Cachorro', 'Sem raça definida', 'M', '2020-12-25', 14.70),
(7, 'Nina', 'Gato', 'Sem raça definida', 'F', '2021-05-14', 4.50),
(8, 'Zeca', 'Ave', 'Calopsita', 'M', '2024-01-20', 0.09);
-- 10 serviços do catálogo
INSERT INTO servico (descricao, categoria, valor) VALUES
('Consulta clínica', 'Consulta', 120.00),
('Vacina V10', 'Vacinação', 95.00),
('Vacina antirrábica', 'Vacinação', 60.00),
('Hemograma completo', 'Exame', 80.00),
('Raio-X', 'Exame', 150.00),
('Ultrassonografia', 'Exame', 180.00),
('Limpeza dentária', 'Procedimento', 250.00),
('Vermifugação', 'Procedimento', 40.00),
('Castração', 'Cirurgia', 450.00),
('Banho terapêutico', 'Procedimento', 70.00);
-- 10 consultas: a maioria já realizada, uma cancelada e duas agendadas
INSERT INTO consulta (id_animal, id_veterinario, data_hora, status, observacoes)
VALUES
(1, 1, '2026-08-05 09:00', 'Realizada', 'Check-up anual e vacinação'),
(2, 5, '2026-08-12 10:30', 'Realizada', 'Gato apático, solicitado hemograma'),
(3, 2, '2026-08-20 14:00', 'Realizada', 'Claudicação na pata traseira'),
(4, 3, '2026-09-02 08:30', 'Realizada', 'Coceira e vermelhidão na pele'),
(5, 5, '2026-09-10 11:00', 'Realizada', 'Vacinação e vermifugação'),
(6, 4, '2026-09-18 15:30', 'Realizada', 'Avaliação cardíaca de rotina'),
(7, 8, '2026-09-25 09:30', 'Cancelada', 'Tutor desmarcou por imprevisto'),
(8, 1, '2026-10-07 16:00', 'Realizada', 'Vacina antirrábica e consulta'),
(9, 7, '2026-11-10 10:00', 'Agendada', 'Limpeza dentária programada'),
(1, 2, '2026-11-17 13:30', 'Agendada', 'Retorno ortopédico');
-- 14 itens cobrados. A consulta 4 teve 10% de desconto no banho (63,00
-- em vez de 70,00) e a consulta 3 teve duas chapas de raio-X.
INSERT INTO consulta_servico (id_consulta, id_servico, quantidade, valor_cobrado)
VALUES
(1, 1, 1, 120.00),
(1, 2, 1, 95.00),
(2, 1, 1, 150.00),
(2, 4, 1, 80.00),
(3, 1, 1, 180.00),
(3, 5, 2, 150.00),
(4, 1, 1, 160.00),
(4, 10, 1, 63.00),
(5, 2, 1, 95.00),
(5, 8, 1, 40.00),
(6, 1, 1, 200.00),
(6, 6, 1, 180.00),
(8, 1, 1, 120.00),
(8, 3, 1, 60.00);
-- Agora as consultas (SELECT) para analisar os dados.
-- Q1) Lista os cachorros com o nome do tutor e a cidade, do mais pesado
-- para o mais leve (JOIN + filtro no WHERE).
SELECT a.nome AS animal,
a.raca,
a.peso_kg,
t.nome AS tutor,
t.cidade
FROM animal a
JOIN tutor t ON t.id_tutor = a.id_tutor
WHERE a.especie = 'Cachorro'
ORDER BY a.peso_kg DESC;
-- Q2) Quantos animais cada tutor tem. Uso LEFT JOIN para os tutores sem
-- animal também aparecerem, com zero (LEFT JOIN + GROUP BY).
SELECT t.nome AS tutor,
COUNT(a.id_animal) AS qtd_animais
FROM tutor t
LEFT JOIN animal a ON a.id_tutor = t.id_tutor
GROUP BY t.id_tutor, t.nome
ORDER BY qtd_animais DESC, t.nome;
-- Q3) Quantas consultas cada veterinário já realizou. Cancelada e agendada
-- não entram na conta (JOIN + GROUP BY + filtro).
SELECT v.nome AS veterinario,
v.especialidade,
COUNT(c.id_consulta) AS consultas_realizadas
FROM veterinario v
JOIN consulta c ON c.id_veterinario = v.id_veterinario
WHERE c.status = 'Realizada'
GROUP BY v.id_veterinario, v.nome, v.especialidade
ORDER BY consultas_realizadas DESC, v.nome;
-- Q4) Quanto foi cobrado em cada consulta realizada, mostrando animal,
-- tutor e veterinário (JOIN de 5 tabelas + GROUP BY).
SELECT c.id_consulta,
TO_CHAR(c.data_hora, 'DD/MM/YYYY HH24:MI') AS data_hora,
a.nome AS animal,
t.nome AS tutor,
v.nome AS veterinario,
SUM(cs.quantidade * cs.valor_cobrado) AS total_cobrado
FROM consulta c
JOIN animal a ON a.id_animal = c.id_animal
JOIN tutor t ON t.id_tutor = a.id_tutor
JOIN veterinario v ON v.id_veterinario = c.id_veterinario
JOIN consulta_servico cs ON cs.id_consulta = c.id_consulta
WHERE c.status = 'Realizada'
GROUP BY c.id_consulta, c.data_hora, a.nome, t.nome, v.nome
ORDER BY total_cobrado DESC;
-- Q5) Quanto cada categoria de serviço rendeu (JOIN + GROUP BY).
SELECT s.categoria,
SUM(cs.quantidade) AS itens_prestados,
SUM(cs.quantidade * cs.valor_cobrado) AS faturamento
FROM consulta_servico cs
JOIN servico s ON s.id_servico = cs.id_servico
GROUP BY s.categoria
ORDER BY faturamento DESC;
-- Q6) Tutores que gastaram mais de R$ 300,00 na clínica. O HAVING filtra
-- depois da soma (GROUP BY + HAVING).
SELECT t.nome AS tutor,
SUM(cs.quantidade * cs.valor_cobrado) AS total_gasto
FROM tutor t
JOIN animal a ON a.id_tutor = t.id_tutor
JOIN consulta c ON c.id_animal = a.id_animal
JOIN consulta_servico cs ON cs.id_consulta = c.id_consulta
GROUP BY t.id_tutor, t.nome
HAVING SUM(cs.quantidade * cs.valor_cobrado) > 300
ORDER BY total_gasto DESC;
-- Q7) Consultas feitas ou canceladas entre agosto e setembro de 2026
-- (filtros com AND, IN e BETWEEN).
SELECT c.id_consulta,
c.data_hora,
a.nome AS animal,
c.status,
c.observacoes
FROM consulta c
JOIN animal a ON a.id_animal = c.id_animal
WHERE c.data_hora BETWEEN '2026-08-01' AND '2026-09-30 23:59:59'
AND c.status IN ('Realizada', 'Cancelada')
ORDER BY c.data_hora;
-- Q8) Peso médio, menor e maior por espécie de animal (funções de agregação).
SELECT especie,
COUNT(*) AS qtd,
ROUND(AVG(peso_kg), 2) AS peso_medio_kg,
MIN(peso_kg) AS menor_peso_kg,
MAX(peso_kg) AS maior_peso_kg
FROM animal
GROUP BY especie
ORDER BY qtd DESC;
-- Q9) Ranking dos serviços mais usados nas consultas.
SELECT s.descricao,
s.categoria,
COUNT(cs.id_consulta) AS vezes_em_consultas,
SUM(cs.quantidade) AS total_unidades
FROM servico s
JOIN consulta_servico cs ON cs.id_servico = s.id_servico
GROUP BY s.id_servico, s.descricao, s.categoria
HAVING COUNT(cs.id_consulta) >= 1
ORDER BY vezes_em_consultas DESC, total_unidades DESC, s.descricao;
-- Q10) Animais que nunca tiveram consulta. Dá para a clínica entrar em
-- contato com os tutores (LEFT JOIN + IS NULL).
SELECT a.nome AS animal,
a.especie,
t.nome AS tutor,
t.telefone
FROM animal a
JOIN tutor t ON t.id_tutor = a.id_tutor
LEFT JOIN consulta c ON c.id_animal = a.id_animal
WHERE c.id_consulta IS NULL
ORDER BY a.nome;
-- Q11) Próximas consultas agendadas, com veterinário e especialidade.
SELECT TO_CHAR(c.data_hora, 'DD/MM/YYYY HH24:MI') AS data_hora,
a.nome AS animal,
t.nome AS tutor,
v.nome AS veterinario,
v.especialidade
FROM consulta c
JOIN animal a ON a.id_animal = c.id_animal
JOIN tutor t ON t.id_tutor = a.id_tutor
JOIN veterinario v ON v.id_veterinario = c.id_veterinario
WHERE c.status = 'Agendada'
ORDER BY c.data_hora;
-- Q12) Veterinários ativos e quantas consultas cada um tem, de qualquer
-- status. Quem ainda não atendeu aparece com zero.
SELECT v.nome,
v.especialidade,
COUNT(c.id_consulta) AS total_consultas
FROM veterinario v
LEFT JOIN consulta c ON c.id_veterinario = v.id_veterinario
WHERE v.ativo = TRUE
GROUP BY v.id_veterinario, v.nome, v.especialidade
ORDER BY total_consultas DESC, v.nome;

-- FUNCTION 1: Calcula o total de uma consulta
CREATE OR REPLACE FUNCTION fn_total_consulta(p_id_consulta INTEGER)
RETURNS NUMERIC(10,2)
LANGUAGE SQL
AS $$
    SELECT COALESCE(
        SUM(cs.quantidade * cs.valor_cobrado),
        0
    )::NUMERIC(10,2)
    FROM consulta_servico cs
    WHERE cs.id_consulta = p_id_consulta;
$$;


-- FUNCTION 2: Qtd de animais por tutor
CREATE OR REPLACE FUNCTION fn_quantidade_animais_tutor(p_id_tutor INTEGER)
RETURNS INTEGER
LANGUAGE SQL
AS $$
    SELECT COUNT(*)::INTEGER
    FROM animal a
    WHERE a.id_tutor = p_id_tutor;
$$;
-- FUNCTION 3: Consultas realizadas por veterinário
CREATE OR REPLACE FUNCTION fn_consultas_realizadas_veterinario(
    p_id_veterinario INTEGER
)
RETURNS INTEGER
LANGUAGE SQL
AS $$
    SELECT COUNT(*)::INTEGER
    FROM consulta c
    WHERE c.id_veterinario = p_id_veterinario
      AND c.status = 'Realizada';
$$;
-- TESTES DAS FUNCTIONS
SELECT fn_total_consulta(1);

SELECT fn_quantidade_animais_tutor(1);

SELECT fn_consultas_realizadas_veterinario(1);

