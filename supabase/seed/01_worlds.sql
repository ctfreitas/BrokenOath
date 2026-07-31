-- =====================================================
-- BROKEN OATH
-- Seed Oficial - Worlds
-- Arquivo: 01_worlds.sql
-- =====================================================

INSERT INTO public.worlds (
    id,
    nome,
    limite_jogadores,
    jogadores_atuais,
    created_at,
    largura_mapa,
    altura_mapa,
    largura_imagem,
    altura_imagem,
    imagem_mapa,
    multiplicador
)
VALUES (
    1,
    'Terras Antigas',
    15,
    0,
    '2026-07-28 20:29:13.094048+00',
    600,
    600,
    16384,
    16384,
    'assets/mapa/mundo_alfa.png',
    8.00
);