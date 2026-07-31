BEGIN;

DO $$
DECLARE
    v_personagem_id bigint;
    v_titulo_rei_id bigint;
    v_entidade_reino_id bigint;
    v_cargo_tipo_id bigint;
BEGIN

    -- =====================================================
    -- Entidade institucional do Reino
    -- =====================================================

    SELECT e.id
    INTO v_entidade_reino_id
    FROM public.entidades e
    JOIN public.entidade_tipos et
      ON et.id = e.entidade_tipo_id
    WHERE lower(trim(et.nome)) = 'reino'
    LIMIT 1;

    IF v_entidade_reino_id IS NULL THEN
        RAISE EXCEPTION 'ENTIDADE_REINO_NAO_ENCONTRADA';
    END IF;


    -- =====================================================
    -- Título Rei
    -- =====================================================

    SELECT id
    INTO v_titulo_rei_id
    FROM public.titulo_tipos
    WHERE nome = 'Rei'
    LIMIT 1;

    IF v_titulo_rei_id IS NULL THEN
        RAISE EXCEPTION 'TITULO_REI_NAO_ENCONTRADO';
    END IF;


    -- =====================================================
    -- Rei
    -- =====================================================

    SELECT id
    INTO v_personagem_id
    FROM public.personagens
    WHERE nome = 'Aldren Valemor';

    IF v_personagem_id IS NULL THEN
        RAISE EXCEPTION 'PERSONAGEM_ALDREN_NAO_ENCONTRADO';
    END IF;

    IF NOT EXISTS (
        SELECT 1
        FROM public.personagem_titulos
        WHERE personagem_id = v_personagem_id
          AND titulo_tipo_id = v_titulo_rei_id
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
            v_titulo_rei_id,
            now(),
            true
        );

    END IF;


    -- =====================================================
    -- Conselheiros
    -- =====================================================

    FOR v_personagem_id, v_cargo_tipo_id IN

        SELECT
            p.id,
            ct.id
        FROM (
            VALUES
                ('Edmund Ravencroft','Chanceler'),
                ('Garrick Thorne','Marechal'),
                ('Odran Velmont','Tesoureiro'),
                ('Seraphine Vael','Diplomata'),
                ('Malrec Voss','Mestre dos Espiões')
        ) dados(nome_personagem,nome_cargo)

        JOIN public.personagens p
            ON p.nome = dados.nome_personagem

        JOIN public.cargo_tipos ct
            ON ct.nome = dados.nome_cargo

    LOOP

        IF NOT EXISTS (

            SELECT 1
            FROM public.personagem_cargos

            WHERE personagem_id = v_personagem_id
              AND cargo_tipo_id = v_cargo_tipo_id
              AND entidade_id = v_entidade_reino_id
              AND ativo = true

        ) THEN

            INSERT INTO public.personagem_cargos (

                personagem_id,
                cargo_tipo_id,
                entidade_id,
                data_inicio,
                ativo

            )
            VALUES (

                v_personagem_id,
                v_cargo_tipo_id,
                v_entidade_reino_id,
                now(),
                true

            );

        END IF;

    END LOOP;

END;
$$;

COMMIT;