-- =====================================================
-- BROKEN OATH
-- Seed Oficial - Regiões de Fundação
-- Arquivo: 03_regioes_fundacao.sql
-- =====================================================

INSERT INTO public.regioes_fundacao (
    id,
    world_id,
    nome,
    perfil_padrao,
    descricao,
    ordem,
    ativo,
    criado_em
)
VALUES
(
    1,
    1,
    'Mercantil',
    'mercantil',
    'Região voltada ao comércio e desenvolvimento econômico.',
    1,
    TRUE,
    '2026-07-30 15:53:07.517882+00'
),
(
    2,
    1,
    'Conquistadora',
    'conquistadora',
    'Região voltada à expansão militar.',
    2,
    TRUE,
    '2026-07-30 15:53:07.517882+00'
),
(
    3,
    1,
    'Pacificadora',
    'pacificadora',
    'Região voltada ao crescimento equilibrado e diplomático.',
    3,
    TRUE,
    '2026-07-30 15:53:07.517882+00'
);