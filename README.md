heroku-pg-table-transfer
========================

Transfer Heroku Postgres databases or specific tables

Code referenced from [https://github.com/heroku/heroku](https://github.com/heroku/heroku) & [https://github.com/ddollar/heroku-pg-transfer](https://github.com/ddollar/heroku-pg-transfer)

# Installation

```
$ heroku plugins:install https://github.com/kitwalker12/heroku-pg-table-transfer
```

# Usage

```
$heroku pg:transfer_tables
  -f, --from DATABASE  # source database, defaults to DATABASE_URL on the app
  -t, --to   DATABASE  # target database
  --tables tables # comma-separated list of tables

$ env FROM_URL=postgres://localhost/myapp-development TO_URL=postgres://heroku.com/herokudb heroku pg:transfer_tables --tables my_tables

$ source .env && heroku pg:transfer_tables --from $FROM_URL --to $TO_URL --tables my_tables
```
