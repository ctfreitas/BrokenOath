


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


CREATE SCHEMA IF NOT EXISTS "public";


ALTER SCHEMA "public" OWNER TO "pg_database_owner";


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE OR REPLACE FUNCTION "public"."fundar_cidade"("p_world_id" bigint, "p_nome_governante" "text", "p_nome_cidade" "text", "p_perfil_cidade" "text") RETURNS bigint
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$declare
    v_user_id uuid;
    v_cidade_id bigint;
    v_limite integer;
    v_jogadores integer;

    v_local_id bigint;
    v_mapa_id bigint;
begin
    v_user_id := auth.uid();

    if v_user_id is null then
        raise exception 'USUARIO_NAO_AUTENTICADO';
    end if;

    p_nome_governante :=
        trim(regexp_replace(p_nome_governante, '\s+', ' ', 'g'));

    p_nome_cidade :=
        trim(regexp_replace(p_nome_cidade, '\s+', ' ', 'g'));

    p_perfil_cidade :=
        lower(trim(p_perfil_cidade));

    if
        length(p_nome_governante) < 3
        or length(p_nome_cidade) < 3
        or length(p_nome_governante) > 50
        or length(p_nome_cidade) > 50
    then
        raise exception 'NOME_INVALIDO';
    end if;

    if p_perfil_cidade not in (
        'mercantil',
        'conquistadora',
        'pacificadora'
    ) then
        raise exception 'PERFIL_INVALIDO';
    end if;

    select
        limite_jogadores,
        jogadores_atuais
    into
        v_limite,
        v_jogadores
    from public.worlds
    where id = p_world_id
    for update;

    if not found then
        raise exception 'MUNDO_NAO_ENCONTRADO';
    end if;

    if v_jogadores >= v_limite then
        raise exception 'MUNDO_CHEIO';
    end if;

    if exists (
        select 1
        from public.cidades
        where world_id = p_world_id
          and user_id = v_user_id
          and tipo_entidade = 'jogador'
    ) then
        raise exception 'USUARIO_JA_POSSUI_CIDADE';
    end if;

    if exists (
        select 1
        from public.cidades
        where world_id = p_world_id
          and lower(trim(nome_governante)) =
              lower(p_nome_governante)
    ) then
        raise exception 'GOVERNANTE_JA_EXISTE';
    end if;

    if exists (
        select 1
        from public.cidades
        where world_id = p_world_id
          and lower(trim(nome_cidade)) =
              lower(p_nome_cidade)
    ) then
        raise exception 'CIDADE_JA_EXISTE';
    end if;

    select
        id,
        mapa_id
    into
        v_local_id,
        v_mapa_id
    from public.locais_mapa lm
        join public.mapa_coordenadas mc
            on mc.id = lm.mapa_id
        where mc.world_id = p_world_id
        and lm.tipo_local = 'fundacao'
        and lm.perfil_cidade = p_perfil_cidade
        and lm.cidade_id is null
    order by ordem
    limit 1
    for update;

    if not found then
        raise exception 'SEM_LOCAL_DISPONIVEL';
    end if;

    if v_mapa_id is null then
        raise exception 'LOCAL_SEM_COORDENADA';
    end if;

    insert into public.cidades (
        user_id,
        world_id,
        nome_governante,
        titulo_governante,
        nivel_governante,
        nome_cidade,
        nivel_cidade,
        perfil_cidade,
        tipo_entidade
    )
    values (
        v_user_id,
        p_world_id,
        p_nome_governante,
        'Barão',
        1,
        p_nome_cidade,
        1,
        p_perfil_cidade,
        'jogador'
    )
    returning id into v_cidade_id;

    update public.locais_mapa
    set cidade_id = v_cidade_id
    where id = v_local_id;

    update public.worlds
    set jogadores_atuais = jogadores_atuais + 1
    where id = p_world_id;

    return v_cidade_id;
end;$$;


ALTER FUNCTION "public"."fundar_cidade"("p_world_id" bigint, "p_nome_governante" "text", "p_nome_cidade" "text", "p_perfil_cidade" "text") OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."cidades" (
    "id" bigint NOT NULL,
    "user_id" "uuid" NOT NULL,
    "world_id" bigint NOT NULL,
    "nome_governante" character varying(50) NOT NULL,
    "nome_cidade" character varying(50) NOT NULL,
    "titulo_governante" character varying(20) DEFAULT 'Barão'::character varying NOT NULL,
    "nivel_cidade" smallint DEFAULT 1 NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "perfil_cidade" character varying(20) DEFAULT 'fundada'::character varying NOT NULL,
    "tipo_entidade" character varying(20) DEFAULT 'jogador'::character varying NOT NULL,
    "nivel_governante" smallint DEFAULT 1 NOT NULL,
    CONSTRAINT "chk_tipo_cidade" CHECK ((("perfil_cidade")::"text" = ANY ((ARRAY['mercantil'::character varying, 'conquistadora'::character varying, 'pacificadora'::character varying, 'real'::character varying])::"text"[]))),
    CONSTRAINT "chk_tipo_entidade" CHECK ((("tipo_entidade")::"text" = ANY ((ARRAY['reino'::character varying, 'jogador'::character varying, 'npc'::character varying, 'barbaro'::character varying])::"text"[]))),
    CONSTRAINT "ck_nivel_cidade" CHECK ((("nivel_cidade" >= 1) AND ("nivel_cidade" <= 5))),
    CONSTRAINT "ck_nivel_governante" CHECK ((("titulo_governante")::"text" = ANY ((ARRAY['Barão'::character varying, 'Visconde'::character varying, 'Conde'::character varying, 'Marquês'::character varying, 'Duque'::character varying, 'Rei'::character varying])::"text"[])))
);


ALTER TABLE "public"."cidades" OWNER TO "postgres";


ALTER TABLE "public"."cidades" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."cidade_inicial_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."locais_mapa" (
    "id" bigint NOT NULL,
    "perfil_cidade" character varying(20),
    "cidade_id" bigint,
    "criado_em" timestamp with time zone DEFAULT "now"() NOT NULL,
    "regiao" character varying(20) DEFAULT 'centro'::character varying NOT NULL,
    "ordem" smallint DEFAULT 1 NOT NULL,
    "tipo_local" character varying(20) DEFAULT 'fundacao'::character varying NOT NULL,
    "mapa_id" bigint NOT NULL,
    CONSTRAINT "chk_local_perfil_cidade" CHECK ((("perfil_cidade")::"text" = ANY ((ARRAY['mercantil'::character varying, 'conquistadora'::character varying, 'pacificadora'::character varying])::"text"[]))),
    CONSTRAINT "chk_local_regiao" CHECK ((("regiao")::"text" = ANY ((ARRAY['centro'::character varying, 'norte'::character varying, 'sul'::character varying, 'leste'::character varying, 'oeste'::character varying, 'nordeste'::character varying, 'noroeste'::character varying, 'sudeste'::character varying, 'sudoeste'::character varying])::"text"[]))),
    CONSTRAINT "chk_tipo_local" CHECK ((("tipo_local")::"text" = ANY ((ARRAY['fundacao'::character varying, 'npc'::character varying, 'barbaro'::character varying, 'especial'::character varying])::"text"[])))
);


ALTER TABLE "public"."locais_mapa" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."mapa_coordenadas" (
    "id" bigint NOT NULL,
    "world_id" bigint NOT NULL,
    "x" integer NOT NULL,
    "y" integer NOT NULL,
    "tipo_terreno" character varying(30) NOT NULL,
    "dominio_tipo" character varying(20) DEFAULT 'livre'::character varying NOT NULL,
    "recurso_tipo" character varying(30),
    "producao_base_trabalhador" integer DEFAULT 0 NOT NULL,
    "modificador_producao" numeric(5,2) DEFAULT 1.00 NOT NULL,
    "bloqueado" boolean DEFAULT false NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "sprite_offset_x" integer DEFAULT 0 NOT NULL,
    "sprite_offset_y" integer DEFAULT 0 NOT NULL,
    "sprite_width" integer,
    "sprite_height" integer,
    CONSTRAINT "chk_dominio_tipo" CHECK ((("dominio_tipo")::"text" = ANY ((ARRAY['livre'::character varying, 'territorio'::character varying, 'urbano'::character varying, 'reino'::character varying])::"text"[])))
);


ALTER TABLE "public"."mapa_coordenadas" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."mapa_coordenadas_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."mapa_coordenadas_id_seq" OWNER TO "postgres";


ALTER SEQUENCE "public"."mapa_coordenadas_id_seq" OWNED BY "public"."mapa_coordenadas"."id";



ALTER TABLE "public"."locais_mapa" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."pontos_fundacao_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."worlds" (
    "id" bigint NOT NULL,
    "nome" character varying(100) NOT NULL,
    "limite_jogadores" integer DEFAULT 10 NOT NULL,
    "jogadores_atuais" integer DEFAULT 0 NOT NULL,
    "velocidade" character varying(10) DEFAULT 'medio'::character varying NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "largura_mapa" integer DEFAULT 200 NOT NULL,
    "altura_mapa" integer DEFAULT 200 NOT NULL,
    "largura_imagem" integer DEFAULT 10240 NOT NULL,
    "altura_imagem" integer DEFAULT 10240 NOT NULL,
    "imagem_mapa" "text",
    CONSTRAINT "worlds_check" CHECK ((("jogadores_atuais" >= 0) AND ("jogadores_atuais" <= "limite_jogadores"))),
    CONSTRAINT "worlds_limite_jogadores_check" CHECK (("limite_jogadores" > 0)),
    CONSTRAINT "worlds_velocidade_check" CHECK ((("velocidade")::"text" = ANY ((ARRAY['lento'::character varying, 'medio'::character varying, 'rapido'::character varying])::"text"[])))
);


ALTER TABLE "public"."worlds" OWNER TO "postgres";


ALTER TABLE "public"."worlds" ALTER COLUMN "id" ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME "public"."worlds_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



ALTER TABLE ONLY "public"."mapa_coordenadas" ALTER COLUMN "id" SET DEFAULT "nextval"('"public"."mapa_coordenadas_id_seq"'::"regclass");



ALTER TABLE ONLY "public"."cidades"
    ADD CONSTRAINT "cidade_inicial_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."mapa_coordenadas"
    ADD CONSTRAINT "mapa_coordenadas_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."locais_mapa"
    ADD CONSTRAINT "pontos_fundacao_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."cidades"
    ADD CONSTRAINT "uq_cidade_por_mundo" UNIQUE ("world_id", "nome_cidade");



ALTER TABLE ONLY "public"."cidades"
    ADD CONSTRAINT "uq_governante_por_mundo" UNIQUE ("world_id", "nome_governante");



ALTER TABLE ONLY "public"."locais_mapa"
    ADD CONSTRAINT "uq_locais_mapa_mapa_id" UNIQUE ("mapa_id");



ALTER TABLE ONLY "public"."mapa_coordenadas"
    ADD CONSTRAINT "uq_mapa_coordenada" UNIQUE ("world_id", "x", "y");



ALTER TABLE ONLY "public"."mapa_coordenadas"
    ADD CONSTRAINT "uq_mapa_coordenadas_world_xy" UNIQUE ("world_id", "x", "y");



ALTER TABLE ONLY "public"."worlds"
    ADD CONSTRAINT "worlds_nome_key" UNIQUE ("nome");



ALTER TABLE ONLY "public"."worlds"
    ADD CONSTRAINT "worlds_pkey" PRIMARY KEY ("id");



CREATE INDEX "idx_mapa_recurso" ON "public"."mapa_coordenadas" USING "btree" ("recurso_tipo");



CREATE INDEX "idx_mapa_terreno" ON "public"."mapa_coordenadas" USING "btree" ("tipo_terreno");



CREATE INDEX "idx_mapa_world" ON "public"."mapa_coordenadas" USING "btree" ("world_id");



CREATE UNIQUE INDEX "uq_cidade_mundo_sem_maiusculas" ON "public"."cidades" USING "btree" ("world_id", "lower"(TRIM(BOTH FROM "nome_cidade")));



CREATE UNIQUE INDEX "uq_governante_mundo_sem_maiusculas" ON "public"."cidades" USING "btree" ("world_id", "lower"(TRIM(BOTH FROM "nome_governante")));



ALTER TABLE ONLY "public"."cidades"
    ADD CONSTRAINT "cidade_inicial_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."cidades"
    ADD CONSTRAINT "cidade_inicial_world_id_fkey" FOREIGN KEY ("world_id") REFERENCES "public"."worlds"("id") ON DELETE RESTRICT;



ALTER TABLE ONLY "public"."locais_mapa"
    ADD CONSTRAINT "fk_locais_mapa_mapa" FOREIGN KEY ("mapa_id") REFERENCES "public"."mapa_coordenadas"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."mapa_coordenadas"
    ADD CONSTRAINT "mapa_coordenadas_world_id_fkey" FOREIGN KEY ("world_id") REFERENCES "public"."worlds"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."locais_mapa"
    ADD CONSTRAINT "pontos_fundacao_cidade_id_fkey" FOREIGN KEY ("cidade_id") REFERENCES "public"."cidades"("id") ON DELETE SET NULL;



CREATE POLICY "Jogadores podem visualizar coordenadas" ON "public"."mapa_coordenadas" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Todos podem visualizar mundos" ON "public"."worlds" FOR SELECT USING (true);



CREATE POLICY "Usuário lê seus próprios governantes" ON "public"."cidades" FOR SELECT TO "authenticated" USING ((("auth"."uid"() = "user_id") OR (("tipo_entidade")::"text" = 'reino'::"text")));



CREATE POLICY "authenticated_can_read_locais_mapa" ON "public"."locais_mapa" FOR SELECT TO "authenticated" USING (true);



ALTER TABLE "public"."cidades" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."locais_mapa" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."mapa_coordenadas" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."worlds" ENABLE ROW LEVEL SECURITY;


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";



GRANT ALL ON FUNCTION "public"."fundar_cidade"("p_world_id" bigint, "p_nome_governante" "text", "p_nome_cidade" "text", "p_perfil_cidade" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."fundar_cidade"("p_world_id" bigint, "p_nome_governante" "text", "p_nome_cidade" "text", "p_perfil_cidade" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."fundar_cidade"("p_world_id" bigint, "p_nome_governante" "text", "p_nome_cidade" "text", "p_perfil_cidade" "text") TO "service_role";



GRANT ALL ON TABLE "public"."cidades" TO "anon";
GRANT ALL ON TABLE "public"."cidades" TO "authenticated";
GRANT ALL ON TABLE "public"."cidades" TO "service_role";



GRANT ALL ON SEQUENCE "public"."cidade_inicial_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."cidade_inicial_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."cidade_inicial_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."locais_mapa" TO "anon";
GRANT ALL ON TABLE "public"."locais_mapa" TO "authenticated";
GRANT ALL ON TABLE "public"."locais_mapa" TO "service_role";



GRANT ALL ON TABLE "public"."mapa_coordenadas" TO "anon";
GRANT ALL ON TABLE "public"."mapa_coordenadas" TO "authenticated";
GRANT ALL ON TABLE "public"."mapa_coordenadas" TO "service_role";



GRANT ALL ON SEQUENCE "public"."mapa_coordenadas_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."mapa_coordenadas_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."mapa_coordenadas_id_seq" TO "service_role";



GRANT ALL ON SEQUENCE "public"."pontos_fundacao_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."pontos_fundacao_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."pontos_fundacao_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."worlds" TO "anon";
GRANT ALL ON TABLE "public"."worlds" TO "authenticated";
GRANT ALL ON TABLE "public"."worlds" TO "service_role";



GRANT ALL ON SEQUENCE "public"."worlds_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."worlds_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."worlds_id_seq" TO "service_role";



ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";







