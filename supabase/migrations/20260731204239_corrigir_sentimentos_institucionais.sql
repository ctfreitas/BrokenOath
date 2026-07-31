BEGIN;

-- Remove relações inválidas em que o Reino aparece como origem.
DELETE FROM public.sentimentos s
USING public.entidades e,
      public.entidade_tipos et
WHERE s.origem_entidade_id = e.id
  AND e.entidade_tipo_id = et.id
  AND lower(trim(et.nome)) = 'reino';


CREATE OR REPLACE FUNCTION public.inicializar_sentimentos_entidade(
    p_entidade_id bigint
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO public
AS $function$
DECLARE
    v_tipo_origem text;
BEGIN
    -- =====================================================
    -- Valida se a entidade existe e identifica seu tipo
    -- =====================================================

    SELECT lower(trim(et.nome))
    INTO v_tipo_origem
    FROM public.entidades e
    INNER JOIN public.entidade_tipos et
        ON et.id = e.entidade_tipo_id
    WHERE e.id = p_entidade_id
    LIMIT 1;

    IF v_tipo_origem IS NULL THEN
        RAISE EXCEPTION 'ENTIDADE_NAO_ENCONTRADA';
    END IF;


    -- =====================================================
    -- Apenas personagens podem originar sentimentos
    -- =====================================================

    IF v_tipo_origem <> 'personagem' THEN
        RAISE EXCEPTION 'ENTIDADE_NAO_PODE_ORIGINAR_SENTIMENTOS';
    END IF;


    -- =====================================================
    -- Novo personagem -> demais personagens e Reino
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
    -- Personagens existentes -> novo personagem
    --
    -- O Reino não aparece como origem.
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
      AND lower(trim(origem_tipo.nome)) = 'personagem'
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
    'Cria sentimentos neutros de um personagem para outros personagens e para o Reino, além dos sentimentos dos personagens existentes para o novo personagem. O Reino nunca é origem de sentimentos.';

COMMIT;