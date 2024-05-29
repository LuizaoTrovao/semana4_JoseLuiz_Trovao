-- Criar procedure Insere_Projeto
-- Criando procedure para cadastrar um novo projeto na base de dados:
CREATE OR REPLACE PROCEDURE brh.insere_projeto
(
    p_NOME        BRH.PROJETO.NOME%TYPE,
    p_RESPONSAVEL BRH.PROJETO.RESPONSAVEL%TYPE,
    p_INICIO      BRH.PROJETO.INICIO%TYPE
)
IS
BEGIN
    IF LENGTH(p_NOME) > 1 AND p_NOME IS NOT NULL THEN
        INSERT INTO BRH.PROJETO
        (NOME, RESPONSAVEL, INICIO)
        VALUES
        (p_NOME, p_RESPONSAVEL, p_INICIO);
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Nome de projeto inválido! Deve ter dois ou mais caracteres.');
    END IF;
END;

-- Criar função calcula_idade
-- Criando uma função para calcular a idade a partir de uma data de nascimento.

CREATE OR REPLACE FUNCTION  brh.calcula_idade
(
    p_DATA_NASCIMENTO DATE
)
RETURN NUMBER
IS
    v_IDADE NUMBER;
BEGIN
    IF p_DATA_NASCIMENTO < SYSDATE AND p_DATA_NASCIMENTO IS NOT NULL THEN
        v_IDADE := TRUNC(MONTHS_BETWEEN (SYSDATE, p_DATA_NASCIMENTO) / 12);
        RETURN v_IDADE;
    ELSE
        RAISE_APPLICATION_ERROR(-20001, 'Impossível calcular idade! Data inválida: ' || TO_CHAR(p_DATA_NASCIMENTO, 'DD/MM/YYYY'));
    END IF;
END;

-- Criar função finaliza_projeto
-- Criando uma função para registrar o término de um projeto
CREATE OR REPLACE FUNCTION brh.finaliza_projeto(p_ID IN BRH.PROJETO.ID%TYPE) RETURN DATE IS
    v_FIM DATE;
BEGIN
    v_FIM := SYSDATE;
    UPDATE BRH.PROJETO SET FIM = v_FIM WHERE ID = p_ID;
    RETURN v_FIM;
END;

-- Criar procedure define_atribuicao
-- Criando uma procedure para inserir um colaborador em um projeto em um determinado papel
CREATE OR REPLACE PROCEDURE brh.define_atribuicao
(
    p_NOME_COLABORADOR IN BRH.COLABORADOR.NOME%TYPE,
    p_NOME_PROJETO     IN BRH.PROJETO.NOME%TYPE,
    p_PAPEL            IN BRH.PAPEL.NOME%TYPE
)
IS
    BEGIN
        INSERT INTO BRH.ATRIBUICAO
        (
            (SELECT MATRICULA FROM BRH.COLABORADOR WHERE NOME = p_NOME_COLABORADOR),
            (SELECT ID        FROM BRH.PROJETO     WHERE NOME = p_NOME_PROJETO),
            (SELECT ID        FROM BRH.PAPEL       WHERE NOME = p_PAPEL)
        );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Não foi possível realizar a atribuição. Dados fornecidos são inválidos.');
    END;
END;