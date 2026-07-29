<?php
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
    <title>Broken Oath — Painel</title>
    <link rel="stylesheet" href="css/dashboard.css">
</head>
<body>
    <div class="page-overlay"></div>
    <header class="topbar">
        <a class="brand" href="dashboard.php" aria-label="Voltar ao painel">
            <img src="assets/logo.png" alt="Brasão Broken Oath">
            <div><strong>Broken Oath</strong><span>Reinos em conflito, honra em jogo</span></div>
        </a>
        <div class="account">
            <button id="account-button" class="account-button" type="button" aria-expanded="false" aria-controls="account-menu">
                <span id="player-name">Fundar Cidade</span><span id="account-arrow" class="arrow" hidden>▾</span>
            </button>
            <nav id="account-menu" class="account-menu" hidden>
                <a id="fundar-cidade-link" href="fundar_cidade.php" hidden>Fundar Cidade</a>
                <a href="#" data-action="account">Minha Conta</a>
                <a href="#" data-action="name">Alterar nome</a>
                <a href="#" data-action="password">Alterar senha</a>
                <a href="#" class="danger" data-action="delete">Excluir conta</a>
                <button id="logout-button" type="button">Sair</button>
            </nav>
        </div>
    </header>
    <main class="dashboard">
        <section class="menu-grid" aria-label="Menu principal">
            <a class="menu-card" href="mapa.php"><img src="assets/menu/mapa.png" alt="Mapa medieval aberto sobre uma mesa"><span>Mapa</span></a>
            <a class="menu-card" href="cidade.php"><img src="assets/menu/cidade.png" alt="Cidade medieval fortificada"><span>Minha Cidade</span></a>
            <a class="menu-card" href="diplomacia.php"><img src="assets/menu/diplomacia.png" alt="Pergaminho selado e pena de escrita"><span>Diplomacia</span></a>
            <a class="menu-card" href="estatisticas-militares.php"><img src="assets/menu/estatisticas.png" alt="Espadas sobre relatório militar"><span>Estatísticas Militares</span></a>
        </section>
    </main>
    <footer>Broken Oath — Versão Alpha</footer>
    <div id="notice" class="notice" role="status" aria-live="polite"></div>
    <script>
        window.BROKEN_OATH_CONFIG = <?= json_encode([
            'supabaseUrl' => $supabaseUrl,
            'supabaseAnonKey' => $supabaseAnonKey,
            'configured' => $configured,
        ], JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
    </script>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script src="js/dashboard.js"></script>
</body>
</html>
