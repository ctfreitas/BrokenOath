BEGIN;

ALTER TABLE public.personagens
ADD COLUMN cla_id bigint
REFERENCES public.clas(id);

CREATE INDEX idx_personagens_cla
    ON public.personagens(cla_id);

COMMIT;