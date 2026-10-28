-- ============================================================
-- SISTEMA DE GESTÃO DE CAMPEONATOS E TORNEIOS
-- Banco de dados: campeonato_db
-- Compatível com MariaDB / XAMPP / phpMyAdmin
-- ============================================================


-- ------------------------------------------------------------
-- DESATIVA TEMPORARIAMENTE AS VERIFICAÇÕES
-- ------------------------------------------------------------

SET @OLD_UNIQUE_CHECKS = @@UNIQUE_CHECKS;
SET UNIQUE_CHECKS = 0;

SET @OLD_FOREIGN_KEY_CHECKS = @@FOREIGN_KEY_CHECKS;
SET FOREIGN_KEY_CHECKS = 0;


-- ============================================================
-- 1. BANCO DE DADOS
-- ============================================================

DROP DATABASE IF EXISTS `campeonato_db`;

CREATE DATABASE `campeonato_db`
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_general_ci;

USE `campeonato_db`;


-- ============================================================
-- 2. TABELA USUARIO
-- ============================================================

CREATE TABLE `usuario` (
    `idusuario` INT NOT NULL AUTO_INCREMENT,
    `nome` VARCHAR(100) NOT NULL,
    `email` VARCHAR(150) NOT NULL,
    `senha` VARCHAR(255) NOT NULL,

    PRIMARY KEY (`idusuario`),

    UNIQUE KEY `email_UNIQUE` (`email`)
)
ENGINE = InnoDB;


-- ============================================================
-- 3. TABELA TIME
-- ============================================================

CREATE TABLE `time` (
    `idtime` INT NOT NULL AUTO_INCREMENT,
    `nome` VARCHAR(100) NOT NULL,
    `modalidade` VARCHAR(50) NOT NULL,

    PRIMARY KEY (`idtime`),

    UNIQUE KEY `nome_UNIQUE` (`nome`)
)
ENGINE = InnoDB;


-- ============================================================
-- 4. TABELA EQUIPAMENTO
--
-- Guarda os materiais/equipamentos utilizados nos jogos.
-- Exemplos:
-- bola, colete, kit de proteção, periféricos etc.
-- ============================================================

CREATE TABLE `equipamento` (
    `idequipamento` INT NOT NULL AUTO_INCREMENT,
    `codigo` VARCHAR(30) NOT NULL,
    `nome` VARCHAR(100) NOT NULL,

    `quantidade` INT NOT NULL DEFAULT 0,
    `estoque_minimo` INT NOT NULL DEFAULT 0,

    PRIMARY KEY (`idequipamento`),

    UNIQUE KEY `codigo_UNIQUE` (`codigo`)
)
ENGINE = InnoDB;


-- ============================================================
-- 5. TABELA ARBITRO
-- ============================================================

CREATE TABLE `arbitro` (
    `idarbitro` INT NOT NULL AUTO_INCREMENT,
    `nome` VARCHAR(100) NOT NULL,

    PRIMARY KEY (`idarbitro`)
)
ENGINE = InnoDB;


-- ============================================================
-- 6. TABELA JOGADOR
--
-- Cada jogador pertence a um time.
-- O mesmo número pode existir em times diferentes,
-- mas não pode se repetir dentro do mesmo time.
-- ============================================================

CREATE TABLE `jogador` (
    `idjogador` INT NOT NULL AUTO_INCREMENT,
    `nome` VARCHAR(100) NOT NULL,
    `numero` INT NOT NULL,

    `time_idtime` INT NOT NULL,

    PRIMARY KEY (`idjogador`),

    INDEX `fk_jogador_time_idx` (`time_idtime`),

    UNIQUE KEY `numero_time_UNIQUE`
        (`time_idtime`, `numero`),

    CONSTRAINT `fk_jogador_time`
        FOREIGN KEY (`time_idtime`)
        REFERENCES `time` (`idtime`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
ENGINE = InnoDB;


-- ============================================================
-- 7. TABELA PARTIDA
--
-- Registra:
-- - data prevista;
-- - data de realização;
-- - status;
-- - fase;
-- - placar;
-- - árbitro;
-- - time 1;
-- - time 2.
-- ============================================================

CREATE TABLE `partida` (
    `idpartida` INT NOT NULL AUTO_INCREMENT,

    `data_prevista` DATETIME NOT NULL,
    `data_realizacao` DATETIME NULL,

    `status` ENUM(
        'Agendada',
        'Concluída',
        'Cancelada'
    ) NOT NULL DEFAULT 'Agendada',

    `fase` ENUM(
        'Classificatória',
        'Eliminatória'
    ) NOT NULL,

    -- Enquanto a partida não for concluída,
    -- os pontos podem permanecer NULL.
    `pontos_time1` INT NULL,
    `pontos_time2` INT NULL,

    `arbitro_idarbitro` INT NOT NULL,
    `time_idtime1` INT NOT NULL,
    `time_idtime2` INT NOT NULL,

    PRIMARY KEY (`idpartida`),

    INDEX `fk_partida_arbitro_idx`
        (`arbitro_idarbitro`),

    INDEX `fk_partida_time1_idx`
        (`time_idtime1`),

    INDEX `fk_partida_time2_idx`
        (`time_idtime2`),

    CONSTRAINT `fk_partida_arbitro`
        FOREIGN KEY (`arbitro_idarbitro`)
        REFERENCES `arbitro` (`idarbitro`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT `fk_partida_time1`
        FOREIGN KEY (`time_idtime1`)
        REFERENCES `time` (`idtime`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT `fk_partida_time2`
        FOREIGN KEY (`time_idtime2`)
        REFERENCES `time` (`idtime`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
ENGINE = InnoDB;


-- ============================================================
-- 8. TABELA USO
--
-- Registra quais equipamentos/materiais foram utilizados
-- em determinada partida.
-- ============================================================

CREATE TABLE `uso` (
    `iduso` INT NOT NULL AUTO_INCREMENT,

    `quantidade_utilizada` INT NOT NULL,

    `equipamento_idequipamento` INT NOT NULL,
    `partida_idpartida` INT NOT NULL,

    PRIMARY KEY (`iduso`),

    INDEX `fk_uso_equipamento_idx`
        (`equipamento_idequipamento`),

    INDEX `fk_uso_partida_idx`
        (`partida_idpartida`),

    CONSTRAINT `fk_uso_equipamento`
        FOREIGN KEY (`equipamento_idequipamento`)
        REFERENCES `equipamento` (`idequipamento`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT `fk_uso_partida`
        FOREIGN KEY (`partida_idpartida`)
        REFERENCES `partida` (`idpartida`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
ENGINE = InnoDB;


-- ============================================================
-- 9. TABELA PONTUACAO_JOGADOR
--
-- Registra os pontos individuais obtidos por cada jogador
-- em uma determinada partida.
-- ============================================================

CREATE TABLE `pontuacao_jogador` (
    `idpontuacao` INT NOT NULL AUTO_INCREMENT,

    `pontos` INT NOT NULL DEFAULT 0,

    `jogador_idjogador` INT NOT NULL,
    `partida_idpartida` INT NOT NULL,

    PRIMARY KEY (`idpontuacao`),

    INDEX `fk_pontuacao_jogador_idx`
        (`jogador_idjogador`),

    INDEX `fk_pontuacao_partida_idx`
        (`partida_idpartida`),

    -- Impede registrar duas vezes o mesmo jogador
    -- na mesma partida.
    UNIQUE KEY `jogador_partida_UNIQUE`
        (`jogador_idjogador`, `partida_idpartida`),

    CONSTRAINT `fk_pontuacao_jogador`
        FOREIGN KEY (`jogador_idjogador`)
        REFERENCES `jogador` (`idjogador`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,

    CONSTRAINT `fk_pontuacao_partida`
        FOREIGN KEY (`partida_idpartida`)
        REFERENCES `partida` (`idpartida`)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
)
ENGINE = InnoDB;


-- ============================================================
-- 10. POPULAÇÃO DO BANCO
--
-- O enunciado solicita pelo menos 3 registros
-- em todas as tabelas.
-- ============================================================


-- ------------------------------------------------------------
-- USUARIOS
-- ------------------------------------------------------------

INSERT INTO `usuario`
(
    `nome`,
    `email`,
    `senha`
)
VALUES

(
    'Carlos Organizador',
    'carlos@liga.com',
    '123'
),

(
    'Fernanda Administradora',
    'fernanda@liga.com',
    '123'
),

(
    'Ricardo Coordenador',
    'ricardo@liga.com',
    '456'
);


-- ------------------------------------------------------------
-- TIMES
-- ------------------------------------------------------------

INSERT INTO `time`
(
    `nome`,
    `modalidade`
)
VALUES

(
    'Falcões',
    'Futsal'
),

(
    'Tigres',
    'Futsal'
),

(
    'Dragões',
    'Futsal'
);


-- ------------------------------------------------------------
-- EQUIPAMENTOS / MATERIAIS
-- ------------------------------------------------------------

INSERT INTO `equipamento`
(
    `codigo`,
    `nome`,
    `quantidade`,
    `estoque_minimo`
)
VALUES

(
    'EQ001',
    'Bola Oficial',
    20,
    5
),

(
    'EQ002',
    'Colete Esportivo',
    30,
    10
),

(
    'EQ003',
    'Kit de Proteção',
    15,
    5
);


-- ------------------------------------------------------------
-- ARBITROS
-- ------------------------------------------------------------

INSERT INTO `arbitro`
(
    `nome`
)
VALUES

(
    'João Silva'
),

(
    'Mariana Santos'
),

(
    'Pedro Oliveira'
);


-- ------------------------------------------------------------
-- JOGADORES
-- ------------------------------------------------------------

INSERT INTO `jogador`
(
    `nome`,
    `numero`,
    `time_idtime`
)
VALUES

(
    'Lucas Almeida',
    10,
    1
),

(
    'Gabriel Santos',
    7,
    2
),

(
    'Matheus Silva',
    9,
    3
);


-- ------------------------------------------------------------
-- PARTIDAS
-- ------------------------------------------------------------

INSERT INTO `partida`
(
    `data_prevista`,
    `data_realizacao`,
    `status`,
    `fase`,
    `pontos_time1`,
    `pontos_time2`,
    `arbitro_idarbitro`,
    `time_idtime1`,
    `time_idtime2`
)
VALUES

-- Partida 1
(
    '2026-10-20 14:00:00',
    '2026-10-20 15:30:00',
    'Concluída',
    'Classificatória',
    3,
    2,
    1,
    1,
    2
),

-- Partida 2
(
    '2026-10-25 16:00:00',
    '2026-10-25 17:30:00',
    'Concluída',
    'Classificatória',
    1,
    4,
    2,
    2,
    3
),

-- Partida 3
(
    '2026-11-05 18:00:00',
    NULL,
    'Agendada',
    'Eliminatória',
    NULL,
    NULL,
    3,
    1,
    3
);


-- ------------------------------------------------------------
-- USO DE EQUIPAMENTOS / MATERIAIS
-- ------------------------------------------------------------

INSERT INTO `uso`
(
    `quantidade_utilizada`,
    `equipamento_idequipamento`,
    `partida_idpartida`
)
VALUES

(
    2,
    1,
    1
),

(
    5,
    2,
    1
),

(
    3,
    3,
    2
);


-- ------------------------------------------------------------
-- PONTUAÇÃO INDIVIDUAL DOS JOGADORES
-- ------------------------------------------------------------

INSERT INTO `pontuacao_jogador`
(
    `pontos`,
    `jogador_idjogador`,
    `partida_idpartida`
)
VALUES

(
    2,
    1,
    1
),

(
    2,
    2,
    1
),

(
    3,
    3,
    2
);


-- ============================================================
-- 11. RESTAURA AS CONFIGURAÇÕES
-- ============================================================

SET FOREIGN_KEY_CHECKS = @OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS = @OLD_UNIQUE_CHECKS;


-- ============================================================
-- FIM DO SCRIPT
-- ============================================================