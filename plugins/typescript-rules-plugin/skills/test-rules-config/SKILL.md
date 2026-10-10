---
name: test-rules-config
description: テストルール設定ファイル（.test-rules.yml）を対話的に作成・更新するスキル。describe禁止・条件分岐禁止・ファイル命名規則の有効/無効を設定する。
user-invocable: true
---

# テストルール設定ファイル生成

プロジェクトのテストルール設定ファイル `.test-rules.yml` を対話的に作成・更新する。

## 設定可能なルール

| ルールキー | 説明 | デフォルト |
|:--|:--|:--|
| `no-describe` | describe/context/suite の使用を禁止 | `true` |
| `no-conditional` | テストコード内の if/else/switch を禁止 | `true` |
| `file-naming` | `{対象名}.{カテゴリ}.test.ts\|tsx` の命名規則を強制 | `true` |

## 実行手順

### 1. 配置先の決定

以下の順序で `.test-rules.yml` の配置先を決定する。

1. ユーザーが引数でパスを指定した場合 → そのパスを使用
2. 既存の `.test-rules.yml` が `{プロジェクトルート}/.plugin-workspace/testing/` にある場合 → そのファイルを更新
3. 既存の `.test-rules.yml` がプロジェクト内にある場合 → そのファイルを更新（後方互換）
4. いずれもない場合 → `{プロジェクトルート}/.plugin-workspace/testing/.test-rules.yml` に新規作成（ディレクトリがなければ作成）

### 2. 既存設定の確認

配置先に `.test-rules.yml` が既に存在する場合、現在の設定内容を読み取り、ユーザーに表示する。

### 3. ルールの選択

ユーザーに各ルールの有効/無効を確認する。質問形式の例:

```
以下のテストルールを設定します。無効にしたいルールはありますか？

1. no-describe: describe/context/suite の使用禁止（現在: 有効）
2. no-conditional: テスト内の条件分岐禁止（現在: 有効）
3. file-naming: ファイル命名規則の強制（現在: 有効）

すべてデフォルト（全て有効）でよければ「OK」と回答してください。
```

### 4. ファイルの生成

設定内容に基づいて `.test-rules.yml` を生成する。

#### 全てデフォルト（全ルール有効）の場合

```yaml
# テストルール設定
# 各ルールを false にすると該当チェックを無効化できます
# ファイル単位の無効化: テストファイル先頭に // @test-rules-disable [ルール名] を記述
rules:
  no-describe: true
  no-conditional: true
  file-naming: true
```

#### 一部無効化した場合（例: describe を許可）

```yaml
# テストルール設定
# 各ルールを false にすると該当チェックを無効化できます
# ファイル単位の無効化: テストファイル先頭に // @test-rules-disable [ルール名] を記述
rules:
  no-describe: false
  no-conditional: true
  file-naming: true
```

### 5. ユーザーへの確認

生成内容と配置先をユーザーに提示し、承認を得てから書き込む。

### 6. 完了報告

書き込み完了後、以下を報告する:

- 配置先のパス
- 各ルールの設定状態
- ファイル単位の無効化方法（`// @test-rules-disable [ルール名]`）
