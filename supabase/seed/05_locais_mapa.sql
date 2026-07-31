-- =====================================================
-- BROKEN OATH
-- Seed Oficial - Locais do Mapa
-- Arquivo: 04_locais_mapa.sql
-- =====================================================

INSERT INTO public.locais_mapa (
    id, cidade_id, criado_em, regiao, ordem, tipo_local, mapa_id, regiao_id, codigo_local, local_vinculado_id, categoria
)
VALUES
(
    18, 1, '2026-07-29 22:31:28.118279+00', 'centro', 1, 'especial', 5, NULL, 'REINO_01', NULL, 'real'
),
(
    25, 4, '2026-07-30 19:40:28.670153+00', 'noroeste', 1, 'especial', 28, NULL, 'MERC_01', NULL, 'mercantil'
),
(
    26, 5, '2026-07-30 19:40:28.670153+00', 'oeste', 2, 'especial', 9, NULL, 'MERC_02', NULL, 'mercantil'
),
(
    27, 6, '2026-07-30 19:40:28.670153+00', 'noroeste', 3, 'especial', 19, NULL, 'MERC_03', NULL, 'mercantil'
),
(
    28, 7, '2026-07-30 19:40:28.670153+00', 'sudoeste', 4, 'especial', 21, NULL, 'MERC_04', NULL, 'mercantil'
),
(
    29, 8, '2026-07-30 19:40:28.670153+00', 'sudoeste', 5, 'especial', 24, NULL, 'MERC_05', NULL, 'mercantil'
),
(
    30, 9, '2026-07-30 19:40:28.670153+00', 'nordeste', 1, 'especial', 31, NULL, 'PACI_01', NULL, 'pacificadora'
),
(
    31, 10, '2026-07-30 19:40:28.670153+00', 'nordeste', 2, 'especial', 37, NULL, 'PACI_02', NULL, 'pacificadora'
),
(
    32, 11, '2026-07-30 19:40:28.670153+00', 'sudeste', 3, 'especial', 16, NULL, 'PACI_03', NULL, 'pacificadora'
),
(
    33, 12, '2026-07-30 19:40:28.670153+00', 'sul', 4, 'especial', 32, NULL, 'PACI_04', NULL, 'pacificadora'
),
(
    34, 13, '2026-07-30 19:40:28.670153+00', 'sudeste', 5, 'especial', 18, NULL, 'PACI_05', NULL, 'pacificadora'
),
(
    35, 14, '2026-07-30 19:40:28.670153+00', 'norte', 1, 'especial', 36, NULL, 'BARB_01', NULL, 'conquistadora'
),
(
    36, 15, '2026-07-30 19:40:28.670153+00', 'sul', 2, 'especial', 22, NULL, 'BARB_02', NULL, 'conquistadora'
),
(
    37, 16, '2026-07-30 19:40:28.670153+00', 'nordeste', 3, 'especial', 15, NULL, 'BARB_03', NULL, 'conquistadora'
),
(
    38, 17, '2026-07-30 19:40:28.670153+00', 'sudeste', 4, 'especial', 11, NULL, 'BARB_04', NULL, 'conquistadora'
),
(
    39, 18, '2026-07-30 19:40:28.670153+00', 'sudeste', 5, 'especial', 17, NULL, 'BARB_05', NULL, 'conquistadora'
),
(
    40, NULL, '2026-07-30 19:40:28.670153+00', 'noroeste', 1, 'especial', 27, NULL, 'FUND_MERC_01', 25, 'mercantil'
),
(
    41, NULL, '2026-07-30 19:40:28.670153+00', 'oeste', 2, 'especial', 29, NULL, 'FUND_MERC_02', 26, 'mercantil'
),
(
    42, NULL, '2026-07-30 19:40:28.670153+00', 'oeste', 3, 'especial', 23, NULL, 'FUND_MERC_03', 27, 'mercantil'
),
(
    43, NULL, '2026-07-30 19:40:28.670153+00', 'sudoeste', 4, 'especial', 10, NULL, 'FUND_MERC_04', 28, 'mercantil'
),
(
    44, NULL, '2026-07-30 19:40:28.670153+00', 'sudoeste', 5, 'especial', 14, NULL, 'FUND_MERC_05', 29, 'mercantil'
),
(
    45, NULL, '2026-07-30 19:40:28.670153+00', 'nordeste', 1, 'especial', 25, NULL, 'FUND_PACI_01', 30, 'pacificadora'
),
(
    46, NULL, '2026-07-30 19:40:28.670153+00', 'leste', 2, 'especial', 26, NULL, 'FUND_PACI_02', 31, 'pacificadora'
),
(
    47, NULL, '2026-07-30 19:40:28.670153+00', 'sudeste', 3, 'especial', 20, NULL, 'FUND_PACI_03', 32, 'pacificadora'
),
(
    48, NULL, '2026-07-30 19:40:28.670153+00', 'sul', 4, 'especial', 8, NULL, 'FUND_PACI_04', 33, 'pacificadora'
),
(
    49, NULL, '2026-07-30 19:40:28.670153+00', 'sudeste', 5, 'especial', 33, NULL, 'FUND_PACI_05', 34, 'pacificadora'
),
(
    50, NULL, '2026-07-30 19:40:28.670153+00', 'norte', 1, 'especial', 35, NULL, 'FUND_BARB_01', 35, 'conquistadora'
),
(
    51, NULL, '2026-07-30 19:40:28.670153+00', 'sul', 2, 'especial', 30, NULL, 'FUND_BARB_02', 36, 'conquistadora'
),
(
    52, NULL, '2026-07-30 19:40:28.670153+00', 'leste', 3, 'especial', 13, NULL, 'FUND_BARB_03', 37, 'conquistadora'
),
(
    53, NULL, '2026-07-30 19:40:28.670153+00', 'sudeste', 4, 'especial', 34, NULL, 'FUND_BARB_04', 38, 'conquistadora'
),
(
    54, NULL, '2026-07-30 19:40:28.670153+00', 'sudeste', 5, 'especial', 12, NULL, 'FUND_BARB_05', 39, 'conquistadora'
);