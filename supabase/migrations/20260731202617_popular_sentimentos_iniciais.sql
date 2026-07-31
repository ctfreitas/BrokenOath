BEGIN;

DO $$
DECLARE
    v_tipo_reino_id bigint;
    v_tipo_personagem_id bigint;
    v_cidade_real_id bigint;
    v_entidade_reino_id bigint;
BEGIN
    -- =====================================================
    -- Localiza os tipos de entidade
    -- =====================================================

    SELECT id
    INTO v_tipo_reino_id
    FROM public.entidade_tipos
    WHERE lower(trim(nome)) = 'reino'
    LIMIT 1;

    IF v_tipo_reino_id IS NULL THEN
        RAISE EXCEPTION 'TIPO_ENTIDADE_REINO_NAO_ENCONTRADO';
    END IF;

    SELECT id
    INTO v_tipo_personagem_id
    FROM public.entidade_tipos
    WHERE lower(trim(nome)) = 'personagem'
    LIMIT 1;

    IF v_tipo_personagem_id IS NULL THEN
        RAISE EXCEPTION 'TIPO_ENTIDADE_PERSONAGEM_NAO_ENCONTRADO';
    END IF;


    -- =====================================================
    -- Localiza a Cidade Real
    -- =====================================================

    SELECT id
    INTO v_cidade_real_id
    FROM public.cidades
    WHERE tipo_entidade = 'reino'
      AND origem_cidade = 'reino'
    ORDER BY id
    LIMIT 1;

    IF v_cidade_real_id IS NULL THEN
        RAISE EXCEPTION 'CIDADE_REAL_NAO_ENCONTRADA';
    END IF;


    -- =====================================================
    -- Cria ou recupera a entidade institucional do Reino
    -- =====================================================

    SELECT id
    INTO v_entidade_reino_id
    FROM public.entidades
    WHERE entidade_tipo_id = v_tipo_reino_id
      AND referencia_bigint = v_cidade_real_id
    LIMIT 1;

    IF v_entidade_reino_id IS NULL THEN
        INSERT INTO public.entidades (
            entidade_tipo_id,
            referencia_uuid,
            referencia_bigint
        )
        VALUES (
            v_tipo_reino_id,
            NULL,
            v_cidade_real_id
        )
        RETURNING id INTO v_entidade_reino_id;
    END IF;


    -- =====================================================
    -- Cria todos os sentimentos neutros
    --
    -- Inclui:
    -- personagem → personagem
    -- personagem → Reino
    -- Reino → personagem
    --
    -- Não cria sentimento da entidade por ela mesma.
    -- =====================================================

    INSERT INTO public.sentimentos (
        origem_entidade_id,
        destino_entidade_id,
        sentimento_tipo_id,
        valor
    )
    SELECT
        origem.id,
        destino.id,
        sentimento_tipo.id,
        50
    FROM (
        SELECT e.id
        FROM public.entidades e
        WHERE e.entidade_tipo_id = v_tipo_personagem_id

        UNION ALL

        SELECT v_entidade_reino_id
    ) AS origem
    CROSS JOIN (
        SELECT e.id
        FROM public.entidades e
        WHERE e.entidade_tipo_id = v_tipo_personagem_id

        UNION ALL

        SELECT v_entidade_reino_id
    ) AS destino
    CROSS JOIN public.sentimento_tipos sentimento_tipo
    WHERE origem.id <> destino.id
    ON CONFLICT (
        origem_entidade_id,
        destino_entidade_id,
        sentimento_tipo_id
    )
    DO NOTHING;


    -- =====================================================
    -- Membros do mesmo clã
    --
    -- Lealdade  = 80
    -- Confiança = 75
    -- Respeito  = 80
    -- Empatia   = 70
    -- =====================================================

    UPDATE public.sentimentos s
    SET
        valor = CASE lower(trim(st.nome))
            WHEN 'lealdade'  THEN 80
            WHEN 'confiança' THEN 75
            WHEN 'respeito'  THEN 80
            WHEN 'empatia'   THEN 70
            ELSE s.valor
        END,
        updated_at = now()
    FROM
        public.sentimento_tipos st,
        public.entidades origem_entidade,
        public.personagens origem_personagem,
        public.entidades destino_entidade,
        public.personagens destino_personagem
    WHERE st.id = s.sentimento_tipo_id

      AND origem_entidade.id = s.origem_entidade_id
      AND origem_entidade.entidade_tipo_id = v_tipo_personagem_id
      AND origem_personagem.id =
          origem_entidade.referencia_bigint

      AND destino_entidade.id = s.destino_entidade_id
      AND destino_entidade.entidade_tipo_id = v_tipo_personagem_id
      AND destino_personagem.id =
          destino_entidade.referencia_bigint

      AND origem_personagem.id <> destino_personagem.id
      AND origem_personagem.cla_id IS NOT NULL
      AND origem_personagem.cla_id = destino_personagem.cla_id

      AND lower(trim(st.nome)) IN (
          'lealdade',
          'confiança',
          'respeito',
          'empatia'
      );


    -- =====================================================
    -- Rivalidade entre as duas ligas mercantis
    --
    -- Confiança  = 40
    -- Respeito   = 60
    -- Rivalidade = 60
    -- =====================================================

    UPDATE public.sentimentos s
    SET
        valor = CASE lower(trim(st.nome))
            WHEN 'confiança'  THEN 40
            WHEN 'respeito'   THEN 60
            WHEN 'rivalidade' THEN 60
            ELSE s.valor
        END,
        updated_at = now()
    FROM
        public.sentimento_tipos st,
        public.entidades origem_entidade,
        public.personagens origem_personagem,
        public.clas origem_cla,
        public.entidades destino_entidade,
        public.personagens destino_personagem,
        public.clas destino_cla
    WHERE st.id = s.sentimento_tipo_id

      AND origem_entidade.id = s.origem_entidade_id
      AND origem_entidade.entidade_tipo_id = v_tipo_personagem_id
      AND origem_personagem.id =
          origem_entidade.referencia_bigint
      AND origem_cla.id = origem_personagem.cla_id

      AND destino_entidade.id = s.destino_entidade_id
      AND destino_entidade.entidade_tipo_id = v_tipo_personagem_id
      AND destino_personagem.id =
          destino_entidade.referencia_bigint
      AND destino_cla.id = destino_personagem.cla_id

      AND (
          (
              origem_cla.nome = 'Liga do Âmbar'
              AND destino_cla.nome = 'Liga das Moedas'
          )
          OR
          (
              origem_cla.nome = 'Liga das Moedas'
              AND destino_cla.nome = 'Liga do Âmbar'
          )
      )

      AND lower(trim(st.nome)) IN (
          'confiança',
          'respeito',
          'rivalidade'
      );


    -- =====================================================
    -- Conquistadores que não pertencem ao mesmo clã
    --
    -- Confiança  = 25
    -- Respeito   = 65
    -- Inveja     = 70
    -- Rivalidade = 80
    -- =====================================================

    UPDATE public.sentimentos s
    SET
        valor = CASE lower(trim(st.nome))
            WHEN 'confiança'  THEN 25
            WHEN 'respeito'   THEN 65
            WHEN 'inveja'     THEN 70
            WHEN 'rivalidade' THEN 80
            ELSE s.valor
        END,
        updated_at = now()
    FROM
        public.sentimento_tipos st,
        public.entidades origem_entidade,
        public.personagens origem_personagem,
        public.cidades origem_cidade,
        public.entidades destino_entidade,
        public.personagens destino_personagem,
        public.cidades destino_cidade
    WHERE st.id = s.sentimento_tipo_id

      AND origem_entidade.id = s.origem_entidade_id
      AND origem_entidade.entidade_tipo_id = v_tipo_personagem_id
      AND origem_personagem.id =
          origem_entidade.referencia_bigint
      AND origem_cidade.id =
          origem_personagem.cidade_origem_id

      AND destino_entidade.id = s.destino_entidade_id
      AND destino_entidade.entidade_tipo_id = v_tipo_personagem_id
      AND destino_personagem.id =
          destino_entidade.referencia_bigint
      AND destino_cidade.id =
          destino_personagem.cidade_origem_id

      AND origem_personagem.id <> destino_personagem.id
      AND origem_cidade.perfil_cidade = 'conquistadora'
      AND destino_cidade.perfil_cidade = 'conquistadora'

      -- Preserva a relação positiva entre membros
      -- do mesmo clã, como o Clã do Martelo.
      AND NOT (
          origem_personagem.cla_id IS NOT NULL
          AND origem_personagem.cla_id =
              destino_personagem.cla_id
      )

      AND lower(trim(st.nome)) IN (
          'confiança',
          'respeito',
          'inveja',
          'rivalidade'
      );


    -- =====================================================
    -- Governadores NPC favoráveis ao Reino
    --
    -- Somente a lealdade é alterada.
    -- Os demais sentimentos permanecem neutros.
    -- =====================================================

    UPDATE public.sentimentos s
    SET
        valor = 85,
        updated_at = now()
    FROM
        public.sentimento_tipos st,
        public.entidades origem_entidade,
        public.personagens origem_personagem
    WHERE st.id = s.sentimento_tipo_id

      AND origem_entidade.id = s.origem_entidade_id
      AND origem_entidade.entidade_tipo_id = v_tipo_personagem_id
      AND origem_personagem.id =
          origem_entidade.referencia_bigint

      AND origem_personagem.user_id IS NULL
      AND s.destino_entidade_id = v_entidade_reino_id
      AND lower(trim(st.nome)) = 'lealdade';

END;
$$;

COMMIT;