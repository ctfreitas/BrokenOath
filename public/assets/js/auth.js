const config = window.BROKEN_OATH_CONFIG ?? {};

const loginTab = document.getElementById('login-tab');
const registerTab = document.getElementById('register-tab');
const loginForm = document.getElementById('login-form');
const registerForm = document.getElementById('register-form');
const messageBox = document.getElementById('message');

function setMessage(text = '', type = '') {
    messageBox.textContent = text;
    messageBox.className = 'message';

    if (text) {
        messageBox.classList.add('visible');

        if (type) {
            messageBox.classList.add(type);
        }
    }
}

function showPanel(panelName) {
    const showLogin = panelName === 'login';

    loginTab.classList.toggle('active', showLogin);
    registerTab.classList.toggle('active', !showLogin);

    loginTab.setAttribute('aria-selected', String(showLogin));
    registerTab.setAttribute('aria-selected', String(!showLogin));

    loginForm.hidden = !showLogin;
    registerForm.hidden = showLogin;

    loginForm.classList.toggle('hidden', !showLogin);
    registerForm.classList.toggle('hidden', showLogin);

    setMessage();
}

async function createSupabaseClient() {
    if (!config.configured) {
        throw new Error('As variáveis do Supabase ainda não foram configuradas.');
    }

    const { createClient } = await import(
        'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm'
    );

    return createClient(config.supabaseUrl, config.supabaseAnonKey);
}

loginTab.addEventListener('click', () => showPanel('login'));
registerTab.addEventListener('click', () => showPanel('register'));

document.querySelectorAll('.form-switch').forEach((button) => {
    button.addEventListener('click', () => {
        showPanel(button.dataset.target);
    });
});

loginForm.addEventListener('submit', async (event) => {
    event.preventDefault();
    setMessage();

    const submitButton = loginForm.querySelector('button[type="submit"]');
    submitButton.disabled = true;

    try {
        const supabase = await createSupabaseClient();
        const data = new FormData(loginForm);

        const { error } = await supabase.auth.signInWithPassword({
            email: String(data.get('email') ?? '').trim(),
            password: String(data.get('password') ?? ''),
        });

        if (error) {
            throw error;
        }

        setMessage('Acesso concedido. Entrando no reino...', 'success');
        window.location.assign('/dashboard.php');
    } catch (error) {
        setMessage(
            error instanceof Error ? error.message : 'Não foi possível entrar.',
            'error'
        );
    } finally {
        submitButton.disabled = false;
    }
});

registerForm.addEventListener('submit', async (event) => {
    event.preventDefault();
    setMessage();

    const data = new FormData(registerForm);
    const password = String(data.get('password') ?? '');
    const confirmPassword = String(data.get('confirm_password') ?? '');

    if (password !== confirmPassword) {
        setMessage('As senhas informadas não coincidem.', 'error');
        return;
    }

    const submitButton = registerForm.querySelector('button[type="submit"]');
    submitButton.disabled = true;

    try {
        const supabase = await createSupabaseClient();

        const { error } = await supabase.auth.signUp({
            email: String(data.get('email') ?? '').trim(),
            password,
            options: {
                data: {
                    display_name: String(data.get('display_name') ?? '').trim(),
                },
                emailRedirectTo: `${window.location.origin}/dashboard.php`,
            },
        });

        if (error) {
            throw error;
        }

        registerForm.reset();

        setMessage(
            'Linhagem criada. Verifique seu e-mail caso a confirmação esteja ativada.',
            'success'
        );
    } catch (error) {
        setMessage(
            error instanceof Error
                ? error.message
                : 'Não foi possível criar sua linhagem.',
            'error'
        );
    } finally {
        submitButton.disabled = false;
    }
});
