# API da Landing Page - Fora da escola não pode!

Este projeto é o back-end para a landing-page de recebimento de alerga por agentes.

## Instalação

Para a instalação para desenvolvimento, observe os seguintes requisitos:

* Ruby 2.2.3

Para instalar as dependências, utilize o bundler:

    bundle install

## Configuração

Primeiro, copie o arquivo `sample.env` para o arquivo `.env` e configure as seguintes variáveis:

* `RACK_ENV` - environment para rodar o projeto: `development/production/test`
* `ZUP_API_URL` - URL completa onde está rodando a API do ZUP
* `ZUP_API_TOKEN` - Token para autenticação na API
* `ZUP_API_REPORT_ID` - ID da categoria de relato
* `ZUP_API_CHILD_NAME_FIELD_ID` - ID do campo do nome da criança
* `ZUP_API_CHILD_MOTHER_NAME_FIELD_ID` - ID do campo do nome da mãe da criança
* `ZUP_API_CHILD_BIRTHDAY_FIELD_ID` - ID do campo aniversário da criança
* `SENTRY_URL` - a DSN de sua instância do [Sentry](https://sentry.io)
* `DATABASE_URL` - A URL para o banco de dados no Postgres
* `ZENVIA_SHORTCODE` - O shortcode para ser utilizado na integração com a Zenvia
* `ZENVIA_AUTH` - O código de autorização da API para integração com a Zenvia
* `ZENVIA_FROM` - O nome que irá para a conversa (integração com a Zenvia)

Altere o token para cookies seguros em `/config/initializers/secret_token.rb`.

## Execução

Para iniciar o servidor, você pode executar o `rackup` na raíz do projeto:

   rackup

## Contribuição

Para contribuir, siga os seguintes passos:

1. Crie uma branch a partir do `master`
1. Faça seu desenvolvimento
1. Faça o rebase da sua branch com o master
1. Adicione a alteração no arquivo `CHANGELOG.md`
1. Abra um Merge Request para o master, com uma descrição completa do que foi desenvolvido e o porquê
1. Aguarde Code Review e o merge
