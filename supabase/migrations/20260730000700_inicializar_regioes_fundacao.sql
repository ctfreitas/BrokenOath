INSERT INTO public.regioes_fundacao (
    world_id,
    nome,
    perfil_padrao,
    descricao,
    ordem
)
SELECT
    w.id,
    r.nome,
    r.perfil_padrao,
    r.descricao,
    r.ordem
FROM public.worlds w
CROSS JOIN (
    VALUES
        (
            'Mercantil',
            'mercantil',
            'Região voltada ao comércio e desenvolvimento econômico.',
            1
        ),
        (
            'Conquistadora',
            'conquistadora',
            'Região voltada à expansão militar.',
            2
        ),
        (
            'Pacificadora',
            'pacificadora',
            'Região voltada ao crescimento equilibrado e diplomático.',
            3
        )
) AS r(nome, perfil_padrao, descricao, ordem)
ON CONFLICT (world_id, nome) DO NOTHING;