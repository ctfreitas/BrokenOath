<?php
declare(strict_types=1);

$supabaseUrl = getenv('SUPABASE_URL') ?: '';
$supabaseAnonKey = getenv('SUPABASE_ANON_KEY') ?: '';
$configured = $supabaseUrl !== '' && $supabaseAnonKey !== '';
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Broken Oath — Acesso ao Reino</title>
    <meta name="description" content="Assuma o poder ou crie sua linhagem no mundo persistente de Broken Oath.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@500;600;700&family=IM+Fell+English:ital@0;1&family=MedievalSharp&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body class="auth-page">
    <div class="world-background" aria-hidden="true">
        <div class="mist mist-one"></div>
        <div class="mist mist-two"></div>
        <div class="embers"></div>
        <div class="vignette"></div>
    </div>

    <main class="landing-shell">
        <header class="scroll-header" aria-labelledby="game-title">
            <span class="scroll-rod scroll-rod-left" aria-hidden="true"></span>

            <div class="scroll-paper">
                <span class="scroll-ornament" aria-hidden="true">◆</span>
                <h1 id="game-title">Broken Oath</h1>
                <span class="wax-seal" aria-hidden="true">♛</span>
            </div>

            <span class="scroll-rod scroll-rod-right" aria-hidden="true"></span>
        </header>

        <section class="hero-grid">
            <article class="oath-message" aria-labelledby="oath-heading">
                <h2 id="oath-heading">O reino jamais dorme.</h2>

                <p>
                    Juramentos são feitos.<br>
                    Alguns são quebrados.
                </p>

                <span class="handwritten-divider" aria-hidden="true">◆</span>

                <p>
                    Governe com honra.<br>
                    Ou seja lembrado pelo medo.
                </p>
            </article>

            <section class="access-gate" aria-label="Acesso ao reino">
                <div class="crest" aria-hidden="true">♜</div>

                <div class="gate-content">
                    <div class="tabs" role="tablist" aria-label="Escolha uma forma de acesso">
                        <button
                            id="login-tab"
                            class="tab active"
                            type="button"
                            role="tab"
                            aria-selected="true"
                            aria-controls="login-form">
                            Assumir o Poder
                        </button>

                        <button
                            id="register-tab"
                            class="tab"
                            type="button"
                            role="tab"
                            aria-selected="false"
                            aria-controls="register-form">
                            Ingressar no Reino
                        </button>
                    </div>

                    <?php if (!$configured): ?>
                        <div class="setup-warning" role="alert">
                            Configure as variáveis
                            <strong>SUPABASE_URL</strong> e
                            <strong>SUPABASE_ANON_KEY</strong>.
                        </div>
                    <?php endif; ?>

                    <div id="message" class="message" role="status" aria-live="polite"></div>

                    <form
                        id="login-form"
                        class="auth-form"
                        role="tabpanel"
                        aria-labelledby="login-tab">

                        <header class="form-heading">
                            <p class="form-kicker">Retorne ao seu domínio</p>
                            <h2>Acesse o Reino</h2>
                            <p>Seu reino aguarda a volta de seu governante.</p>
                        </header>

                        <label for="login-email">E-mail</label>
                        <input
                            id="login-email"
                            name="email"
                            type="email"
                            autocomplete="email"
                            placeholder="governante@reino.com"
                            required>

                        <label for="login-password">Senha</label>
                        <input
                            id="login-password"
                            name="password"
                            type="password"
                            autocomplete="current-password"
                            minlength="6"
                            placeholder="Sua senha"
                            required>

                        <button class="primary-button" type="submit">
                            Assumir o Poder
                        </button>

                        <p class="switch-copy">Ainda não possui uma linhagem?</p>

                        <button
                            class="secondary-button form-switch"
                            data-target="register"
                            type="button">
                            Ingressar no Reino
                        </button>
                    </form>

                    <form
                        id="register-form"
                        class="auth-form hidden"
                        role="tabpanel"
                        aria-labelledby="register-tab"
                        hidden>

                        <header class="form-heading">
                            <p class="form-kicker">Inicie sua jornada</p>
                            <h2>Crie sua Linhagem</h2>
                            <p>Escolha como seu nome será lembrado.</p>
                        </header>

                        <label for="register-name">Nome do governante</label>
                        <input
                            id="register-name"
                            name="display_name"
                            type="text"
                            autocomplete="name"
                            minlength="2"
                            maxlength="40"
                            placeholder="Como será conhecido?"
                            required>

                        <label for="register-email">E-mail</label>
                        <input
                            id="register-email"
                            name="email"
                            type="email"
                            autocomplete="email"
                            placeholder="governante@reino.com"
                            required>

                        <label for="register-password">Senha</label>
                        <input
                            id="register-password"
                            name="password"
                            type="password"
                            autocomplete="new-password"
                            minlength="6"
                            placeholder="No mínimo 6 caracteres"
                            required>

                        <label for="register-confirm-password">Confirmar senha</label>
                        <input
                            id="register-confirm-password"
                            name="confirm_password"
                            type="password"
                            autocomplete="new-password"
                            minlength="6"
                            placeholder="Repita a senha"
                            required>

                        <label class="terms-row">
                            <input id="register-terms" type="checkbox" required>
                            <span>Concordo em participar desta versão de testes.</span>
                        </label>

                        <button class="primary-button" type="submit">
                            Ingressar no Reino
                        </button>

                        <button
                            class="secondary-button form-switch"
                            data-target="login"
                            type="button">
                            Voltar ao Acesso
                        </button>
                    </form>

                    <p class="footer-note">
                        Primeira versão de desenvolvimento.<br>
                        Nenhum pagamento é necessário.
                    </p>
                </div>
            </section>
        </section>
    </main>

    <script>
        window.BROKEN_OATH_CONFIG = <?= json_encode([
            'supabaseUrl' => $supabaseUrl,
            'supabaseAnonKey' => $supabaseAnonKey,
            'configured' => $configured,
        ], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
    </script>
    <script type="module" src="/assets/js/auth.js"></script>
</body>
</html>
