(() => {
    const config = window.BROKEN_OATH_CONFIG || {};

    const accountButton = document.getElementById('account-button');
    const accountMenu = document.getElementById('account-menu');
    const playerName = document.getElementById('player-name');
    const accountArrow = document.getElementById('account-arrow');
    const fundarCidadeLink = document.getElementById('fundar-cidade-link');
    const logoutButton = document.getElementById('logout-button');
    const notice = document.getElementById('notice');

    let possuiGovernantes = false;

    const showNotice = (message) => {
        if (!notice) {
            return;
        }

        notice.textContent = message;
        notice.classList.add('show');

        window.setTimeout(() => {
            notice.classList.remove('show');
        }, 2600);
    };

    const closeAccountMenu = () => {
        accountMenu.hidden = true;
        accountButton.setAttribute('aria-expanded', 'false');
    };

    const openAccountMenu = () => {
        accountMenu.hidden = false;
        accountButton.setAttribute('aria-expanded', 'true');
    };

    const getStorageKey = (userId) => {
        return `broken_oath_governante_ativo_${userId}`;
    };

    const salvarGovernanteAtivo = (userId, governante) => {
        const dados = {
            id: governante.id,
            user_id: governante.user_id,
            world_id: governante.world_id,
            nome_governante: governante.nome_governante,
            nome_cidade: governante.nome_cidade,
            nivel_governante: governante.nivel_governante,
            nivel_cidade: governante.nivel_cidade
        };

        localStorage.setItem(
            getStorageKey(userId),
            JSON.stringify(dados)
        );

        /*
         * Mantidos também separadamente para facilitar o uso
         * nas próximas páginas do projeto.
         */
        localStorage.setItem(
            'broken_oath_governante_ativo_id',
            String(governante.id)
        );

        localStorage.setItem(
            'broken_oath_world_ativo_id',
            String(governante.world_id)
        );
    };

    const recuperarGovernanteAtivo = (userId, governantes) => {
        const storageKey = getStorageKey(userId);
        const governanteSalvo = localStorage.getItem(storageKey);

        if (governanteSalvo) {
            try {
                const dados = JSON.parse(governanteSalvo);

                const encontrado = governantes.find(
                    (governante) => String(governante.id) === String(dados.id)
                );

                if (encontrado) {
                    return encontrado;
                }
            } catch (error) {
                localStorage.removeItem(storageKey);
            }
        }

        return governantes[0];
    };

    const removerLinksDeGovernantes = () => {
        accountMenu
            .querySelectorAll('[data-governante-id]')
            .forEach((item) => item.remove());
    };

    const marcarGovernanteAtivo = (governanteId) => {
    accountMenu
        .querySelectorAll('[data-governante-id]')
        .forEach((item) => {
            const ativo =
                String(item.dataset.governanteId) ===
                String(governanteId);

            item.classList.toggle('active', ativo);

            item.setAttribute(
                'aria-current',
                ativo ? 'true' : 'false'
            );

            const status = item.querySelector('.status-governante');

            if (status) {
    status.style.color = ativo ? '#35c759' : '#6f6f6f';
    status.style.marginRight = '10px';
    status.style.display = 'inline-block';
}
        });
};

    const selecionarGovernante = (userId, governante) => {
        salvarGovernanteAtivo(userId, governante);

        playerName.textContent = 'Menu';
        marcarGovernanteAtivo(governante.id);
        closeAccountMenu();

        showNotice(
            `Governante selecionado: ${governante.nome_governante}`
        );
    };

    const criarLinksDeGovernantes = (
        userId,
        governantes,
        governanteAtivo
    ) => {
        removerLinksDeGovernantes();

        governantes.forEach((governante) => {
            const link = document.createElement('a');

            link.href = '#';
link.dataset.governanteId = governante.id;

const status = document.createElement('span');
status.className = 'status-governante status-inativo';
status.textContent = '●';

const nome = document.createElement('span');
nome.textContent = governante.nome_governante;

link.appendChild(status);
link.appendChild(nome);

            if (governante.nome_cidade) {
                link.title = `Cidade: ${governante.nome_cidade}`;
            }

            link.addEventListener('click', (event) => {
                event.preventDefault();
                selecionarGovernante(userId, governante);
            });

            accountMenu.insertBefore(link, fundarCidadeLink);
        });

        marcarGovernanteAtivo(governanteAtivo.id);
    };

    const configurarSemGovernante = () => {
        possuiGovernantes = false;

        removerLinksDeGovernantes();

        playerName.textContent = 'Menu';
        accountArrow.hidden = true;
        fundarCidadeLink.hidden = false;

        localStorage.removeItem('broken_oath_governante_ativo_id');
        localStorage.removeItem('broken_oath_world_ativo_id');

        closeAccountMenu();
    };

    const configurarComGovernantes = (
        userId,
        governantes
    ) => {
        possuiGovernantes = true;

        const governanteAtivo = recuperarGovernanteAtivo(
            userId,
            governantes
        );

        salvarGovernanteAtivo(userId, governanteAtivo);

        playerName.textContent = 'Menu';
        accountArrow.hidden = false;

        /*
         * Mantemos a opção disponível no menu.
         * As regras futuras poderão decidir quando o jogador
         * pode realmente fundar outra cidade.
         */
        fundarCidadeLink.hidden = false;

        criarLinksDeGovernantes(
            userId,
            governantes,
            governanteAtivo
        );
    };

    accountButton.addEventListener('click', () => {
        const isOpen = !accountMenu.hidden;

        if (isOpen) {
            closeAccountMenu();
        } else {
            openAccountMenu();
        }
    });

    document.addEventListener('click', (event) => {
        if (!event.target.closest('.account')) {
            closeAccountMenu();
        }
    });

    document.querySelectorAll('[data-action]').forEach((item) => {
        item.addEventListener('click', (event) => {
            event.preventDefault();

            const labels = {
                account:
                    'A tela Minha Conta será criada na próxima etapa.',
                name:
                    'A alteração de nome será implementada com histórico de 30 dias.',
                password:
                    'A alteração de senha será implementada na próxima etapa.',
                delete:
                    'A exclusão de conta ainda não está disponível.'
            };

            showNotice(
                labels[item.dataset.action] ||
                'Função em desenvolvimento.'
            );

            closeAccountMenu();
        });
    });

    if (!config.configured || !window.supabase) {
        playerName.textContent = 'Configuração pendente';

        showNotice(
            'Supabase não configurado. Verifique o arquivo .env.'
        );

        return;
    }

    const client = window.supabase.createClient(
        config.supabaseUrl,
        config.supabaseAnonKey
    );

    const carregarGovernantes = async (user) => {
        console.log('Usuário conectado:', user.id);
        const { data, error } = await client
            .from('cidades')
            .select(`
                id,
                user_id,
                world_id,
                nome_governante,
                nome_cidade,
                nivel_governante,
                nivel_cidade,
                created_at
            `)
            .eq('user_id', user.id)
            .order('created_at', {
                ascending: true
            });

        if (error) {
            console.error(
                'Erro ao carregar governantes:',
                error
            );

            playerName.textContent = 'Erro ao carregar';

            showNotice(
                'Não foi possível carregar seus governantes.'
            );

            return;
        }

        const governantes = Array.isArray(data) ? data : [];
        console.log('Governantes carregados:', governantes);

        if (governantes.length === 0) {
            configurarSemGovernante();
            return;
        }

        configurarComGovernantes(
            user.id,
            governantes
        );
    };

    const loadSession = async () => {
        const { data, error } =
            await client.auth.getSession();

        if (error || !data.session) {
            window.location.replace('/');
            return;
        }

        const user = data.session.user;

        await carregarGovernantes(user);
    };

    logoutButton.addEventListener('click', async () => {
    logoutButton.disabled = true;

    const { error } = await client.auth.signOut({
        scope: 'global'
    });

    if (error) {
        console.error('Erro ao encerrar sessão:', error);
        logoutButton.disabled = false;
        showNotice('Não foi possível sair da conta.');
        return;
    }

    Object.keys(localStorage).forEach((key) => {
        if (
            key.startsWith('sb-') ||
            key.startsWith('broken_oath_')
        ) {
            localStorage.removeItem(key);
        }
    });

    sessionStorage.clear();

    window.location.replace('index.php?logout=1');
});

    loadSession();

})();