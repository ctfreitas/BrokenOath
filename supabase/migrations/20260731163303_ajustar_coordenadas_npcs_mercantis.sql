BEGIN;

-- Costa Dourada
UPDATE public.mapa_coordenadas
SET
    x = 205,
    y = 508
WHERE world_id = 1
  AND x = 168
  AND y = 520;

-- Porto do Corvo Branco
UPDATE public.mapa_coordenadas
SET
    x = 76,
    y = 335
WHERE world_id = 1
  AND x = 60
  AND y = 380;

-- Vila das Moedas
UPDATE public.mapa_coordenadas
SET
    x = 82,
    y = 186
WHERE world_id = 1
  AND x = 60
  AND y = 224;

COMMIT;