BEGIN;

INSERT INTO public.clas (
    nome,
    descricao
)
VALUES
(
    'Clã da Harmonia',
    'Grande clã formado pelas cidades pacificadoras. Defende a estabilidade, a cooperação e a prosperidade do Reino.'
),
(
    'Clã do Martelo',
    'Antiga casa guerreira formada pelos conquistadores de Presas de Ferro e Punho de Pedra. Valoriza força, disciplina e honra em combate.'
),
(
    'Liga do Âmbar',
    'Liga comercial que reúne Porto da Âmbar e Costa Dourada. Busca influência através do comércio marítimo.'
),
(
    'Liga das Moedas',
    'Liga mercantil composta por Vila das Moedas, Entre Rios e Porto do Corvo Branco. Defende a expansão econômica e a competição comercial.'
);

COMMIT;