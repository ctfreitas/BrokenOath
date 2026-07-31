-- =====================================================
-- BROKEN OATH
-- Seed Oficial - Cidades
-- Arquivo: 05_cidades.sql
-- =====================================================

INSERT INTO public.cidades (
    id,
    user_id,
    world_id,
    nome_cidade,
    nivel_cidade,
    created_at,
    perfil_cidade,
    tipo_entidade,
    origem_cidade
)
VALUES
(1,  NULL, 1, 'Cidade Real',              5, '2026-07-29 19:57:37.665484+00', 'real',           'reino', 'reino'),

(4,  NULL, 1, 'Porto da Âmbar',           1, '2026-07-31 11:48:31.129186+00', 'mercantil',      'npc',   'npc'),
(5,  NULL, 1, 'Vila das Moedas',          1, '2026-07-31 11:48:31.129186+00', 'mercantil',      'npc',   'npc'),
(6,  NULL, 1, 'Entre Rios',               1, '2026-07-31 11:48:31.129186+00', 'mercantil',      'npc',   'npc'),
(7,  NULL, 1, 'Porto do Corvo Branco',    1, '2026-07-31 11:48:31.129186+00', 'mercantil',      'npc',   'npc'),
(8,  NULL, 1, 'Costa Dourada',            1, '2026-07-31 11:48:31.129186+00', 'mercantil',      'npc',   'npc'),

(9,  NULL, 1, 'Bosque dos Anciões',       1, '2026-07-31 11:48:31.129186+00', 'pacificadora',   'npc',   'npc'),
(10, NULL, 1, 'Vale da Névoa',            1, '2026-07-31 11:48:31.129186+00', 'pacificadora',   'npc',   'npc'),
(11, NULL, 1, 'Refúgio das Araucárias',   1, '2026-07-31 11:48:31.129186+00', 'pacificadora',   'npc',   'npc'),
(12, NULL, 1, 'Colina da Aurora',         1, '2026-07-31 11:48:31.129186+00', 'pacificadora',   'npc',   'npc'),
(13, NULL, 1, 'Pedra Serena',             1, '2026-07-31 11:48:31.129186+00', 'pacificadora',   'npc',   'npc'),

(14, NULL, 1, 'Presas de Ferro',          1, '2026-07-31 11:48:31.129186+00', 'conquistadora',  'npc',   'npc'),
(15, NULL, 1, 'Garganta do Lobo',         1, '2026-07-31 11:48:31.129186+00', 'conquistadora',  'npc',   'npc'),
(16, NULL, 1, 'Punho de Pedra',           1, '2026-07-31 11:48:31.129186+00', 'conquistadora',  'npc',   'npc'),
(17, NULL, 1, 'Lança Partida',            1, '2026-07-31 11:48:31.129186+00', 'conquistadora',  'npc',   'npc'),
(18, NULL, 1, 'Cinzas do Sul',            1, '2026-07-31 11:48:31.129186+00', 'conquistadora',  'npc',   'npc');