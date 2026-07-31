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
    <meta name="description" content="Broken Oath — Espadas matam homens. Decisões erradas destroem reinos.">
    <title>Broken Oath</title>

    <style>
        :root {
            --ouro: #d4a652;
            --ouro-claro: #f0d59a;
            --ouro-escuro: #76501f;
            --texto: #eee5d3;
            --texto-suave: #a9a094;
            --preto: #090909;
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
                radial-gradient(circle at 67% 35%, transparent 0%, rgba(0, 0, 0, 0.10) 34%, rgba(0, 0, 0, 0.62) 100%),
                linear-gradient(to bottom, rgba(0, 0, 0, 0.12), rgba(0, 0, 0, 0.42));
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
                linear-gradient(145deg, rgba(24, 22, 20, 0.97), rgba(7, 7, 7, 0.97));
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
            min-height: 690px;
            border: 1px solid rgba(212, 166, 82, 0.36);
            background:
                linear-gradient(rgba(13, 13, 13, 0.96), rgba(17, 17, 17, 0.96)),
                repeating-linear-gradient(
                    45deg,
                    rgba(255,255,255,0.012) 0,
                    rgba(255,255,255,0.012) 1px,
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
                radial-gradient(circle at bottom, rgba(191, 123, 32, 0.15), transparent 55%),
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
            background: linear-gradient(90deg, transparent, #d6a74c, transparent);
        }

        .conteudo {
            padding: 48px 38px 38px;
        }

        .mensagem-erro {
            margin-bottom: 18px;
            padding: 12px 14px;
            border: 1px solid rgba(165, 61, 45, 0.65);
            color: #efbbae;
            background: rgba(88, 17, 12, 0.48);
        }

        .campo {
            margin-bottom: 25px;
        }

        .campo label {
            display: block;
            margin-bottom: 10px;
            color: #efe6d7;
            font-size: 1rem;
            text-transform: uppercase;
        }

        .input-wrap {
            position: relative;
        }

        .campo input {
            width: 100%;
            height: 55px;
            padding: 0 52px 0 16px;
            border: 1px solid rgba(196, 164, 113, 0.36);
            border-radius: 3px;
            outline: none;
            color: #f1eadf;
            font: 1rem Georgia, "Times New Roman", serif;
            background: rgba(0, 0, 0, 0.58);
            transition: border-color .2s ease, box-shadow .2s ease;
        }

        .campo input::placeholder {
            color: #77736d;
        }

        .campo input:focus {
            border-color: var(--ouro);
            box-shadow: 0 0 0 3px rgba(212, 166, 82, 0.08);
        }

        .icone {
            position: absolute;
            right: 17px;
            top: 50%;
            transform: translateY(-50%);
            color: #77736d;
            font-size: 1.15rem;
            pointer-events: none;
        }

        .opcoes {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 15px;
            margin: 5px 0 32px;
            font-size: .92rem;
        }

        .lembrar {
            display: inline-flex;
            align-items: center;
            gap: 10px;
            cursor: pointer;
        }

        .lembrar input {
            width: 18px;
            height: 18px;
            accent-color: #b98634;
        }

        .esqueci {
            color: var(--ouro-claro);
            text-decoration: underline;
            text-underline-offset: 3px;
        }

        .botao {
            width: 100%;
            min-height: 62px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 14px 18px;
            border: 1px solid #d4a652;
            cursor: pointer;
            color: #f7e2b7;
            font: 700 1.12rem Georgia, "Times New Roman", serif;
            letter-spacing: .04em;
            text-decoration: none;
            text-transform: uppercase;
            background:
                linear-gradient(rgba(92, 54, 18, 0.80), rgba(61, 36, 14, 0.94)),
                repeating-linear-gradient(
                    45deg,
                    rgba(255,255,255,.025) 0,
                    rgba(255,255,255,.025) 2px,
                    transparent 2px,
                    transparent 6px
                );
            box-shadow:
                inset 0 0 0 3px rgba(24, 13, 5, 0.72),
                inset 0 0 0 5px rgba(212, 166, 82, 0.50),
                0 8px 18px rgba(0, 0, 0, 0.46);
            transition: transform .18s ease, filter .18s ease;
        }

        .botao:hover {
            transform: translateY(-2px);
            filter: brightness(1.12);
        }

        .separador {
            display: grid;
            grid-template-columns: 1fr auto 1fr;
            align-items: center;
            gap: 18px;
            margin: 25px 0 20px;
            color: #c2b49e;
            font-size: 1rem;
            text-transform: uppercase;
        }

        .separador::before,
        .separador::after {
            content: "";
            height: 1px;
            background: linear-gradient(90deg, transparent, rgba(212, 166, 82, .50));
        }

        .separador::after {
            background: linear-gradient(90deg, rgba(212, 166, 82, .50), transparent);
        }

        .botao-secundario {
            min-height: 57px;
            color: var(--ouro-claro);
            background: rgba(0, 0, 0, 0.34);
            box-shadow: inset 0 0 0 1px rgba(212, 166, 82, 0.35);
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
                0 0 18px rgba(0, 0, 0, .86);
        }

        .slogan-bloco {
            font-size: clamp(2rem, 3vw, 3.35rem);
            line-height: 1.16;
            letter-spacing: .035em;
            text-transform: uppercase;
        }

        .slogan-bloco + .slogan-bloco {
            margin-top: 28px;
            padding-top: 24px;
            border-top: 1px solid rgba(212, 166, 82, 0.55);
        }

        .status-login {
            display: none;
            margin-bottom: 18px;
            padding: 12px 14px;
            border: 1px solid rgba(165, 61, 45, 0.65);
            color: #efbbae;
            background: rgba(88, 17, 12, 0.48);
            line-height: 1.45;
        }

        .status-login.visivel {
            display: block;
        }

        .status-login.sucesso {
            border-color: rgba(116, 160, 87, 0.65);
            color: #d7edc8;
            background: rgba(29, 72, 24, 0.48);
        }

        .botao:disabled {
            cursor: wait;
            opacity: 0.72;
            transform: none;
            filter: none;
        }

        @media (max-width: 1100px) {
            .pagina {
                grid-template-columns: minmax(380px, 520px) 1fr;
                gap: 35px;
                padding: 35px;
            }

            .painel {
                min-height: auto;
            }

            .slogan-bloco {
                font-size: clamp(1.75rem, 3.2vw, 2.7rem);
            }
        }

        @media (max-width: 850px) {
            body {
                background-position: 62% center;
            }

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

            .slogan {
                margin-bottom: 15px;
            }
        }

        @media (max-width: 520px) {
            .painel-externo {
                padding: 10px;
            }

            .conteudo {
                padding: 34px 20px 26px;
            }

            .aba {
                min-height: 58px;
                font-size: 1rem;
            }

            .opcoes {
                align-items: flex-start;
                flex-direction: column;
            }

            .slogan-bloco {
                font-size: 1.65rem;
            }
        }
    </style>
</head>

<body>
    <main class="pagina">
        <section class="painel-externo" aria-label="Acesso ao reino">
            <div class="painel">
                <nav class="abas" aria-label="Acesso">
                    <a class="aba ativa" href="index.php">Entrar</a>
                    <a class="aba" href="cadastrar.php">Cadastrar</a>
                </nav>

                <div class="conteudo">
                    <div
                        id="status-login"
                        class="status-login"
                        role="alert"
                        aria-live="polite"
                    ></div>

                    <form id="login-form" autocomplete="on">
                        <div class="campo">
                            <label for="email">E-mail</label>

                            <div class="input-wrap">
                                <input
                                    type="email"
                                    id="email"
                                    name="email"
                                    placeholder="Digite seu e-mail"
                                    maxlength="160"
                                    autocomplete="email"
                                    required
                                >
                                <span class="icone" aria-hidden="true">♙</span>
                            </div>
                        </div>

                        <div class="campo">
                            <label for="senha">Senha</label>

                            <div class="input-wrap">
                                <input
                                    type="password"
                                    id="senha"
                                    name="senha"
                                    placeholder="Digite sua senha"
                                    maxlength="255"
                                    autocomplete="current-password"
                                    required
                                >
                                <span class="icone" aria-hidden="true">▣</span>
                            </div>
                        </div>

                        <div class="opcoes">
                            <label class="lembrar" for="lembrar">
                                <input type="checkbox" id="lembrar" name="lembrar" value="1">
                                <span>Lembrar de mim</span>
                            </label>

                            <a class="esqueci" href="recuperar-senha.php">
                                Esqueci minha senha
                            </a>
                        </div>

                        <button id="login-button" class="botao" type="submit">
                            Assumir o Poder
                        </button>

                        <div class="separador">ou</div>

                        <a class="botao botao-secundario" href="cadastrar.php">
                            Cadastrar
                        </a>
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
            const form = document.getElementById('login-form');
            const emailInput = document.getElementById('email');
            const passwordInput = document.getElementById('senha');
            const loginButton = document.getElementById('login-button');
            const statusLogin = document.getElementById('status-login');
            const rememberInput = document.getElementById('lembrar');

            const showStatus = (message, success = false) => {
                statusLogin.textContent = message;
                statusLogin.classList.toggle('sucesso', success);
                statusLogin.classList.add('visivel');
            };

            const clearStatus = () => {
                statusLogin.textContent = '';
                statusLogin.classList.remove('visivel', 'sucesso');
            };

            if (!config.configured || !window.supabase) {
                showStatus('Supabase não configurado. Verifique o arquivo .env.');
                loginButton.disabled = true;
                return;
            }

            const AUTH_REMEMBER_KEY = 'broken_oath_lembrar_login';

            const authStorage = {
                getItem(key) {
                    const remember = localStorage.getItem(AUTH_REMEMBER_KEY) === '1';

                    return remember
                        ? localStorage.getItem(key)
                        : sessionStorage.getItem(key);
                },

                setItem(key, value) {
                    const remember = localStorage.getItem(AUTH_REMEMBER_KEY) === '1';

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

            const client = window.supabase.createClient(
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

            const verificarSessao = async () => {
    const parametros = new URLSearchParams(window.location.search);
    const encerrandoSessao = parametros.get('logout') === '1';

    if (encerrandoSessao) {
        await client.auth.signOut({
            scope: 'local'
        });

        Object.keys(localStorage).forEach((key) => {
            if (
                key.startsWith('sb-') ||
                key.startsWith('broken_oath_')
            ) {
                localStorage.removeItem(key);
            }
        });

        sessionStorage.clear();

        window.history.replaceState(
            {},
            document.title,
            'index.php'
        );

        return;
    }

    const { data, error } = await client.auth.getSession();

    if (!error && data.session) {
        window.location.replace('dashboard.php');
    }
};

verificarSessao();

            form.addEventListener('submit', async (event) => {
                event.preventDefault();
                clearStatus();

                const email = emailInput.value.trim();
                const password = passwordInput.value;

                if (email === '' || password === '') {
                    showStatus('Preencha o e-mail e a senha.');
                    return;
                }

                loginButton.disabled = true;
                loginButton.textContent = 'Entrando...';

                if (rememberInput.checked) {
                    localStorage.setItem(AUTH_REMEMBER_KEY, '1');
                } else {
                    localStorage.removeItem(AUTH_REMEMBER_KEY);
}

                const { data, error } = await client.auth.signInWithPassword({
                    email,
                    password
                });

                if (error || !data.session) {
                    showStatus(
                        error?.message === 'Invalid login credentials'
                            ? 'E-mail ou senha inválidos.'
                            : 'Não foi possível entrar. Tente novamente.'
                    );

                    loginButton.disabled = false;
                    loginButton.textContent = 'Assumir o Poder';
                    return;
                }

                showStatus('Acesso autorizado. Entrando no reino...', true);
                window.location.replace('dashboard.php');
            });
        })();
    </script>

</body>
</html>