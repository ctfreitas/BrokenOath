BEGIN;

-- Pacificadores: todos no Clã da Harmonia
UPDATE public.personagens p
SET cla_id = (
    SELECT id
    FROM public.clas
    WHERE nome = 'Clã da Harmonia'
    LIMIT 1
)
FROM public.cidades c
WHERE p.cidade_origem_id = c.id
  AND c.nome_cidade IN (
      'Bosque dos Anciões',
      'Vale da Névoa',
      'Refúgio das Araucárias',
      'Colina da Aurora',
      'Pedra Serena'
  );

-- Conquistadores: apenas dois no Clã do Martelo
UPDATE public.personagens p
SET cla_id = (
    SELECT id
    FROM public.clas
    WHERE nome = 'Clã do Martelo'
    LIMIT 1
)
FROM public.cidades c
WHERE p.cidade_origem_id = c.id
  AND c.nome_cidade IN (
      'Presas de Ferro',
      'Punho de Pedra'
  );

-- Mercantis: Liga do Âmbar
UPDATE public.personagens p
SET cla_id = (
    SELECT id
    FROM public.clas
    WHERE nome = 'Liga do Âmbar'
    LIMIT 1
)
FROM public.cidades c
WHERE p.cidade_origem_id = c.id
  AND c.nome_cidade IN (
      'Porto da Âmbar',
      'Costa Dourada'
  );

-- Mercantis: Liga das Moedas
UPDATE public.personagens p
SET cla_id = (
    SELECT id
    FROM public.clas
    WHERE nome = 'Liga das Moedas'
    LIMIT 1
)
FROM public.cidades c
WHERE p.cidade_origem_id = c.id
  AND c.nome_cidade IN (
      'Vila das Moedas',
      'Entre Rios',
      'Porto do Corvo Branco'
  );

COMMIT;