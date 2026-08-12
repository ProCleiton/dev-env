# AGENTS.md — Workspace 
---

## 1. Oriente-se no projeto alvo

1. `openspec/` — a maioria usa este workflow.
2. `pom.xml`/`package.json` — manifesto é a fonte da verdade.
3. `.gitlab-ci.yml` — comandos reais de build/test.
4. `README.md` — contexto de negócio.

## 2. Convenções
- **Build Java**: `./mvnw -s settings.xml` (Nexus interno, depende de VPN);
  intranet usa Ant.
- **CI**: GitLab self-hosted, Harbor `harbor.nordestefomento.com.br`.
- **Branches**: `master` ou `main` — conferir com `git branch --show-current`.
- **Frontends**: subpastas (`frontend/`, `frontend-lit/`), Lit+Vite ou Angular,
  `npm run build`.
- **Timezone containers**: `America/Fortaleza`.
- **Version managers são a fonte da verdade de runtimes** (projetos rodam em
  versões distintas — nunca assumir a versão global):
  - **Java**: SDKMAN (`SDKMAN_DIR`, `SDKMAN_CANDIDATES_*`) — `sdk list java` /
    `sdk use java <versão>`; conferir `.sdkmanrc` do projeto.
  - **Node**: nvm (`NVM_DIR=/home/dev/.nvm`) — `nvm ls` / `nvm use <versão>`;
    conferir `.nvmrc` do projeto. Instaladas: v16.20.2, v18.20.8, v20.10.0,
    v22.11.0 (default), v22.14.0.
  - **Python**: pyenv/venv do projeto, quando presente.
  - Bun disponível (`BUN_INSTALL`), mas só usar se o projeto já o usar.
- **Telemetria**: `OPENSPEC_TELEMETRY` e `RTK_TELEMETRY_DISABLED` já declaradas
  no `~/.bashrc` — respeitar, não reconfigurar nem sobrescrever.
- **Ignorar vars `PI_*`** (`PI_WORKSPACE`, `PI_WORKFLOW_GATE_PROD_HOSTS`):
  pertencem a um workflow legado em `/NFI-BAK`, não se aplicam a este harness.

## 3. Princípios de engenharia
- **Simplicidade**: use o ecossistema do projeto antes de novas abstrações.
- **Causa raiz**: nada de workarounds escondidos; se inevitável, sinalizar.
- **Nunca expor segredos** em código, logs, respostas ou mensagens.
- **Credenciais**: quando uma tarefa precisar, buscar nas env vars declaradas
  em `~/.bashrc` (ex.: `grep -o 'export [A-Z_]*' ~/.bashrc` para listar nomes;
  `source ~/.bashrc` ou `env` para resolver). **Usar sem imprimir valores** —
  reportar apenas o nome da variável encontrada/ausente.
- Operações longas via **NATS** (assíncrono), não endpoints síncronos.
- **Um serviço escreve por tabela** — não escrever na base de outro.
- APIs externas pagas: limites diários, registro de uso, persistência local+DB.
- Frontend separado do backend (Lit ou Angular), Docker independente.

## 4. Fluxo de trabalho 
- Não-trivial (3+ etapas ou decisão arquitetural): **plano numerado** aprovado
  antes de codificar.
- Branches protegidas — **nunca** push direto em master/main.
- Commit/push em `fix/`/`feat/`/`issue-*` SÓ com autorização explícita.
- Deploy é do usuário (`docker stack deploy`) — **nunca executar, mesmo com
  autorização**.
- Issues fecham manualmente pelo usuário.

## 5. Cuidados
- `mvn test` não garante nada — verifique o que existe antes de confiar.
- Certificados digitais versionados — não mover nem regenerar.
- Legados (Java 8, Zuul, log4j 1.x, Jersey 1.x) — não modernizar como bônus.
- Deps internas (`NFSYS-DB`, `NFSYS-UTILS`) do Nexus — não "corrigir".
- Ignorar `graphify-out/`, `ia-reviews/`, `target/`, `dist/`, `www/`.
- Diretórios não-git são materiais operacionais — não tratar como codebase.

## 6. Testes
- Siga a infra de testes existente no projeto (JUnit, Vitest, Playwright...).
- Não crie framework do zero sem alinhar com o usuário.
- Cobertura por risco, não por assertiva (diretriz 25/07).

## 7. Validação
1. Build com comando do `.gitlab-ci.yml` (`./mvnw -s settings.xml clean install`).
2. Rode os testes existentes sem assumir cobertura.
3. Respeite a política de branches.

## 8. RTK (obrigatório — economia de tokens)
A extensão `~/.omp/agent/extensions/rtk.ts` reescreve comandos bash
automaticamente para o equivalente RTK. Todo comando com saída volumosa
passa pelo RTK — lista canônica: `rtk --help` (`rtk err`, `rtk test`,
`rtk git`, `rtk psql`, `rtk find`, etc.). Economia auditável: `rtk gain`.
Exceções: tool `read` nativa para leitura precisa de edição; saída completa
quando necessária à decisão; operações destrutivas.
Fallbacks: `rtk tree` depende do binário nativo `tree` — se falhar com
"tree command not found", use `rtk find <dir>` (ou `-type d` p/ só
diretórios) ou `rtk ls <dir>`; nunca instale nada por conta própria,
sinalize ao usuário.

## 9. OpenSpec (CLI)
`openspec list` / `show` / `validate` antes de propor mudança. Change =
proposal + tasks + deltas de spec (WHEN/THEN). Archive com autorização:
`openspec archive <change> --skip-specs -y` + push `-o ci.skip` e `[ci skip]`
(o push segue a regra da seção 4: só com autorização explícita).
Nunca renomear scenarios em deltas MODIFIED.

**Processo de documentação (delegar ao agente `task`):**
- Change fechada (merge), sobretudo feature nova → **atualizar `openspec/specs/`**
  para não defasar (validar contra o código real).
- `openspec/changes/archive/`: retenção máxima de **2 semanas**; acima disso
  o diretório da change é **excluído**. Problema que retorna = change nova,
  nunca restauração de archive.
  
---

## 10. DBA — contexto operacional de produção

As proibições e gatilhos de escalonamento estão no `RULES.md` (sticky).
Aqui fica o background, carregado uma vez por sessão:

- **Permitido sem aprovação** (sempre com log): `SELECT`, `EXPLAIN` sem
  `ANALYZE`, `SHOW`, `pg_stat_activity`, `INFORMATION_SCHEMA`, `pg_catalog`,
  verificação de locks/índices/tamanhos.
- **Auditoria**: toda query em produção é registrada com timestamp UTC, query,
  banco/schema, linhas afetadas, tempo, ticket e aprovador. Tentativas de
  operação proibida são sinalizadas ao usuário imediatamente.
- **Contingência**: antes de operação aprovada, confirmar backup válido (<24h),
  snapshot quando aplicável e rollback definido. Executar em transação com
  `autocommit` desligado; abortar se exceder o threshold combinado. Após:
  verificar integridade, índices e constraints.
- **Dados sensíveis**: nunca exportar PII para fora do ambiente; mascarar
  colunas sensíveis em resultados; temporários criptografados e removidos em
  até 24h. LGPD/GDPR se aplicam.
- **Janelas**: operações aprovadas só dentro de janela de manutenção; fora do
  horário comercial, somente com aprovação explícita do DBA on-call.
- **Comunicação**: ao reportar operações, incluir ticket, query, linhas
  afetadas e tempo; linguagem não técnica para stakeholders.
- **Credenciais de agente**: usuários dedicados com prefixo `agent_` e role
  restrita; nunca acesso simultâneo a produção e homologação na mesma sessão.

## 11. LSP, npm global e providers — convenções operacionais

- **LSP depende do cwd da sessão**: servidores só carregam quando a sessão é
  aberta **dentro** do projeto (rootMarkers `pom.xml`/`package.json` no próprio
  cwd — sem busca em ancestrais). Sessão na raiz do workspace **não tem LSP**.
  Padrão: `cd <projeto> && omp` ou `omp --cwd <projeto>`. Servidores instalados:
  jdtls (wrapper `~/.local/bin/jdtls-wrapper`, JVM SDKMAN 21 fixa) e
  typescript-language-server (pi-node). Config em `~/.omp/agent/lsp.json`.
- **npm global cai no pi-node, não no nvm**: o `node`/`npm` do PATH é o do pi
  (`~/.local/share/pi-node/...`); `npm i -g` instala lá, mesmo com `nvm use`.
  Use caminhos absolutos do pi-node em configs (lsp.json já usa). Não esperar
  binário global sob `~/.nvm/versions/...`.
- **Providers kimi têm ids por layer** (mesmo serviço, registries diferentes):
  harness omp = `kimi-code/*` (ex.: `kimi-code/k3`, `kimi-code/kimi-for-coding`);
  layer pi (`~/.pi/agent/settings.json`, pi-acp/CodeCompanion) = `kimi-coding/*`
  (ex.: `kimi-coding/k3`). Não misturar ao editar modelo do layer errado.
- **gitlab-duo desabilitado** (`disabledProviders` no config.yml): sem
  credenciais (GITLAB_TOKEN/oauth) o probe 401 falha ruidosamente em CLI
  headless; reabilitar somente após configurar auth.
- **Sessões pi acumulam** (`~/.pi/agent/sessions/`): reter ~14 dias; mais
  antigas podem ser arquivadas (tar.gz) — sessões arquivadas perdem resume
  via pi-acp.
