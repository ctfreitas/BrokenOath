const config = window.BROKEN_OATH_CONFIG ?? {};
const statusText = document.getElementById('dashboard-status');
const logoutButton = document.getElementById('logout-button');

async function startDashboard() {
    if (!config.configured) {
        statusText.textContent = 'O Supabase ainda não foi configurado.';
        logoutButton.disabled = true;
        return;
    }

    const { createClient } = await import(
        'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm'
    );

    const supabase = createClient(config.supabaseUrl, config.supabaseAnonKey);
    const { data, error } = await supabase.auth.getSession();

    if (error || !data.session) {
        window.location.replace('/');
        return;
    }

    const user = data.session.user;
    const displayName =
        user.user_metadata?.display_name ||
        user.email ||
        'Governante';

    statusText.textContent = `Bem-vindo, ${displayName}. O mundo continuou em movimento durante sua ausência.`;

    logoutButton.addEventListener('click', async () => {
        logoutButton.disabled = true;

        await supabase.auth.signOut();
        window.location.replace('/');
    });
}

startDashboard().catch(() => {
    statusText.textContent = 'Não foi possível carregar sua sessão.';
});
