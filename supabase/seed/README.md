# Broken Oath - Seeds Oficiais

Esta pasta contém os dados iniciais necessários para criar um novo mundo do Broken Oath.

## Objetivo

Os arquivos desta pasta **não alteram a estrutura do banco de dados**.

A estrutura é criada pelas **migrations**.

Os seeds apenas inserem os dados fixos necessários para que um mundo possa funcionar.

---

# Ordem de execução

Os arquivos devem ser executados exatamente nesta ordem:

```text
01_worlds.sql
02_mapa_coordenadas.sql
03_regioes_fundacao.sql
04_cidades.sql
05_locais_mapa.sql
06_cidade_governanca.sql