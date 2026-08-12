# dev-env

Instalador autocontido do ambiente de desenvolvimento baseado no harness
[Oh My Pi](https://github.com/can1357/oh-my-pi) (`omp` + `pi`): verifica o
ambiente, instala runtimes e servidores LSP, configura variáveis, plugins e
skills — com helpers de configuração.

Licença: [MIT](LICENSE) · Créditos: [CREDITS.md](CREDITS.md)

## Instalação (como o oh-my-pi)

```bash
curl -fsSL https://raw.githubusercontent.com/ProCleiton/dev-env/main/install.sh | bash
```

O script baixa o repositório, verifica o ambiente e instala:

| Componente | O que faz |
|---|---|
| runtimes | SDKMAN (Java 8/17/21/25), nvm (Node 22), bun |
| harness | `omp` (@oh-my-pi/pi-coding-agent), `pi` (@earendil-works/pi-coding-agent) |
| LSP | jdtls (Eclipse JDT LS) + typescript-language-server |
| plugins | marketplaces + plugins do omp (code-review, security-guidance, commit-commands) |
| configs | `~/.omp/agent/{config.yml,lsp.json,mcp.json,AGENTS.md,RULES.md,commands,skills}`, `~/.pi/agent/settings.json`, `mem` CLI |

Flags do instalador:

```bash
curl -fsSL https://raw.githubusercontent.com/ProCleiton/dev-env/main/install.sh | bash -s -- --verify-only   # só verifica
curl -fsSL .../install.sh | bash -s -- --configure-only  # só reaplica configs
curl -fsSL .../install.sh | bash -s -- --no-langs --no-lsp  # pula componentes
```

## CLI `dev-env`

Após instalar, um comando `dev-env` fica disponível em `~/.local/bin`:

```bash
dev-env verify      # tabela de verificação do ambiente (OK/—)
dev-env status      # versões dos componentes
dev-env install     # re-executa o instalador (mesmas flags)
dev-env configure   # reaplica as configurações do repo
dev-env env         # template de variáveis para o ~/.bashrc
dev-env update      # atualiza o repo (git pull)
dev-env uninstall   # remove binários (configs preservadas)
```

## Verificação do ambiente

`dev-env verify` checa: SO/arquitetura, ferramentas base (curl/git/tar/python3/
jq/bun/npm/node), gerenciadores (sdkman/nvm/pi-node), harness (omp/pi/mem/
config.yml/lsp.json) e servidores LSP (jdtls/tsserver/rust-analyzer). Suporta
`dev-env verify --json` para consumo programático.

## Variáveis de ambiente

Rode `dev-env env` e adicione ao `~/.bashrc` (ajuste os valores):

```bash
export GRAYLOG_URL="https://graylog.exemplo.com"
export GRAYLOG_TOKEN="coloque-seu-token"
```

O `mcp.json` usa `${GRAYLOG_URL}`/`${GRAYLOG_TOKEN}` (substituídos pelo shell).
Providers de modelo (ex.: opencode-go) são configurados no `~/.omp/agent/config.yml`.

## Estrutura

```
dev-env/
├── install.sh            # bootstrap curl|bash
├── scripts/
│   ├── install.sh        # instalador principal (flags)
│   ├── verify.sh         # verificação de ambiente
│   ├── install-langs.sh  # SDKMAN/nvm/bun
│   ├── install-lsp.sh    # jdtls + typescript-language-server
│   ├── install-plugins.sh# marketplaces/plugins omp
│   ├── configure.sh      # aplica configs (com backup)
│   ├── helpers.sh        # funções comuns
│   └── dev-env           # CLI
├── config/               # configurações de referência (templates)
├── bin/mem               # CLI de consulta ao banco mnemopi
└── CREDITS.md, LICENSE
```

## Observações

- **LSP por cwd**: os servidores LSP só carregam em sessão aberta dentro do
  projeto (rootMarkers no cwd) — use `cd <projeto> && omp`.
- **npm global**: `npm i -g` instala no node gerenciado do pi (não no nvm);
  o lsp.json usa caminhos absolutos reais.
- **Providers kimi**: omp usa `kimi-code/*`; layer pi usa `kimi-coding/*`.
- **gitlab-duo** fica desabilitado por padrão (sem credenciais → 401 ruidoso).
- Os configs de referência (`AGENTS.md`, `RULES.md`) refletem o ambiente de
  origem — ajuste para o seu contexto após instalar.
