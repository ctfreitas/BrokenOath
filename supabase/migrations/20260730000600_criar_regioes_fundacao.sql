-- ===========================================================
-- Criação da tabela de regiões de fundação
-- ===========================================================

CREATE TABLE public.regioes_fundacao (
    id BIGSERIAL PRIMARY KEY,

    world_id BIGINT NOT NULL
        REFERENCES public.worlds(id)
        ON DELETE CASCADE,

    nome VARCHAR(50) NOT NULL,

    perfil_padrao VARCHAR(30),

    descricao TEXT,

    ordem SMALLINT NOT NULL DEFAULT 1,

    ativo BOOLEAN NOT NULL DEFAULT TRUE,

    criado_em TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    UNIQUE (world_id, nome)
);

COMMENT ON TABLE public.regioes_fundacao IS
'Regiões estratégicas utilizadas para fundação de cidades.';

COMMENT ON COLUMN public.regioes_fundacao.perfil_padrao IS
'Perfil de cidade associado à região (mercantil, conquistadora, pacificadora).';


-- ===========================================================
-- Adiciona a referência da região em locais_mapa
-- ===========================================================

ALTER TABLE public.locais_mapa
ADD COLUMN regiao_id BIGINT;

ALTER TABLE public.locais_mapa
ADD CONSTRAINT fk_locais_mapa_regiao
FOREIGN KEY (regiao_id)
REFERENCES public.regioes_fundacao(id);