SET session_replication_role = replica;

--
-- PostgreSQL database dump
--

-- \restrict T3lmB8P21oArYpN73qjz59cs6ncOrLiaqWKIAmL9sUZi1z2WFYC4GqeS1CwacG4

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: worlds; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."worlds" ("id", "nome", "limite_jogadores", "jogadores_atuais", "velocidade", "created_at", "largura_mapa", "altura_mapa", "largura_imagem", "altura_imagem", "imagem_mapa") OVERRIDING SYSTEM VALUE VALUES
	(1, 'Terras Antigas', 15, 0, 'medio', '2026-07-28 20:29:13.094048+00', 600, 600, 16384, 16384, 'assets/mapa/mundo_alfa.png');


--
-- Data for Name: cidades; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."cidades" ("id", "user_id", "world_id", "nome_governante", "nome_cidade", "titulo_governante", "nivel_cidade", "created_at", "perfil_cidade", "tipo_entidade", "nivel_governante") VALUES
	(1, '2ea4a857-276d-4e80-93ec-a40dde8411e5', 1, 'Rei', 'Cidade Real', 'Rei', 5, '2026-07-29 19:57:37.665484+00', 'real', 'reino', 0),
	(2, '5c69e151-479a-4ed8-8a8f-6f2bdb385c56', 1, 'Malk', 'Malkalia', 'Barão', 1, '2026-07-29 20:55:52.491253+00', 'pacificadora', 'jogador', 1);


--
-- Data for Name: mapa_coordenadas; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."mapa_coordenadas" ("id", "world_id", "x", "y", "tipo_terreno", "dominio_tipo", "recurso_tipo", "producao_base_trabalhador", "modificador_producao", "bloqueado", "created_at", "sprite_offset_x", "sprite_offset_y", "sprite_width", "sprite_height") VALUES
	(5, 1, 285, 225, 'grama', 'reino', NULL, 0, 1.00, false, '2026-07-29 19:59:34.558289+00', 0, 0, 110, 110),
	(7, 1, 340, 310, 'grama', 'urbano', NULL, 0, 1.00, false, '2026-07-29 23:18:59.835396+00', 0, 0, NULL, NULL);


--
-- Data for Name: locais_mapa; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO "public"."locais_mapa" ("id", "perfil_cidade", "cidade_id", "criado_em", "regiao", "ordem", "tipo_local", "mapa_id") VALUES
	(18, NULL, 1, '2026-07-29 22:31:28.118279+00', 'centro', 1, 'especial', 5),
	(22, 'pacificadora', 2, '2026-07-29 23:26:38.878725+00', 'sul', 2, 'fundacao', 7);


--
-- Name: cidade_inicial_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."cidade_inicial_id_seq"', 2, true);


--
-- Name: mapa_coordenadas_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."mapa_coordenadas_id_seq"', 7, true);


--
-- Name: pontos_fundacao_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."pontos_fundacao_id_seq"', 22, true);


--
-- Name: worlds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('"public"."worlds_id_seq"', 1, true);


--
-- PostgreSQL database dump complete
--

-- \unrestrict T3lmB8P21oArYpN73qjz59cs6ncOrLiaqWKIAmL9sUZi1z2WFYC4GqeS1CwacG4

RESET ALL;
