# bball-postgres-bld-etl
- ### run bld.sh to build & load bball postgres database
- ### edit main.go then go run ./pgbld to run etl for many seasons into existing db 
- ### build/season run of etl package - [github.com/jdetok/bball-etl-go](https://github.com/jdetok/bball-etl-go)
- ### database is built on docker compose up with .sql files in sql directory
- ### pgbld directory contains go code to insert many nba/wnba seasons of game logs into database (config in .env)

