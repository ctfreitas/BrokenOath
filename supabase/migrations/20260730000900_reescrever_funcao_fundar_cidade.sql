CREATE OR REPLACE FUNCTION public.fundar_cidade(
    p_world_id bigint,
    p_nome_governante text,
    p_nome_cidade text,
    p_perfil_cidade text
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id uuid;

    v_cidade_id bigint;
    v_cidade_reino_id bigint;

    v_limite integer;
    v_jogadores integer;

    v_local_id bigint;
    v_mapa_id bigint;
BEGIN
    -- =====================================================
    -- Usuário autenticado
    -- =====================================================

    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'USUARIO_NAO_AUTENTICADO';
    END IF;


    -- =====================================================
    -- Normalização dos parâmetros
    -- =====================================================

    p_nome_governante :=
        trim(regexp_replace(p_nome_governante, '\s+', ' ', 'g'));

    p_nome_cidade :=
        trim(regexp_replace(p_nome_cidade, '\s+', ' ', 'g'));

    p_perfil_cidade :=
        lower(trim(p_perfil_cidade));


    -- =====================================================
    -- Validação dos nomes
    -- =====================================================

    IF
        length(p_nome_governante) < 3
        OR length(p_nome_cidade) < 3
        OR length(p_nome_governante) > 50
        OR length(p_nome_cidade) > 50
    THEN
        RAISE EXCEPTION 'NOME_INVALIDO';
    END IF;


    -- =====================================================
    -- Validação do perfil
    -- =====================================================

    IF p_perfil_cidade NOT IN (
        'mercantil',
        'conquistadora',
        'pacificadora'
    ) THEN
        RAISE EXCEPTION 'PERFIL_INVALIDO';
    END IF;


    -- =====================================================
    -- Busca e bloqueia o mundo durante a fundação
    -- =====================================================

    SELECT
        limite_jogadores,
        jogadores_atuais
    INTO
        v_limite,
        v_jogadores
    FROM public.worlds
    WHERE id = p_world_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'MUNDO_NAO_ENCONTRADO';
    END IF;

    IF COALESCE(v_jogadores, 0) >= v_limite THEN
        RAISE EXCEPTION 'MUNDO_CHEIO';
    END IF;


    -- =====================================================
    -- Verifica se o jogador já possui cidade no mundo
    -- =====================================================

    IF EXISTS (
        SELECT 1
        FROM public.cidades
        WHERE world_id = p_world_id
          AND user_id = v_user_id
          AND tipo_entidade = 'jogador'
    ) THEN
        RAISE EXCEPTION 'USUARIO_JA_POSSUI_CIDADE';
    END IF;


    -- =====================================================
    -- Verifica nome de governante duplicado
    -- =====================================================

    IF EXISTS (
        SELECT 1
        FROM public.cidade_governanca cg
        INNER JOIN public.cidades c
            ON c.id = cg.cidade_id
        WHERE c.world_id = p_world_id
          AND cg.ativo = true
          AND lower(trim(cg.nome_governante)) =
              lower(p_nome_governante)
    ) THEN
        RAISE EXCEPTION 'GOVERNANTE_JA_EXISTE';
    END IF;


    -- =====================================================
    -- Verifica nome de cidade duplicado
    -- =====================================================

    IF EXISTS (
        SELECT 1
        FROM public.cidades
        WHERE world_id = p_world_id
          AND lower(trim(nome_cidade)) =
              lower(p_nome_cidade)
    ) THEN
        RAISE EXCEPTION 'CIDADE_JA_EXISTE';
    END IF;


    -- =====================================================
    -- Localiza a Cidade Real do mundo
    -- =====================================================

    SELECT c.id
    INTO v_cidade_reino_id
    FROM public.cidades c
    WHERE c.world_id = p_world_id
      AND c.origem_cidade = 'reino'
      AND c.tipo_entidade = 'reino'
    ORDER BY c.id
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'CIDADE_REAL_NAO_ENCONTRADA';
    END IF;


    -- =====================================================
    -- Reserva um ponto de fundação do perfil escolhido
    -- =====================================================

    SELECT
        lm.id,
        lm.mapa_id
    INTO
        v_local_id,
        v_mapa_id
    FROM public.locais_mapa lm
    INNER JOIN public.mapa_coordenadas mc
        ON mc.id = lm.mapa_id
    INNER JOIN public.regioes_fundacao rf
        ON rf.id = lm.regiao_id
    WHERE mc.world_id = p_world_id
      AND rf.world_id = p_world_id
      AND rf.ativo = true
      AND rf.perfil_padrao = p_perfil_cidade
      AND lm.tipo_local = 'fundacao'
      AND lm.cidade_id IS NULL
    ORDER BY
        rf.ordem,
        lm.ordem,
        lm.id
    LIMIT 1
    FOR UPDATE OF lm;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'SEM_LOCAL_DISPONIVEL_PERFIL';
    END IF;

    IF v_mapa_id IS NULL THEN
        RAISE EXCEPTION 'LOCAL_SEM_COORDENADA';
    END IF;


    -- =====================================================
    -- Cria a cidade
    -- =====================================================

    INSERT INTO public.cidades (
        user_id,
        world_id,
        nome_cidade,
        nivel_cidade,
        perfil_cidade,
        origem_cidade,
        tipo_entidade
    )
    VALUES (
        v_user_id,
        p_world_id,
        p_nome_cidade,
        1,
        p_perfil_cidade,
        'fundada',
        'jogador'
    )
    RETURNING id INTO v_cidade_id;


    -- =====================================================
    -- Cria a governança inicial
    -- =====================================================

    INSERT INTO public.cidade_governanca (
        cidade_id,
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
        'jogador',
        v_user_id,
        p_nome_governante,
        'Barão',
        1,
        now(),
        true
    );


    -- =====================================================
    -- Subordina a nova cidade ao Reino
    -- =====================================================

    INSERT INTO public.cidade_subordinacao (
        cidade_id,
        tipo_suserano,
        suserano_user_id,
        suserano_cidade_id,
        inicio_subordinacao,
        motivo,
        ativo
    )
    VALUES (
        v_cidade_id,
        'reino',
        NULL,
        v_cidade_reino_id,
        now(),
        'Fundação da cidade no Reino',
        true
    );


    -- =====================================================
    -- Ocupa o ponto de fundação
    -- =====================================================

    UPDATE public.locais_mapa
    SET cidade_id = v_cidade_id
    WHERE id = v_local_id;


    -- =====================================================
    -- Atualiza a quantidade de jogadores
    -- =====================================================

    UPDATE public.worlds
    SET jogadores_atuais = COALESCE(jogadores_atuais, 0) + 1
    WHERE id = p_world_id;


    -- =====================================================
    -- Retorna a cidade criada
    -- =====================================================

    RETURN v_cidade_id;
END;
$$;