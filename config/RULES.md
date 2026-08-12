# Rules

## Bancos de dados em produção — proibições absolutas

Nunca executar, em nenhuma circunstância:

- `DROP DATABASE` / `DROP TABLE` / `DROP SCHEMA` / `TRUNCATE TABLE`
- `DELETE FROM` ou `UPDATE` sem cláusula `WHERE`
- `ALTER TABLE ... DROP COLUMN`, `MODIFY COLUMN` com perda, `RENAME TABLE`
- `DROP INDEX` / `DROP CONSTRAINT`; desativar triggers, constraints ou checks
- `GRANT` / `REVOKE`; `CREATE`/`DROP`/`ALTER USER`; alterar senhas ou roles
- `SHUTDOWN` / `RESTART`; `SET GLOBAL` / `ALTER SYSTEM`
- Backup/restore (`pg_dump`, `pg_restore`, `mysqldump`) fora de pipeline aprovada
- Stored procedures desconhecidas ou não documentadas
- Migração de dados entre ambientes; scripts de "correção em massa"
- Usar credenciais `root`/`sa`/`postgres` ou equivalentes

## Exigem aprovação humana explícita antes de executar

- `ALTER TABLE ... ADD COLUMN/INDEX/CONSTRAINT`, `CREATE INDEX`, `CREATE TABLE`
- `UPDATE` com `WHERE` afetando >10 registros; `DELETE` com `WHERE` afetando >1
- `INSERT` em tabelas de configuração ou lookup
- `ANALYZE`/`VACUUM`/`REINDEX` fora de horário de pico; `KILL`/`TERMINATE` de queries
- `EXPLAIN ANALYZE` em tabelas >1M registros

Procedimento: apresentar query completa, tabelas, estimativa de linhas, motivo e
impacto; aguardar confirmação explícita; registrar o ticket.

## Escalonamento — parar e consultar o usuário quando

- Erro inesperado, deadlock ou lock wait timeout
- Tempo de execução >2x o esperado; linhas afetadas divergem >20% da estimativa
- Ambiente não saudável (replica lag, CPU >80%)
- Dúvida sobre semântica ou solicitação ambígua/incompleta

Quando em dúvida, pare. Nenhuma automação vale mais que a integridade dos dados.
