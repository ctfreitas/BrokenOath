BEGIN;

CREATE OR REPLACE FUNCTION public.inicializar_sentimentos_entidade(
    p_entidade_id bigint
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $function$
BEGIN
    -- =====================================================
    -- Valida se a entidade existe
    -- =====================================================

    IF NOT EXISTS (
        SELECT 1
        FROM public.entidades
        WHERE id = p_entidade_id
    ) THEN
        RAISE EXCEPTION 'ENTIDADE_NAO_ENCONTRADA';
    END IF;


    -- =====================================================
    -- Valida se a entidade participa da rede de sentimentos
    --
    -- Apenas personagens e o Reino são suportados.
    -- =====================================================

    IF NOT EXISTS (
        SELECT 1
        FROM public.entidades e
        INNER JOIN public.entidade_tipos et
            ON et.id = e.entidade_tipo_id
        WHERE e.id = p_entidade_id
          AND lower(trim(et.nome)) IN (
              'personagem',
              'reino'
          )
    ) THEN
        RAISE EXCEPTION 'ENTIDADE_NAO_SUPORTA_SENTIMENTOS';
    END IF;


    -- =====================================================
    -- Nova entidade -> demais entidades sociais
    -- =====================================================

    INSERT INTO public.sentimentos (
        origem_entidade_id,
        destino_entidade_id,
        sentimento_tipo_id,
        valor
    )
    SELECT
        p_entidade_id,
        destino.id,
        st.id,
        50
    FROM public.entidades destino
    INNER JOIN public.entidade_tipos destino_tipo
        ON destino_tipo.id = destino.entidade_tipo_id
    CROSS JOIN public.sentimento_tipos st
    WHERE destino.id <> p_entidade_id
      AND lower(trim(destino_tipo.nome)) IN (
          'personagem',
          'reino'
      )
    ON CONFLICT (
        origem_entidade_id,
        destino_entidade_id,
        sentimento_tipo_id
    )
    DO NOTHING;


    -- =====================================================
    -- Demais entidades sociais -> nova entidade
    -- =====================================================

    INSERT INTO public.sentimentos (
        origem_entidade_id,
        destino_entidade_id,
        sentimento_tipo_id,
        valor
    )
    SELECT
        origem.id,
        p_entidade_id,
        st.id,
        50
    FROM public.entidades origem
    INNER JOIN public.entidade_tipos origem_tipo
        ON origem_tipo.id = origem.entidade_tipo_id
    CROSS JOIN public.sentimento_tipos st
    WHERE origem.id <> p_entidade_id
      AND lower(trim(origem_tipo.nome)) IN (
          'personagem',
          'reino'
      )
    ON CONFLICT (
        origem_entidade_id,
        destino_entidade_id,
        sentimento_tipo_id
    )
    DO NOTHING;
END;
$function$;

COMMENT ON FUNCTION
    public.inicializar_sentimentos_entidade(bigint)
IS
    'Cria sentimentos neutros nos dois sentidos entre uma entidade social nova e todos os personagens e Reino existentes.';

COMMIT;