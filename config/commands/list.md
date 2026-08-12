---
description: Lista registros do banco mnemopi (pendencia/licao/config/segredo-ref) com filtros
---

Execute `mem list $ARGUMENTS` (via `rtk` se a saída for longa) e apresente o resultado ao usuário em tabela legível.

Exemplos de uso do comando:
- `/list pendencia` — pendências por importância+data
- `/list licao --pinned` — só lições fixadas
- `/list config --tag swarm` — configs com tag
- `/list pendencia --since 2026-08-01 --order data`

Se o usuário passar argumentos que não são do `mem list` (ex.: texto livre), use `mem search "<texto>"` em vez disso.
