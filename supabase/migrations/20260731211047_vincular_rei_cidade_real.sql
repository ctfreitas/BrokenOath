BEGIN;

DO $$
DECLARE
    v_cidade_real_id bigint;
    v_personagem_rei_id bigint;
BEGIN
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

    SELECT id
    INTO v_personagem_rei_id
    FROM public.personagens
    WHERE nome = 'Aldren Valemor'
    LIMIT 1;

    IF v_personagem_rei_id IS NULL THEN
        RAISE EXCEPTION 'PERSONAGEM_REI_NAO_ENCONTRADO';
    END IF;

    UPDATE public.cidade_governanca
    SET
        personagem_id = v_personagem_rei_id,
        tipo_governante = 'npc',
        governante_user_id = NULL,
        nome_governante = 'Aldren Valemor',
        titulo_governante = 'Rei',
        nivel_governante = 7
    WHERE cidade_id = v_cidade_real_id
      AND ativo = true;

    IF NOT FOUND THEN
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
            v_cidade_real_id,
            v_personagem_rei_id,
            'npc',
            NULL,
            'Aldren Valemor',
            'Rei',
            7,
            now(),
            true
        );
    END IF;
END;
$$;

COMMIT;