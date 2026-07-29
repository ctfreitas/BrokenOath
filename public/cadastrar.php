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
    <meta
        name="description"
        content="Broken Oath — Crie sua conta para entrar no reino."
    >
    <title>Broken Oath — Criar Conta</title>

    <style>
        :root {
            --ouro: #d4a652;
            --ouro-claro: #f0d59a;
            --texto: #eee5d3;
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
                linear-gradient(
                    90deg,
                    rgba(0, 0, 0, 0.28) 0%,
                    rgba(0, 0, 0, 0.08) 48%,
                    rgba(0, 0, 0, 0.18) 100%
                ),
                url("assets/background_index.png") center center / cover no-repeat fixed;
        }

        body::before {
            content: "";
            position: fixed;
            inset: 0;
            z-index: 0;
            pointer-events: none;
            background:
                radial-gradient(
                    circle at 67% 35%,
                    transparent 0%,
                    rgba(0, 0, 0, 0.10) 34%,
                    rgba(0, 0, 0, 0.62) 100%
                ),
                linear-gradient(
                    to bottom,
                    rgba(0, 0, 0, 0.12),
                    rgba(0, 0, 0, 0.42)
                );
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
            border: 2px solid rgba(190, 133, 53, 0.82);
            background:
                linear-gradient(
                    145deg,
                    rgba(24, 22, 20, 0.97),
                    rgba(7, 7, 7, 0.97)
                );
            box-shadow:
                0 28px 70px rgba(0, 0, 0, 0.85),
                inset 0 0 0 5px rgba(0, 0, 0, 0.55),
                inset 0 0 45px rgba(175, 114, 38, 0.07);
        }

        .painel-externo::before,
        .painel-externo::after {
            content: "";
            position: absolute;
            left: 9%;
            right: 9%;
            height: 18px;
            border: 1px solid rgba(212, 166, 82, 0.70);
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
            border: 1px solid rgba(212, 166, 82, 0.36);
            background:
                linear-gradient(
                    rgba(13, 13, 13, 0.96),
                    rgba(17, 17, 17, 0.96)
                ),
                repeating-linear-gradient(
                    45deg,
                    rgba(255, 255, 255, 0.012) 0,
                    rgba(255, 255, 255, 0.012) 1px,
                    transparent 1px,
                    transparent 5px
                );
        }

        .abas {
            display: grid;
            grid-template-columns: 1fr 1fr;
            border-bottom: 1px solid rgba(212, 166, 82, 0.40);
        }

        .aba {
            min-height: 68px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #98938a;
            font-size: 1.28rem;
            letter-spacing: 0.04em;
            text-decoration: none;
            text-transform: uppercase;
            border-right: 1px solid rgba(212, 166, 82, 0.28);
            background: rgba(0, 0, 0, 0.18);
        }

        .aba:last-child {
            border-right: 0;
        }

        .aba.ativa {
            position: relative;
            color: var(--ouro-claro);
            background:
                radial-gradient(
                    circle at bottom,
                    rgba(191, 123, 32, 0.15),
                    transparent 55%
                ),
                rgba(0, 0, 0, 0.10);
            text-shadow: 0 0 14px rgba(228, 173, 76, 0.28);
        }

        .aba.ativa::after {
            content: "";
            position: absolute;
            left: 0;
            right: 0;
            bottom: -1px;
            height: 2px;
            background:
                linear-gradient(90deg, transparent, #d6a74c, transparent);
        }

        .conteudo {
            padding: 38px;
        }

        .introducao {
            margin-bottom: 26px;
            color: #bdb3a4;
            line-height: 1.55;
            text-align: center;
        }

        .status {
            display: none;
            margin-bottom: 18px;
            padding: 12px 14px;
            border: 1px solid rgba(165, 61, 45, 0.65);
            color: #efbbae;
            background: rgba(88, 17, 12, 0.48);
            line-height: 1.45;
        }

        .status.visivel {
            display: block;
        }

        .status.sucesso {
            border-color: rgba(116, 160, 87, 0.65);
            color: #d7edc8;
            background: rgba(29, 72, 24, 0.48);
        }

        .campo {
            margin-bottom: 19px;
        }

        .campo label {
            display: block;
            margin-bottom: 9px;
            color: #efe6d7;
            font-size: 0.95rem;
            text-transform: uppercase;
        }

        .campo input {
            width: 100%;
            height: 53px;
            padding: 0 16px;
            border: 1px solid rgba(196, 164, 113, 0.36);
            border-radius: 3px;
            outline: none;
            color: #f1eadf;
            font: 1rem Georgia, "Times New Roman", serif;
            background: rgba(0, 0, 0, 0.58);
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .campo input::placeholder {
            color: #77736d;
        }

        .campo input:focus {
            border-color: var(--ouro);
            box-shadow: 0 0 0 3px rgba(212, 166, 82, 0.08);
        }

        .botao {
            width: 100%;
            min-height: 62px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-top: 26px;
            padding: 14px 18px;
            border: 1px solid var(--ouro);
            cursor: pointer;
            color: #f7e2b7;
            font: 700 1.12rem Georgia, "Times New Roman", serif;
            letter-spacing: 0.04em;
            text-transform: uppercase;
            background:
                linear-gradient(
                    rgba(92, 54, 18, 0.80),
                    rgba(61, 36, 14, 0.94)
                );
            box-shadow:
                inset 0 0 0 3px rgba(24, 13, 5, 0.72),
                inset 0 0 0 5px rgba(212, 166, 82, 0.50),
                0 8px 18px rgba(0, 0, 0, 0.46);
            transition: transform 0.18s ease, filter 0.18s ease;
        }

        .botao:hover {
            transform: translateY(-2px);
            filter: brightness(1.12);
        }

        .botao:disabled {
            cursor: wait;
            opacity: 0.72;
            transform: none;
            filter: none;
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
            filter:
                drop-shadow(0 16px 18px rgba(0, 0, 0, 0.88))
                drop-shadow(0 0 18px rgba(178, 112, 31, 0.12));
        }

        .slogan {
            width: 100%;
            margin-top: 18px;
            color: #ead7b2;
            text-shadow:
                0 4px 8px #000,
                0 0 18px rgba(0, 0, 0, 0.86);
        }

        .slogan-bloco {
            font-size: clamp(2rem, 3vw, 3.35rem);
            line-height: 1.16;
            letter-spacing: 0.035em;
            text-transform: uppercase;
        }

        .slogan-bloco + .slogan-bloco {
            margin-top: 28px;
            padding-top: 24px;
            border-top: 1px solid rgba(212, 166, 82, 0.55);
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
                padding: 28px 20px;
            }

            .aba {
                min-height: 58px;
                font-size: 1rem;
            }

            .slogan-bloco {
                font-size: 1.65rem;
            }
        }
    </style>
</head>

<body>
    <main class="pagina">
        <section class="painel-externo" aria-label="Criar conta">
            <div class="painel">
                <nav class="abas" aria-label="Acesso">
                    <a class="aba" href="index.php">Entrar</a>
                    <a class="aba ativa" href="cadastrar.php">Cadastrar</a>
                </nav>

                <div class="conteudo">
                    <p class="introducao">
                        Crie sua conta para entrar no reino.
                    </p>

                    <div
                        id="status"
                        class="status"
                        role="alert"
                        aria-live="polite"
                    ></div>

                    <form id="cadastro-form" autocomplete="on">




                        <div class="campo">
                            <label for="email">E-mail</label>
                            <input
                                type="email"
                                id="email"
                                name="email"
                                placeholder="Digite seu e-mail"
                                maxlength="160"
                                autocomplete="email"
                                required
                            >
                        </div>

                        <div class="campo">
                            <label for="senha">Senha</label>
                            <input
                                type="password"
                                id="senha"
                                name="senha"
                                placeholder="Crie uma senha"
                                minlength="6"
                                maxlength="255"
                                autocomplete="new-password"
                                required
                            >
                        </div>

                        <div class="campo">
                            <label for="confirmar-senha">Confirmar Senha</label>
                            <input
                                type="password"
                                id="confirmar-senha"
                                name="confirmar_senha"
                                placeholder="Digite a senha novamente"
                                minlength="6"
                                maxlength="255"
                                autocomplete="new-password"
                                required
                            >
                        </div>

                        <button id="cadastro-button" class="botao" type="submit">
                            Criar Conta
                        </button>
                    </form>
                </div>
            </div>
        </section>

        <section class="apresentacao" aria-label="Broken Oath">
            <img class="logo" src="assets/logo.png" alt="Broken Oath">

            <div class="slogan">
                <div class="slogan-bloco">
                    Espadas,<br>
                    matam homens!
                </div>

                <div class="slogan-bloco">
                    Decisões erradas,<br>
                    destroem reinos
                </div>
            </div>
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
            const form = document.getElementById('cadastro-form');
            const button = document.getElementById('cadastro-button');
            const status = document.getElementById('status');

            const emailInput = document.getElementById('email');
            const senhaInput = document.getElementById('senha');
            const confirmarSenhaInput =
                document.getElementById('confirmar-senha');

            const showStatus = (message, success = false) => {
                status.textContent = message;
                status.classList.toggle('sucesso', success);
                status.classList.add('visivel');
            };

            const clearStatus = () => {
                status.textContent = '';
                status.classList.remove('visivel', 'sucesso');
            };

            if (!config.configured || !window.supabase) {
                showStatus(
                    'Supabase não configurado. Verifique o arquivo .env.'
                );
                button.disabled = true;
                return;
            }

            const client = window.supabase.createClient(
                config.supabaseUrl,
                config.supabaseAnonKey
            );

            client.auth.getSession().then(({ data, error }) => {
                if (!error && data.session) {
                    window.location.replace('dashboard.php');
                }
            });

            form.addEventListener('submit', async (event) => {
                event.preventDefault();
                clearStatus();

                const email = emailInput.value.trim();
                const senha = senhaInput.value;
                const confirmarSenha = confirmarSenhaInput.value;

                if (
                    email === '' ||
                    senha === '' ||
                    confirmarSenha === ''
                ) {
                    showStatus('Preencha todos os campos.');
                    return;
                }

                if (senha.length < 6) {
                    showStatus('A senha deve possuir pelo menos 6 caracteres.');
                    return;
                }

                if (senha !== confirmarSenha) {
                    showStatus('As senhas informadas não são iguais.');
                    return;
                }

                button.disabled = true;
                button.textContent = 'Fundando...';

                const { data, error } = await client.auth.signUp({
                    email,
                    password: senha,
                    options: {
                        emailRedirectTo:
                            `${window.location.origin}/index.php`
                    }
                });

                if (error) {
                    const messages = {
                        'User already registered':
                            'Este e-mail já possui uma conta.',
                        'Password should be at least 6 characters':
                            'A senha deve possuir pelo menos 6 caracteres.'
                    };

                    showStatus(
                        messages[error.message] ||
                        'Não foi possível criar a conta. Tente novamente.'
                    );

                    button.disabled = false;
                    button.textContent = 'Criar Conta';
                    return;
                }

                if (data.session) {
                    showStatus(
                        'Conta criada. Entrando no reino...',
                        true
                    );

                    window.location.replace('dashboard.php');
                    return;
                }

                showStatus(
                    'Conta criada. Confirme o e-mail recebido e depois entre no reino.',
                    true
                );

                form.reset();
                button.disabled = false;
                button.textContent = 'Criar Conta';
            });
        })();
    </script>
</body>
</html>
