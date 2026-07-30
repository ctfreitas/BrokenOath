ALTER TABLE public.worlds
    ADD COLUMN multiplicador_tempo numeric(4,2) NOT NULL DEFAULT 8.00;

UPDATE public.worlds
SET multiplicador_tempo = 8.00;

ALTER TABLE public.worlds
    ADD CONSTRAINT worlds_multiplicador_tempo_positivo
    CHECK (multiplicador_tempo > 0);

ALTER TABLE public.worlds
    DROP COLUMN velocidade;