BEGIN;

-- =====================================================
-- Permite vincular a governança ao personagem permanente
-- =====================================================

ALTER TABLE public.cidade_governanca
ADD COLUMN IF NOT EXISTS personagem_id bigint;

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conname = 'cidade_governanca_personagem_fk'
    ) THEN
        ALTER TABLE public.cidade_governanca
        ADD CONSTRAINT cidade_governanca_personagem_fk
        FOREIGN KEY (personagem_id)
        REFERENCES public.personagens(id);
    END IF;
END;
$$;

CREATE INDEX IF NOT EXISTS idx_cidade_governanca_personagem
    ON public.cidade_governanca(personagem_id);


-- =====================================================
-- Cria e vincula os 15 governadores NPC
-- =====================================================

DO $$
DECLARE
    r record;

    v_cidade_id bigint;
    v_personagem_id bigint;
    v_entidade_id bigint;

    v_tipo_personagem_id bigint;
    v_titulo_barao_id bigint;
BEGIN
    -- Tipo universal de personagem
    SELECT id
    INTO v_tipo_personagem_id
    FROM public.entidade_tipos
    WHERE nome = 'personagem'
    LIMIT 1;

    IF v_tipo_personagem_id IS NULL THEN
        RAISE EXCEPTION 'TIPO_ENTIDADE_PERSONAGEM_NAO_ENCONTRADO';
    END IF;

    -- Título inicial
    SELECT id
    INTO v_titulo_barao_id
    FROM public.titulo_tipos
    WHERE nome = 'Barão'
    LIMIT 1;

    IF v_titulo_barao_id IS NULL THEN
        RAISE EXCEPTION 'TITULO_BARAO_NAO_ENCONTRADO';
    END IF;

    FOR r IN
        SELECT *
        FROM (
            VALUES
                ('Porto da Âmbar',          'Alaric Ventor'),
                ('Vila das Moedas',         'Hector Draven'),
                ('Entre Rios',              'Lucien Mercier'),
                ('Porto do Corvo Branco',   'Otto Reinhardt'),
                ('Costa Dourada',           'Cedric Valmont'),

                ('Bosque dos Anciões',      'Eamon Sylvar'),
                ('Vale da Névoa',           'Rowan Eldric'),
                ('Refúgio das Araucárias',  'Caelan Thorn'),
                ('Colina da Aurora',        'Armand Solis'),
                ('Pedra Serena',            'Gareth Aster'),

                ('Presas de Ferro',         'Ragnar Bjornsson'),
                ('Garganta do Lobo',        'Ulric Varg'),
                ('Punho de Pedra',          'Darius Korv'),
                ('Lança Partida',           'Viktor Draegor'),
                ('Cinzas do Sul',            'Cedric Ashen')
        ) AS dados(nome_cidade, nome_personagem)
    LOOP
        -- =================================================
        -- Localiza a cidade NPC
        -- =================================================

        SELECT id
        INTO v_cidade_id
        FROM public.cidades
        WHERE nome_cidade = r.nome_cidade
          AND tipo_entidade = 'npc'
        LIMIT 1;

        IF v_cidade_id IS NULL THEN
            RAISE EXCEPTION
                'CIDADE_NPC_NAO_ENCONTRADA: %',
                r.nome_cidade;
        END IF;


        -- =================================================
        -- Cria ou recupera o personagem
        -- =================================================

        SELECT id
        INTO v_personagem_id
        FROM public.personagens
        WHERE lower(trim(nome)) =
              lower(trim(r.nome_personagem))
        LIMIT 1;

        IF v_personagem_id IS NULL THEN
            INSERT INTO public.personagens (
                user_id,
                nome,
                apelido,
                cidade_origem_id,
                coragem,
                respeito,
                honra,
                ambicao
            )
            VALUES (
                NULL,
                r.nome_personagem,
                NULL,
                v_cidade_id,
                50,
                50,
                50,
                50
            )
            RETURNING id INTO v_personagem_id;
        ELSE
            UPDATE public.personagens
            SET cidade_origem_id =
                COALESCE(cidade_origem_id, v_cidade_id)
            WHERE id = v_personagem_id;
        END IF;


        -- =================================================
        -- Cria a entidade universal do personagem
        -- =================================================

        SELECT id
        INTO v_entidade_id
        FROM public.entidades
        WHERE entidade_tipo_id = v_tipo_personagem_id
          AND referencia_bigint = v_personagem_id
        LIMIT 1;

        IF v_entidade_id IS NULL THEN
            INSERT INTO public.entidades (
                entidade_tipo_id,
                referencia_uuid,
                referencia_bigint
            )
            VALUES (
                v_tipo_personagem_id,
                NULL,
                v_personagem_id
            )
            RETURNING id INTO v_entidade_id;
        END IF;


        -- =================================================
        -- Concede o título inicial de Barão
        -- =================================================

        IF NOT EXISTS (
            SELECT 1
            FROM public.personagem_titulos
            WHERE personagem_id = v_personagem_id
              AND ativo = true
        ) THEN
            INSERT INTO public.personagem_titulos (
                personagem_id,
                titulo_tipo_id,
                data_inicio,
                ativo
            )
            VALUES (
                v_personagem_id,
                v_titulo_barao_id,
                now(),
                true
            );
        END IF;


        -- =================================================
        -- Encerra eventual governança ativa sem personagem
        -- =================================================

        UPDATE public.cidade_governanca
        SET
            fim_governo = now(),
            ativo = false
        WHERE cidade_id = v_cidade_id
          AND ativo = true
          AND personagem_id IS DISTINCT FROM v_personagem_id;


        -- =================================================
        -- Cria ou atualiza a governança da cidade
        -- =================================================

        IF EXISTS (
            SELECT 1
            FROM public.cidade_governanca
            WHERE cidade_id = v_cidade_id
              AND personagem_id = v_personagem_id
              AND ativo = true
        ) THEN
            UPDATE public.cidade_governanca
            SET
                tipo_governante = 'npc',
                governante_user_id = NULL,
                nome_governante = r.nome_personagem,
                titulo_governante = 'Barão',
                nivel_governante = 1
            WHERE cidade_id = v_cidade_id
              AND personagem_id = v_personagem_id
              AND ativo = true;
        ELSE
            INSERT INTO public.cidade_governanca (
                cidade_id,
                personagem_id,
                tipo_governante,
                governante_user_id,
                nome_governante,
                titulo_governante,
                nivel_governante,
                inicio_governo,
                ativo
            )
            VALUES (
                v_cidade_id,
                v_personagem_id,
                'npc',
                NULL,
                r.nome_personagem,
                'Barão',
                1,
                now(),
                true
            );
        END IF;
    END LOOP;
END;
$$;

COMMIT;