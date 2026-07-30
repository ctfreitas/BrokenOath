BEGIN;

INSERT INTO public.mapa_coordenadas (
    world_id,
    x,
    y,
    tipo_terreno
)
SELECT
    w.id,
    d.x,
    d.y,
    'grama'
FROM public.worlds w
CROSS JOIN (
VALUES

-- ===========================
-- NPC Mercantis
-- ===========================

(106,84),
(60,224),
(180,202),
(60,380),
(168,520),

-- ===========================
-- NPC Pacificadoras
-- ===========================

(450,84),
(402,202),
(402,380),
(295,520),
(420,520),

-- ===========================
-- NPC Bárbaras
-- ===========================

(295,84),
(295,380),
(546,194),
(546,380),
(546,520),

-- ===========================
-- Fundações Mercantis
-- ===========================

(114,110),
(70,232),
(170,232),
(70,406),
(178,546),

-- ===========================
-- Fundações Pacificadoras
-- ===========================

(438,110),
(392,232),
(392,406),
(282,546),
(410,546),

-- ===========================
-- Fundações Bárbaras
-- ===========================

(282,114),
(282,406),
(512,216),
(512,406),
(512,546)

) AS d(x,y)

WHERE lower(w.nome) = 'Terras Antigas'

AND NOT EXISTS (
    SELECT 1
    FROM public.mapa_coordenadas mc
    WHERE mc.world_id = w.id
      AND mc.x = d.x
      AND mc.y = d.y
);

COMMIT;