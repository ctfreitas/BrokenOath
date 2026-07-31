BEGIN;

-- Renomeia a tabela para atender jogadores e NPCs
ALTER TABLE public.personagens_npc
RENAME TO personagens;

-- Permite vincular um personagem a uma conta de jogador
ALTER TABLE public.personagens
ADD COLUMN user_id uuid
REFERENCES auth.users(id);

-- Cada usuário pode possuir apenas um personagem
ALTER TABLE public.personagens
ADD CONSTRAINT personagens_usuario_unico
UNIQUE (user_id);

-- Atualiza o índice existente
ALTER INDEX IF EXISTS public.idx_personagens_npc_cidade_origem
RENAME TO idx_personagens_cidade_origem;

-- Atualiza o tipo universal correspondente
UPDATE public.entidade_tipos
SET
    nome = 'personagem',
    descricao = 'Personagem do mundo, controlado por jogador ou pelo sistema.'
WHERE nome = 'personagem_npc';

COMMIT;