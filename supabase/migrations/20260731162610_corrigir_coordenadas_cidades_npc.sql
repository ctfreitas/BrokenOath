BEGIN;

-- Cinzas do Sul: 546x520 → 449x445
UPDATE public.mapa_coordenadas
SET
    x = 449,
    y = 445
WHERE world_id = 1
  AND x = 546
  AND y = 520;

-- Lança Partida: 546x380 → 484x295
UPDATE public.mapa_coordenadas
SET
    x = 484,
    y = 295
WHERE world_id = 1
  AND x = 546
  AND y = 380;

-- Punho de Pedra: 546x194 → 502x194
UPDATE public.mapa_coordenadas
SET
    x = 502,
    y = 194
WHERE world_id = 1
  AND x = 546
  AND y = 194;

COMMIT;