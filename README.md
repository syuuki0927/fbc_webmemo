# Web memo

## How to use
### bundleのインストール
```
bundle install
```

### DBの準備
```
# postgreSQLにユーザーpostgresを作成
psql -Upostgres
# prepareDBを実行
./prepareDB_Table.sh
```

### アプリの実行
```
bundle exec ruby myapp.rb
```
