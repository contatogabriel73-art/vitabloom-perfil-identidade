# VITABLOOM: como ligar o painel de agendamentos

Este passo a passo leva uns 15 minutos. Você só precisa de um e-mail e do navegador.

## O que você vai ter no final

- O site (`index.html`) grava cada visita e cada agendamento no Supabase.
- O painel (`admin.html`) mostra visitas, agendamentos, pagos e faturamento, e deixa você marcar pagamentos.

## 1. Criar o projeto no Supabase

1. Entre em <https://supabase.com> e crie uma conta gratuita.
2. Clique em **New project**, dê um nome (ex.: `vitabloom`), escolha uma senha para o banco (guarde) e a região **South America (São Paulo)**.
3. Espere uns 2 minutos até o projeto ficar pronto.

## 2. Rodar o SQL

1. Abra o arquivo `supabase-setup.sql` num editor de texto (Bloco de Notas serve).
2. Perto do final, troque `seu@email.com` pelo **e-mail que você vai usar para entrar no painel**. Só ele terá acesso.
3. No Supabase, clique em **SQL Editor** (menu da esquerda), depois **New query**.
4. Cole o conteúdo inteiro do arquivo e clique em **Run**. Deve aparecer "Success".

## 3. Criar o seu usuário

1. No menu da esquerda, clique em **Authentication** e depois em **Users**.
2. Clique em **Add user > Create new user**.
3. Digite o **mesmo e-mail** do passo 2, escolha uma senha forte e marque **Auto Confirm User**.
4. Clique em **Create user**.

## 4. Fechar o cadastro para estranhos

1. Vá em **Authentication > Sign In / Providers** (ou **Settings**, conforme a versão).
2. Desligue **Allow new users to sign up**.

Assim ninguém além de você consegue criar conta no seu projeto.

## 5. Colar a URL e a chave no `config.js`

1. No Supabase, vá em **Project Settings > API**.
2. Copie o **Project URL** e cole entre as aspas de `SUPABASE_URL` no arquivo `config.js`.
3. Copie a chave **anon / public** e cole entre as aspas de `SUPABASE_ANON_KEY`.

Importante: use **somente** a chave `anon`. Nunca use a `service_role`.

## 6. Testar

1. Abra o `index.html` no navegador (ou o site publicado).
2. Faça um agendamento de teste e preencha todos os campos. Deve aparecer a tela "Que alegria ter você".
3. Abra o `admin.html`, entre com seu e-mail e senha. O agendamento deve aparecer na lista e as visitas nos cartões.
4. Teste **Marcar como pago**, informe o valor e confira o Faturamento.
5. Apague o agendamento de teste com **Remover**.

Se aparecer a mensagem "Não conseguimos registrar seu agendamento", confira o `config.js` (passo 5) e se o SQL rodou sem erro (passo 2).

## 7. Publicar

Publique **todos os arquivos da pasta** (`index.html`, `admin.html`, `config.js`, `quiz.html`, `devolutiva.html`) no seu serviço de hospedagem (Netlify, Vercel, GitHub Pages, Hostinger etc.). O arquivo `supabase-setup.sql` e este `LEIA-ME.md` não precisam ir para o site.

O painel fica em `seu-site.com/admin.html`, também acessível pelo link **Área de gestão** no rodapé do site.

## Dúvidas comuns

- **Esqueci a senha:** em Authentication > Users, clique nos três pontinhos do seu usuário e escolha redefinir a senha.
- **Quero outro e-mail como administrador:** no SQL Editor, rode `insert into public.admins (email) values ('novo@email.com');` e crie o usuário no passo 3.
- **Visitas contam quem?** Uma vez por pessoa a cada vez que abre o site (por sessão do navegador).
- **Faturamento** é a soma dos valores que você informou ao marcar como pago.
