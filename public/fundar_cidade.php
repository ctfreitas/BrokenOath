<?php
declare(strict_types=1);

$envPath = __DIR__ . '/../.env';
$env = file_exists($envPath) ? parse_ini_file($envPath) : [];

$supabaseUrl = $env['SUPABASE_URL'] ?? '';
$supabaseAnonKey = $env['SUPABASE_ANON_KEY'] ?? '';
$configured = $supabaseUrl !== '' && $supabaseAnonKey !== '';
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Broken Oath — Escolha um mundo, nomeie seu governante e funde sua cidade inicial.">
    <title>Broken Oath — Fundar Cidade</title>

    <style>
        :root {
            --ouro: #d4a652;
            --ouro-claro: #f0d59a;
            --texto: #eee5d3;
            --texto-fraco: #bdb3a4;
            --erro: #efbbae;
            --sucesso: #d7edc8;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        html,
        body {
            width: 100%;
            min-height: 100%;
        }

        body {
            min-height: 100vh;
            overflow-x: hidden;
            color: var(--texto);
            font-family: Georgia, "Times New Roman", serif;
            background:
                linear-gradient(90deg, rgba(0, 0, 0, .32), rgba(0, 0, 0, .10) 52%, rgba(0, 0, 0, .28)),
                url("assets/background_index.png") center / cover no-repeat fixed;
        }

        body::before {
            content: "";
            position: fixed;
            inset: 0;
            z-index: 0;
            pointer-events: none;
            background:
                radial-gradient(circle at 67% 35%, transparent 0%, rgba(0, 0, 0, .12) 35%, rgba(0, 0, 0, .68) 100%),
                linear-gradient(to bottom, rgba(0, 0, 0, .14), rgba(0, 0, 0, .48));
        }

        .pagina {
            position: relative;
            z-index: 1;
            min-height: 100vh;
            display: grid;
            grid-template-columns: minmax(430px, 590px) minmax(430px, 1fr);
            align-items: center;
            gap: clamp(50px, 7vw, 130px);
            padding: clamp(38px, 5vh, 70px) clamp(55px, 6vw, 105px);
        }

        .painel-externo {
            position: relative;
            width: 100%;
            padding: 18px;
            border: 2px solid rgba(190, 133, 53, .82);
            background: linear-gradient(145deg, rgba(24, 22, 20, .97), rgba(7, 7, 7, .97));
            box-shadow: 0 28px 70px rgba(0, 0, 0, .85), inset 0 0 0 5px rgba(0, 0, 0, .55);
        }

        .painel-externo::before,
        .painel-externo::after {
            content: "";
            position: absolute;
            left: 9%;
            right: 9%;
            height: 18px;
            border: 1px solid rgba(212, 166, 82, .70);
            pointer-events: none;
        }

        .painel-externo::before {
            top: -10px;
            border-bottom: 0;
        }

        .painel-externo::after {
            bottom: -10px;
            border-top: 0;
        }

        .painel {
            border: 1px solid rgba(212, 166, 82, .36);
            background: linear-gradient(rgba(13, 13, 13, .96), rgba(17, 17, 17, .96));
        }

        .cabecalho-painel {
            padding: 25px 30px 20px;
            border-bottom: 1px solid rgba(212, 166, 82, .40);
            text-align: center;
        }

        .cabecalho-painel h1 {
            color: var(--ouro-claro);
            font-size: clamp(1.55rem, 2.2vw, 2.05rem);
            font-weight: 700;
            letter-spacing: .05em;
            text-transform: uppercase;
        }

        .cabecalho-painel p {
            margin-top: 8px;
            color: var(--texto-fraco);
            line-height: 1.45;
        }

        .conteudo {
            padding: 30px 38px 36px;
        }

        .status {
            display: none;
            margin-bottom: 18px;
            padding: 12px 14px;
            border: 1px solid rgba(165, 61, 45, .65);
            color: var(--erro);
            background: rgba(88, 17, 12, .48);
            line-height: 1.45;
        }

        .status.visivel {
            display: block;
        }

        .status.sucesso {
            border-color: rgba(116, 160, 87, .65);
            color: var(--sucesso);
            background: rgba(29, 72, 24, .48);
        }

        .campo {
            margin-bottom: 19px;
        }

        .campo label {
            display: block;
            margin-bottom: 9px;
            color: #efe6d7;
            font-size: .92rem;
            text-transform: uppercase;
        }

        .campo input,
        .campo select {
            width: 100%;
            height: 53px;
            padding: 0 16px;
            border: 1px solid rgba(196, 164, 113, .36);
            border-radius: 3px;
            outline: none;
            color: #f1eadf;
            font: 1rem Georgia, "Times New Roman", serif;
            background: rgba(0, 0, 0, .66);
            transition: border-color .2s ease, box-shadow .2s ease, opacity .2s ease;
        }

        .campo select option {
            color: #f1eadf;
            background: #17130f;
        }

        .campo input::placeholder {
            color: #77736d;
        }

        .campo input:focus,
        .campo select:focus {
            border-color: var(--ouro);
            box-shadow: 0 0 0 3px rgba(212, 166, 82, .08);
        }

        .campo input:disabled,
        .campo select:disabled {
            cursor: not-allowed;
            opacity: .52;
        }

        .ajuda {
            display: block;
            margin-top: 7px;
            color: #8f887d;
            font-size: .82rem;
            line-height: 1.35;
        }

        .resumo-mundo {
            display: none;
            margin: 3px 0 20px;
            padding: 12px 14px;
            border-left: 3px solid var(--ouro);
            color: #d8c7a6;
            background: rgba(75, 48, 18, .24);
            line-height: 1.45;
        }

        .resumo-mundo.visivel {
            display: block;
        }

        .botao {
            width: 100%;
            min-height: 62px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-top: 25px;
            padding: 14px 18px;
            border: 1px solid var(--ouro);
            cursor: pointer;
            color: #f7e2b7;
            font: 700 1.12rem Georgia, "Times New Roman", serif;
            letter-spacing: .04em;
            text-transform: uppercase;
            background: linear-gradient(rgba(92, 54, 18, .80), rgba(61, 36, 14, .94));
            box-shadow: inset 0 0 0 3px rgba(24, 13, 5, .72), inset 0 0 0 5px rgba(212, 166, 82, .50), 0 8px 18px rgba(0, 0, 0, .46);
            transition: transform .18s ease, filter .18s ease;
        }

        .botao:hover:not(:disabled) {
            transform: translateY(-2px);
            filter: brightness(1.12);
        }

        .botao:disabled {
            cursor: not-allowed;
            opacity: .62;
        }

        .voltar {
            display: block;
            margin-top: 18px;
            color: #bba477;
            text-align: center;
            text-decoration: none;
        }

        .voltar:hover {
            color: var(--ouro-claro);
        }

        .apresentacao {
            width: min(690px, 100%);
            justify-self: center;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }

        .logo {
            width: min(520px, 80%);
            max-height: 500px;
            object-fit: contain;
            filter: drop-shadow(0 16px 18px rgba(0, 0, 0, .88));
        }

        .lema {
            width: 100%;
            margin-top: 18px;
            color: #ead7b2;
            font-size: clamp(1.7rem, 2.7vw, 3rem);
            line-height: 1.2;
            letter-spacing: .035em;
            text-transform: uppercase;
            text-shadow: 0 4px 8px #000, 0 0 18px rgba(0, 0, 0, .86);
        }

        @media (max-width: 850px) {
            .pagina {
                grid-template-columns: 1fr;
                padding: 28px 18px 45px;
            }

            .apresentacao {
                order: 1;
            }

            .painel-externo {
                order: 2;
                max-width: 590px;
                justify-self: center;
            }

            .logo {
                width: min(390px, 78%);
            }
        }

        @media (max-width: 520px) {
            .painel-externo {
                padding: 10px;
            }

            .conteudo {
                padding: 26px 20px 30px;
            }

            .cabecalho-painel {
                padding: 22px 18px 18px;
            }
        }
    </style>
</head>
<body>
    <main class="pagina">
        <section class="painel-externo" aria-label="Fundar cidade">
            <div class="painel">
                <header class="cabecalho-painel">
                    <h1>Fundar Cidade</h1>
                    <p>Escolha seu mundo e dê início à sua Baronia.</p>
                </header>

                <div class="conteudo">
                    <div id="status" class="status" role="alert" aria-live="polite"></div>

                    <form id="fundacao-form" autocomplete="off">
                        <div class="campo">
                            <label for="mundo">1. Selecione o Mundo</label>
                            <select id="mundo" name="mundo" required disabled>
                                <option value="">Carregando mundos...</option>
                            </select>
                        </div>

                        <div id="resumo-mundo" class="resumo-mundo"></div>

                        <div class="campo">
                            <label for="governante">2. Nome do Governante</label>
                            <input
                                type="text"
                                id="governante"
                                name="governante"
                                placeholder="Digite o nome do governante"
                                minlength="3"
                                maxlength="50"
                                autocomplete="nickname"
                                required
                                disabled
                            >
                            <small class="ajuda">O nome precisa ser único apenas dentro do mundo escolhido.</small>
                        </div>


<div class="campo">
    <label for="perfil-cidade">3. Perfil da Cidade</label>

    <select
        id="perfil-cidade"
        name="perfil-cidade"
        required
        disabled
    >
        <option value="">Selecione um perfil</option>
        <option value="mercantil">Mercantil</option>
        <option value="conquistadora">Conquistadora</option>
        <option value="pacificadora">Pacificadora</option>
    </select>

    <small class="ajuda">
        O perfil define a especialização inicial da cidade.
    </small>
</div>

                        <div class="campo">
                            <label for="cidade">4. Nome da Cidade</label>
                            <input
                                type="text"
                                id="cidade"
                                name="cidade"
                                placeholder="Digite o nome da cidade"
                                minlength="3"
                                maxlength="50"
                                required
                                disabled
                            >
                            <small class="ajuda">A cidade começará como Baronia e também será única apenas nesse mundo.</small>
                        </div>

                        <button id="fundar-button" class="botao" type="submit" disabled>
                            Fundar Baronia
                        </button>
                    </form>

                    <a class="voltar" href="dashboard.php">Voltar ao painel</a>
                </div>
            </div>
        </section>

        <section class="apresentacao" aria-label="Broken Oath">
            <img class="logo" src="assets/logo.png" alt="Broken Oath">
            <div class="lema">Toda grande dinastia começa com uma única terra.</div>
        </section>
    </main>

    <script>
        window.BROKEN_OATH_CONFIG = <?= json_encode([
            'supabaseUrl' => $supabaseUrl,
            'supabaseAnonKey' => $supabaseAnonKey,
            'configured' => $configured,
        ], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
    </script>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>

    <script>
        (() => {
            const config = window.BROKEN_OATH_CONFIG || {};
            const form = document.getElementById('fundacao-form');
            const mundoSelect = document.getElementById('mundo');
            const governanteInput = document.getElementById('governante');
            const cidadeInput = document.getElementById('cidade');
            const button = document.getElementById('fundar-button');
            const status = document.getElementById('status');
            const resumoMundo = document.getElementById('resumo-mundo');

            let client = null;
            let mundos = [];
            let usuario = null;

            const mostrarStatus = (mensagem, sucesso = false) => {
                status.textContent = mensagem;
                status.classList.toggle('sucesso', sucesso);
                status.classList.add('visivel');
            };

            const limparStatus = () => {
                status.textContent = '';
                status.classList.remove('visivel', 'sucesso');
            };

            const normalizarNome = (valor) => valor.trim().replace(/\s+/g, ' ');

            const atualizarCampos = () => {
                const mundoSelecionado = mundoSelect.value !== '';
                    governanteInput.disabled = !mundoSelecionado;
                    cidadeInput.disabled = !mundoSelecionado;
                    document.getElementById('perfil-cidade').disabled = !mundoSelecionado;
                    button.disabled = !mundoSelecionado;

                const mundo = mundos.find((item) => String(item.id) === mundoSelect.value);

                if (!mundo) {
                    resumoMundo.textContent = '';
                    resumoMundo.classList.remove('visivel');
                    return;
                }

                const vagas = mundo.limite_jogadores - mundo.jogadores_atuais;
                resumoMundo.textContent =
                    `${mundo.nome} — multiplicador de tempo ${mundo.multiplicador_tempo}; ` +
                    `${mundo.jogadores_atuais}/${mundo.limite_jogadores} jogadores; ` +
                    `${vagas} vaga${vagas === 1 ? '' : 's'} disponível${vagas === 1 ? '' : 'is'}.`;
                resumoMundo.classList.add('visivel');
            };

            const carregarMundos = async () => {
                const { data, error } = await client
                    .from('worlds')
                    .select('id, nome, limite_jogadores, jogadores_atuais, multiplicador_tempo')
                    .order('id', { ascending: true });

                if (error) {
                    mostrarStatus('Não foi possível carregar os mundos disponíveis.');
                    mundoSelect.innerHTML = '<option value="">Erro ao carregar mundos</option>';
                    return;
                }

                mundos = data || [];
                mundoSelect.innerHTML = '<option value="">Escolha um mundo</option>';

                for (const mundo of mundos) {
                    const cheio = mundo.jogadores_atuais >= mundo.limite_jogadores;
                    const option = document.createElement('option');
                    option.value = String(mundo.id);
                    option.disabled = cheio;
                    option.textContent =
                        `${mundo.nome} (${mundo.jogadores_atuais}/${mundo.limite_jogadores})` +
                        (cheio ? ' — Lotado' : '');
                    mundoSelect.appendChild(option);
                }

                mundoSelect.disabled = mundos.length === 0;

                if (mundos.length === 0) {
                    mostrarStatus('Nenhum mundo está disponível neste momento.');
                }
            };

            const iniciar = async () => {
                if (!config.configured || !window.supabase) {
                    mostrarStatus('Supabase não configurado. Verifique o arquivo .env.');
                    return;
                }

                const AUTH_REMEMBER_KEY = 'broken_oath_lembrar_login';

                const authStorage = {
                    getItem(key) {
                        const remember =
                            localStorage.getItem(AUTH_REMEMBER_KEY) === '1';

                        return remember
                            ? localStorage.getItem(key)
                            : sessionStorage.getItem(key);
                    },

                    setItem(key, value) {
                        const remember =
                            localStorage.getItem(AUTH_REMEMBER_KEY) === '1';

                        if (remember) {
                            localStorage.setItem(key, value);
                            sessionStorage.removeItem(key);
                        } else {
                            sessionStorage.setItem(key, value);
                            localStorage.removeItem(key);
                        }
                    },

                    removeItem(key) {
                        localStorage.removeItem(key);
                        sessionStorage.removeItem(key);
                    }
                };

                client = window.supabase.createClient(
                    config.supabaseUrl,
                    config.supabaseAnonKey,
                    {
                        auth: {
                            storage: authStorage,
                            persistSession: true,
                            autoRefreshToken: true,
                            detectSessionInUrl: true
                        }
                    }
);

                const { data, error } = await client.auth.getSession();

                if (error || !data.session) {
                    window.location.replace('index.php');
                    return;
                }

                usuario = data.session.user;
                await carregarMundos();
            };

            mundoSelect.addEventListener('change', () => {
    limparStatus();
    atualizarCampos();
});

form.addEventListener('submit', async (event) => {
    event.preventDefault();
    limparStatus();

    const worldId = Number(mundoSelect.value);
    const governante = normalizarNome(governanteInput.value);
    const cidade = normalizarNome(cidadeInput.value);
    const perfilCidade =
        document.getElementById('perfil-cidade').value;

    if (!Number.isInteger(worldId) || worldId <= 0) {
        mostrarStatus('Selecione um mundo válido.');
        return;
    }

    if (governante.length < 3 || cidade.length < 3) {
        mostrarStatus('Os nomes devem possuir pelo menos 3 caracteres.');
        return;
    }

    button.disabled = true;
    button.textContent = 'Fundando...';

    const { data, error } = await client.rpc('fundar_cidade', {
        p_world_id: worldId,
        p_nome_governante: governante,
        p_nome_cidade: cidade,
        p_perfil_cidade: perfilCidade
    });

                if (error) {
    console.error('Erro retornado pela função de fundação:', error);

    const mensagem = error.message || '';

    const erros = {
        'GOVERNANTE_JA_EXISTE': 'Já existe um governante com esse nome neste mundo.',
        'CIDADE_JA_EXISTE': 'Já existe uma cidade com esse nome neste mundo.',
        'MUNDO_CHEIO': 'Este mundo atingiu o limite de jogadores.',
        'MUNDO_NAO_ENCONTRADO': 'O mundo selecionado não existe.',
        'USUARIO_NAO_AUTENTICADO': 'Sua sessão expirou. Entre novamente.',
        'NOME_INVALIDO': 'Informe nomes válidos para o governante e a cidade.'
    };

    const chave = Object.keys(erros).find((item) => mensagem.includes(item));

    mostrarStatus(
        chave ? erros[chave] : 'Não foi possível fundar a cidade. Tente novamente.'
    );

    button.disabled = false;
    button.textContent = 'Fundar Baronia';
    return;
}

                localStorage.setItem('broken_oath_cidade_ativa_id', String(data));
                localStorage.setItem('broken_oath_governante_ativo', governante);

                mostrarStatus('Baronia fundada com sucesso. Preparando seu domínio...', true);

                setTimeout(() => {
                    window.location.replace('dashboard.php');
                }, 1200);
            });

            iniciar();
        })();
    </script>
</body>
</html>
