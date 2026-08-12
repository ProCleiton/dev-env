# CREDITS

Este projeto agrega e configura as seguintes ferramentas de terceiros. Cada
componente mantém sua própria licença; este repositório (scripts/configs) é MIT.

## Harness e agentes

| Projeto | Autor | Licença | Uso |
|---|---|---|---|
| [oh-my-pi (pi-coding-agent)](https://github.com/can1357/oh-my-pi) | can1357 | MIT | harness `omp` — sessão, ferramentas, subagentes |
| [pi-coding-agent](https://github.com/earendil-works/pi) | earendil-works | Apache-2.0 | agente base `pi` (modo rpc/ACP) |
| [pi-acp](https://github.com/svkozak/pi-acp) | svkozak | MIT | adapter ACP do pi (CodeCompanion/Zed) |
| [pi-subagents](https://github.com/…/pi-subagents) | — | MIT | extensão de subagentes do pi |
| [pi-sakana-provider](https://github.com/…/pi-sakana-provider) | — | MIT | provider de modelos |
| [pi-mcp-adapter](https://github.com/…/pi-mcp-adapter) | — | MIT | adapter MCP |

## Editores / Neovim

| Projeto | Autor | Licença | Uso |
|---|---|---|---|
| [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim) | olimorris | Apache-2.0 | chat com agentes ACP |
| [lazy.nvim](https://github.com/folke/lazy.nvim) | folke | Apache-2.0 | gerenciador de plugins |
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | nvim-treesitter | Apache-2.0 | syntax highlighting |
| [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects) | nvim-treesitter | Apache-2.0 | text objects |
| [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) | lewis6991 | MIT | diff no gutter |
| [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | nvim-neo-tree | MIT | explorador de arquivos |
| [render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim) | MeanderingProgrammer | MIT | render markdown |
| [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) | nvim-lua | MIT | dependência |
| [nui.nvim](https://github.com/MunifTanjim/nui.nvim) | MunifTanjim | MIT | dependência |
| [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons) | nvim-tree | MIT | ícones |

## Servidores LSP

| Projeto | Autor | Licença | Uso |
|---|---|---|---|
| [Eclipse JDT Language Server](https://github.com/eclipse-jdtls/eclipse-jdtls) | Eclipse Foundation | EPL-2.0 | LSP Java |
| [typescript-language-server](https://github.com/typescript-language-server/typescript-language-server) | typescript-language-server | Apache-2.0 | LSP TypeScript/JS |
| [rust-analyzer](https://github.com/rust-lang/rust-analyzer) | rust-lang | MIT/Apache-2.0 | LSP Rust |

## MCP e integrações

| Projeto | Autor | Licença | Uso |
|---|---|---|---|
| [mcp-server-graylog](https://github.com/…/mcp-server-graylog) | — | MIT | consultas Graylog via MCP |
| [playwright-mcp](https://github.com/microsoft/playwright-mcp) | microsoft | Apache-2.0 | automação de navegador |
| [chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | ChromeDevTools | Apache-2.0 | devtools MCP |

## Plugins e marketplaces do omp

| Projeto | Autor | Licença | Uso |
|---|---|---|---|
| [claude-plugins-official](https://github.com/anthropics/claude-plugins-official) | anthropics | Apache-2.0 | code-review, security-guidance, commit-commands |
| [superpowers-marketplace](https://github.com/obra/superpowers-marketplace) | obra | — | marketplace adicional |

## Runtimes e gerenciadores

| Projeto | Autor | Licença | Uso |
|---|---|---|---|
| [SDKMAN](https://sdkman.io) | SDKMAN | Apache-2.0 | gerenciador de JVMs (Java 8/17/21/25) |
| [nvm](https://github.com/nvm-sh/nvm) | nvm-sh | MIT | gerenciador de versões do Node |
| [bun](https://bun.sh) | Oven | MIT | runtime do `omp` |

## Ferramentas internas deste repo

| Ferramenta | Descrição |
|---|---|
| `mem` | CLI de consulta ao banco Mnemopi (list/search/stats) — MIT, deste repo |
| `rtk` | extensão de economia de tokens do harness — MIT, deste repo |

Se algum crédito estiver faltando ou incorreto, abra uma issue.
