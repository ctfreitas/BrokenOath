-- =====================================================
-- BROKEN OATH
-- Seed Oficial - Governança
-- Arquivo: 06_cidade_governanca.sql
-- =====================================================

INSERT INTO public.cidade_governanca (
    id,
    cidade_id,
    tipo_governante,
    governante_user_id,
    nome_governante,
    titulo_governante,
    nivel_governanca,
    lealdade,
    autonomia,
    inicio_governo,
    fim_governo,
    ativo
)
VALUES (
    1,
    1,
    'npc',
    NULL,
    'Rei',
    'Rei',
    0,
    50,
    50,
    '2026-07-30 12:53:42.804118+00',
    NULL,
    TRUE
);