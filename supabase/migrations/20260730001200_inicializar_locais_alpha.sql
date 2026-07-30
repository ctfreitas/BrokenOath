BEGIN;

-- =====================================================
-- Atualiza o local do Reino
-- =====================================================

UPDATE public.locais_mapa lm
SET codigo_local = 'REINO_01'
FROM public.mapa_coordenadas mc
WHERE lm.mapa_id = mc.id
  AND mc.world_id = 1
  AND mc.x = 285
  AND mc.y = 225;

-- =====================================================
-- Cria os locais do mapa
-- =====================================================

INSERT INTO public.locais_mapa (
    cidade_id,
    regiao,
    ordem,
    tipo_local,
    mapa_id,
    codigo_local
)
SELECT
    NULL,
    d.regiao,
    d.ordem,
    'especial',
    mc.id,
    d.codigo
FROM public.mapa_coordenadas mc
JOIN (

VALUES

-- =====================================================
-- NPC Mercantis
-- =====================================================

('mercantil',1,'MERC_01',106,84),
('mercantil',2,'MERC_02',60,224),
('mercantil',3,'MERC_03',180,202),
('mercantil',4,'MERC_04',60,380),
('mercantil',5,'MERC_05',168,520),

-- =====================================================
-- NPC Pacificadoras
-- =====================================================

('pacificadora',1,'PACI_01',450,84),
('pacificadora',2,'PACI_02',402,202),
('pacificadora',3,'PACI_03',402,380),
('pacificadora',4,'PACI_04',295,520),
('pacificadora',5,'PACI_05',420,520),

-- =====================================================
-- NPC Bárbaras
-- =====================================================

('conquistadora',1,'BARB_01',295,84),
('conquistadora',2,'BARB_02',295,380),
('conquistadora',3,'BARB_03',546,194),
('conquistadora',4,'BARB_04',546,380),
('conquistadora',5,'BARB_05',546,520),

-- =====================================================
-- Pontos Mercantis
-- =====================================================

('mercantil',1,'FUND_MERC_01',114,110),
('mercantil',2,'FUND_MERC_02',70,232),
('mercantil',3,'FUND_MERC_03',170,232),
('mercantil',4,'FUND_MERC_04',70,406),
('mercantil',5,'FUND_MERC_05',178,546),

-- =====================================================
-- Pontos Pacificadores
-- =====================================================

('pacificadora',1,'FUND_PACI_01',438,110),
('pacificadora',2,'FUND_PACI_02',392,232),
('pacificadora',3,'FUND_PACI_03',392,406),
('pacificadora',4,'FUND_PACI_04',282,546),
('pacificadora',5,'FUND_PACI_05',410,546),

-- =====================================================
-- Pontos Bárbaros
-- =====================================================

('conquistadora',1,'FUND_BARB_01',282,114),
('conquistadora',2,'FUND_BARB_02',282,406),
('conquistadora',3,'FUND_BARB_03',512,216),
('conquistadora',4,'FUND_BARB_04',512,406),
('conquistadora',5,'FUND_BARB_05',512,546)

) AS d(regiao,ordem,codigo,x,y)

ON mc.x = d.x
AND mc.y = d.y

WHERE mc.world_id = 1

AND NOT EXISTS (
    SELECT 1
    FROM public.locais_mapa l
    WHERE l.codigo_local = d.codigo
);

COMMIT;