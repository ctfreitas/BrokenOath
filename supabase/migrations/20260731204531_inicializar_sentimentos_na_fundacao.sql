BEGIN;

CREATE OR REPLACE FUNCTION public.fundar_cidade(
    p_world_id bigint,
    p_nome_governante text,
    p_nome_cidade text,
    p_perfil_cidade text
)
RETURNS bigint
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
    v_user_id uuid;

    v_cidade_id bigint;
    v_cidade_reino_id bigint;

    v_limite integer;
    v_jogadores integer;

    v_local_id bigint;
    v_mapa_id bigint;

    v_personagem_id bigint;
    v_entidade_personagem_id bigint;
    v_entidade_cidade_id bigint;

    v_tipo_personagem_id bigint;
    v_tipo_cidade_id bigint;

    v_titulo_barao_id bigint;
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
    -- Verifica nome do personagem duplicado
    -- =====================================================

    IF EXISTS (
        SELECT 1
        FROM public.personagens
        WHERE lower(trim(nome)) = lower(p_nome_governante)
          AND user_id IS DISTINCT FROM v_user_id
    ) THEN
        RAISE EXCEPTION 'GOVERNANTE_JA_EXISTE';
    END IF;


    -- =====================================================
    -- Verifica nome de cidade duplicado no mundo
    -- =====================================================

    IF EXISTS (
        SELECT 1
        FROM public.cidades
        WHERE world_id = p_world_id
          AND lower(trim(nome_cidade)) = lower(p_nome_cidade)
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
    -- Localiza os tipos universais necessários
    -- =====================================================

    SELECT id
    INTO v_tipo_personagem_id
    FROM public.entidade_tipos
    WHERE nome = 'personagem'
    LIMIT 1;

    IF v_tipo_personagem_id IS NULL THEN
        RAISE EXCEPTION 'TIPO_ENTIDADE_PERSONAGEM_NAO_ENCONTRADO';
    END IF;

    SELECT id
    INTO v_tipo_cidade_id
    FROM public.entidade_tipos
    WHERE nome = 'cidade'
    LIMIT 1;

    IF v_tipo_cidade_id IS NULL THEN
        RAISE EXCEPTION 'TIPO_ENTIDADE_CIDADE_NAO_ENCONTRADO';
    END IF;


    -- =====================================================
    -- Localiza o título inicial
    -- =====================================================

    SELECT id
    INTO v_titulo_barao_id
    FROM public.titulo_tipos
    WHERE nome = 'Barão'
    LIMIT 1;

    IF v_titulo_barao_id IS NULL THEN
        RAISE EXCEPTION 'TITULO_BARAO_NAO_ENCONTRADO';
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
    WHERE mc.world_id = p_world_id
      AND lower(trim(lm.categoria)) = p_perfil_cidade
      AND lm.tipo_local = 'especial'
      AND lm.codigo_local LIKE 'FUND_%'
      AND lm.cidade_id IS NULL
    ORDER BY
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
    -- Cria ou recupera o personagem do jogador
    -- =====================================================

    SELECT id
    INTO v_personagem_id
    FROM public.personagens
    WHERE user_id = v_user_id
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
            v_user_id,
            p_nome_governante,
            NULL,
            NULL,
            50,
            50,
            50,
            50
        )
        RETURNING id INTO v_personagem_id;
    END IF;


    -- =====================================================
    -- Cria ou recupera a entidade do personagem
    -- =====================================================

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


    -- =====================================================
    -- Inicializa os sentimentos do personagem
    -- =====================================================

    PERFORM public.inicializar_sentimentos_entidade(
        v_entidade_personagem_id
    );


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
    -- Define a cidade de origem do personagem
    -- =====================================================

    UPDATE public.personagens
    SET cidade_origem_id = COALESCE(
        cidade_origem_id,
        v_cidade_id
    )
    WHERE id = v_personagem_id;


    -- =====================================================
    -- Cria a entidade universal da cidade
    -- =====================================================

    INSERT INTO public.entidades (
        entidade_tipo_id,
        referencia_uuid,
        referencia_bigint
    )
    VALUES (
        v_tipo_cidade_id,
        NULL,
        v_cidade_id
    )
    RETURNING id INTO v_entidade_cidade_id;


    -- =====================================================
    -- Mantém a governança no modelo atualmente utilizado
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
    -- Cria o título inicial do personagem
    -- =====================================================

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
    SET jogadores_atuais =
        COALESCE(jogadores_atuais, 0) + 1
    WHERE id = p_world_id;


    RETURN v_cidade_id;
END;
$function$;

COMMIT;