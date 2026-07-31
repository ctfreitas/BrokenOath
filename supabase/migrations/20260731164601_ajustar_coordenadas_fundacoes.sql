BEGIN;

-- FUND_BARB_05
UPDATE public.mapa_coordenadas
SET
    x = 462,
    y = 474
WHERE world_id = 1
  AND x = 512
  AND y = 546;

-- FUND_BARB_04
UPDATE public.mapa_coordenadas
SET
    x = 478,
    y = 336
WHERE world_id = 1
  AND x = 512
  AND y = 406;

-- FUND_BARB_03
UPDATE public.mapa_coordenadas
SET
    x = 491,
    y = 140
WHERE world_id = 1
  AND x = 512
  AND y = 216;

-- FUND_MERC_04
UPDATE public.mapa_coordenadas
SET
    x = 96,
    y = 383
WHERE world_id = 1
  AND x = 70
  AND y = 406;

-- FUND_MERC_05
UPDATE public.mapa_coordenadas
SET
    x = 181,
    y = 462
WHERE world_id = 1
  AND x = 178
  AND y = 546;

-- FUND_PACI_04
UPDATE public.mapa_coordenadas
SET
    x = 263,
    y = 518
WHERE world_id = 1
  AND x = 282
  AND y = 546;

COMMIT;