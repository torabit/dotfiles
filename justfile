# 既定はレシピ一覧を出す
default:
    @just --list

# palette.json から設定ファイルを生成する
build:
    node build/render.mjs

# 生成物がテンプレートと一致するか検証する
check:
    node build/render.mjs --check

# レンダラの単体テストを走らせる
test:
    node --test 'build/*.test.mjs'
