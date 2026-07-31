BEGIN;

INSERT INTO public.sentimento_tipos (nome)
SELECT 'Inveja'
WHERE NOT EXISTS (
    SELECT 1
    FROM public.sentimento_tipos
    WHERE lower(trim(nome)) = 'inveja'
);

COMMIT;