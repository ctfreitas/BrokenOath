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
    <title>Broken Oath — Seu Reino</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@500;600;700&family=IM+Fell+English:ital@0;1&family=MedievalSharp&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="/assets/css/app.css">
</head>
<body class="dashboard-page">
    <div class="world-background" aria-hidden="true">
        <div class="vignette"></div>
    </div>

    <main class="dashboard-shell">
        <section class="dashboard-card">
            <p class="dashboard-kicker">Broken Oath</p>
            <h1>Seu reino começa aqui.</h1>
            <p id="dashboard-status">
                Verificando sua linhagem...
            </p>

            <div class="dashboard-placeholder">
                <h2>Primeiro marco</h2>
                <p>
                    Esta será a base para o mapa, cidade, recursos, exércitos
                    e todos os sistemas do mundo persistente.
                </p>
            </div>

            <button id="logout-button" class="primary-button" type="button">
                Abandonar o Salão
            </button>
        </section>
    </main>

    <script>
        window.BROKEN_OATH_CONFIG = <?= json_encode([
            'supabaseUrl' => $supabaseUrl,
            'supabaseAnonKey' => $supabaseAnonKey,
            'configured' => $configured,
        ], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
    </script>
    <script type="module" src="/assets/js/dashboard.js"></script>
</body>
</html>
