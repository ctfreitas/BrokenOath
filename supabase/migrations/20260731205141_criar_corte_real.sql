BEGIN;

DO $$
DECLARE
    r record;

    v_cidade_real_id bigint;
    v_tipo_personagem_id bigint;

    v_personagem_id bigint;
    v_entidade_personagem_id bigint;
BEGIN
    -- Localiza a Cidade Real
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

    -- Localiza o tipo universal de personagem
    SELECT id
    INTO v_tipo_personagem_id
    FROM public.entidade_tipos
    WHERE lower(trim(nome)) = 'personagem'
    LIMIT 1;

    IF v_tipo_personagem_id IS NULL THEN
        RAISE EXCEPTION 'TIPO_ENTIDADE_PERSONAGEM_NAO_ENCONTRADO';
    END IF;

    -- Cria os seis personagens da Corte Real
    FOR r IN
        SELECT nome_personagem
        FROM (
            VALUES
                ('Aldren Valemor'),
                ('Edmund Ravencroft'),
                ('Garrick Thorne'),
                ('Odran Velmont'),
                ('Seraphine Vael'),
                ('Malrec Voss')
        ) AS corte(nome_personagem)
    LOOP
        -- Cria ou recupera o personagem
        SELECT id
        INTO v_personagem_id
        FROM public.personagens
        WHERE lower(trim(nome)) = lower(trim(r.nome_personagem))
        LIMIT 1;

        IF v_personagem_id IS NULL THEN
            INSERT INTO public.personagens (
                nome,
                apelido,
                cidade_origem_id,
                coragem,
                respeito,
                honra,
                ambicao,
                user_id,
                cla_id
            )
            VALUES (
                r.nome_personagem,
                NULL,
                v_cidade_real_id,
                50,
                50,
                50,
                50,
                NULL,
                NULL
            )
            RETURNING id INTO v_personagem_id;
        ELSE
            UPDATE public.personagens
            SET cidade_origem_id = COALESCE(
                cidade_origem_id,
                v_cidade_real_id
            )
            WHERE id = v_personagem_id;
        END IF;

        -- Cria ou recupera a entidade universal
        SELECT id
        INTO v_entidade_personagem_id
        FROM public.entidades
        WHERE entidade_tipo_id = v_tipo_personagem_id
          AND referencia_bigint = v_personagem_id
        LIMIT 1;

        IF v_entidade_personagem_id IS NULL THEN
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
            RETURNING id INTO v_entidade_personagem_id;
        END IF;

        -- Integra o personagem à rede social
        PERFORM public.inicializar_sentimentos_entidade(
            v_entidade_personagem_id
        );
    END LOOP;
END;
$$;

COMMIT;