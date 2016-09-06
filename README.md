# API da Landing Page - Fora da escola não pode!

Este projeto é o back-end para a landing-page de recebimento de alerga por agentes.

## Instalação

Para a instalação para desenvolvimento, observe os seguintes requisitos:

* Ruby 2.2.3

Para instalar as dependências, utilize o bundler:

    bundle install

## Configuração

Para configurar o projeto observe as seguintes variáveis:

* `RACK_ENV` - environment para rodar o projeto: `development/production/test`
* `ZUP_API_URL` - URL completa onde está rodando a API do ZUP
* `ZUP_API_TOKEN` - Token para autenticação na API
* `ZUP_API_REPORT_ID` - ID da categoria de relato
* `ZUP_API_FLOW_ID` - ID do fluxo para cadastro do caso
* `ZUP_API_STEP_ID` - ID da primeira etapa
* `ZUP_API_CHILD_NAME_FIELD_ID` - ID do campo do nome da criança
* `ZUP_API_CHILD_MOTHER_NAME_FIELD_ID` - ID do campo do nome da mãe da criança
* `ZUP_API_CHILD_BIRTHDAY_FIELD_ID` - ID do campo aniversário da criança
* `ZUP_API_ABANDON_CAUSE_FIELD_ID` - ID do campo de abandono de causa

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
