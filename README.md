# Broken Oath

Projeto inicial criado do zero para a tela de entrada do jogo **Broken Oath**.

## Conteúdo

```text
public/
├── index.php
├── dashboard.php
└── assets/
    ├── css/app.css
    ├── js/auth.js
    ├── js/dashboard.js
    └── images/castle-bg.jpg
Dockerfile
render.yaml
.env.example
.gitignore
README.md
```

## Rodar no GitHub Codespaces

Na raiz do projeto:

```bash
export SUPABASE_URL="https://SEU-PROJETO.supabase.co"
export SUPABASE_ANON_KEY="SUA_CHAVE_PUBLICAVEL"
php -S 0.0.0.0:8080 -t public
```

Abra a porta `8080`.

## Criar um repositório GitHub novo

1. Crie um repositório vazio chamado `BrokenOath`.
2. Extraia este ZIP.
3. Abra a pasta extraída no Codespaces ou envie os arquivos pelo Git.
4. Execute:

```bash
git init
git add .
git commit -m "Iniciar Broken Oath do zero"
git branch -M main
git remote add origin URL_DO_NOVO_REPOSITORIO
git push -u origin main
```

Não execute `git init` quando o Codespace já tiver sido criado a partir do novo repositório.

## Configurar no Render

O projeto inclui `render.yaml` e `Dockerfile`.

No Render:

1. Crie um novo **Blueprint** ou **Web Service** ligado ao repositório.
2. Adicione:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
3. Faça o deploy.

## Configuração necessária no Supabase

Em **Authentication → URL Configuration**, adicione:

- URL local ou do Codespaces durante os testes.
- URL final fornecida pelo Render.
- A rota de redirecionamento `/dashboard.php`, quando necessário.

A chave usada no navegador deve ser a chave pública/publicável, nunca a chave secreta.

## Estado atual

- Login funcionando com Supabase.
- Cadastro funcionando com Supabase.
- Verificação de sessão no dashboard.
- Logout.
- Interface responsiva para computador e celular.
- Dashboard provisório para a próxima fase.
