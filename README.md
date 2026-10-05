# MISE Marena

Cópia independente do MISE oficial (`258918e9ba666854c21387774f27516a556fc989`), preparada para a Marena. Compartilha o Supabase `hneehjanflbyajrpsdpf` com [marena.orkestri](https://github.com/ikeguimaraes-dot/marena.orkestri).

## Execução

Use Node.js 22 ou superior. Copie `.env.example` para `.env.local` e preencha as chaves do projeto Marena. A service-role é exclusivamente de servidor e nunca deve ter prefixo `NEXT_PUBLIC_`.

```sh
npm ci
npm run dev
```

O aplicativo usa http://localhost:3009. Para produção: `npm run build && npm start`. Configure as três variáveis do exemplo no provedor de hospedagem. Nenhum deploy foi realizado.

## Banco compartilhado

As migrações deste repositório são complementares: dependem da estrutura inicial de `marena.orkestri/supabase/migrations`. Não execute estas migrações isoladamente em um banco vazio. No projeto Marena informado, ambas já foram aplicadas e registradas.

Foram adicionadas 18 tabelas ausentes na primeira cópia, 17 colunas e três conversões de pontuação para numeric, com constraints, índices e triggers necessários. As novas tabelas têm RLS habilitado e acesso de dados somente pelo servidor com service-role. O bucket privado `checklist-photos` foi criado vazio, limite 10 MB, formatos JPEG/PNG/WebP/HEIC. Fotos são servidas por uma rota autenticada, preservando a privacidade do bucket.

Nenhum cliente, funcionário, usuário, PIN, sessão, fornecedor, ingrediente, checklist, relatório ou arquivo da origem foi importado. Permanecem apenas os cadastros técnicos Marena criados na etapa anterior (grupo e perfis). Prévia visual e testes usam exemplos fictícios; não são sementes de banco. Histórico Git, documentos de clientes, capturas de tela antigas e credenciais da origem foram excluídos. Cookie de sessão e armazenamento local possuem namespace Marena.

## Pendências para operar

- Expor `mise` e `opx` na Data API depende da autorização solicitada ao proprietário. A revisão automática bloqueou essa ampliação de acesso na etapa anterior; não foi executada.
- O papel `service_role` ainda não tem USAGE/INSERT no schema/tabelas `opx`; habilitar apenas as permissões necessárias para os eventos quando autorizado. A emissão desses eventos permanece indisponível.
- Cadastrar unidades, primeiro administrador vinculado a `employees` e perfis, responsáveis e PINs novos. Nenhum usuário foi criado.
- Definir domínio/URLs de Auth e configurar integrações externas próprias da Marena. Nomes técnicos `KPH_*` e `/api/integrations/kph/` foram mantidos por compatibilidade; nenhuma credencial de integração foi copiada.

## Validação e limitações

`npm test` executa 11 testes de fluxo de extras e identidade visual. `npm run type-check` verifica TypeScript. Build de produção e TypeScript passaram. Smoke local: `/login` e `/pin-login` retornam 200; `/`, `/preview` e fotos redirecionam visitantes anônimos ao login. O banco compartilhado totaliza 296 tabelas com RLS, zero usuários Auth e zero arquivos de Storage. A cópia preserva os fluxos do código oficial; validação autenticada ponta a ponta depende das pendências acima.

A auditoria de dependências encontrou 5 avisos de severidade alta herdados. Os advisors do banco compartilhado também apontam funções herdadas com search_path mutável e execução por anon/authenticated; não houve alteração global de permissões neste trabalho. Consulte [search_path](https://supabase.com/docs/guides/database/database-linter?lint=0011_function_search_path_mutable) e [funções SECURITY DEFINER](https://supabase.com/docs/guides/database/database-linter?lint=0028_anon_security_definer_function_executable). Tabelas com RLS sem políticas são intencionais quando acessadas exclusivamente pelo servidor.
