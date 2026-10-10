---
name: eslint-setup
description: ESLintセットアップスキル。coding-standardsに対応するESLint公式ルールをプロジェクトに導入する。「ESLint設定」「リンター設定」「eslint setup」などのリクエスト時に使用。
disable-model-invocation: true
---

# ESLint セットアップスキル

coding-standardsのルールに対応するESLint公式ルール（ESLint core + @typescript-eslint）をプロジェクトに導入する。

## 制約

- ESLint core と `@typescript-eslint` のみ使用する
- サードパーティプラグインは使用しない

## 対応ルール一覧

以下の表をユーザーに提示し、導入するルールを選択してもらう。

| # | coding-standards のルール | ESLint ルール | デフォルト |
|:-:|:--|:--|:-:|
| 1 | if文に波括弧必須 | `curly` | ON |
| 2 | マジックナンバー禁止 | `no-magic-numbers` | ON |
| 3 | `any` 禁止 | `@typescript-eslint/no-explicit-any` | ON |
| 4 | 返り値の型明示 | `@typescript-eslint/explicit-function-return-type` | OFF |
| 5 | `const` 優先 | `prefer-const` | ON |
| 6 | ネスト深さ制限 | `max-depth` | ON |
| 7 | `readonly` 優先 | `@typescript-eslint/prefer-readonly` | OFF |

**デフォルト OFF の理由**:
- `explicit-function-return-type`: 既存コードへの影響が大きい場合がある
- `prefer-readonly`: type checker が必要で設定が追加で必要になる

## 実行手順

### 1. 既存設定の確認

プロジェクトルートで以下を確認する。

- `eslint.config.*` (flat config) の有無
- `.eslintrc.*` (legacy config) の有無
- `package.json` 内の `eslint` / `@typescript-eslint/*` の有無

### 2. ルール選択

対応ルール一覧をユーザーに提示し、以下を確認する。

- ON/OFF の変更があるか
- `max-depth` の値（デフォルト: 4）
- `no-magic-numbers` の `ignore` に追加したい値（デフォルト: `[0, 1, -1]`）
- `explicit-function-return-type` を有効にする場合、`allowExpressions` を true にするか

### 3. ESLint がインストールされていない場合

必要パッケージをユーザーに提示し、確認を得てからインストールする。

```
eslint
@typescript-eslint/parser
@typescript-eslint/eslint-plugin
typescript-eslint
```

### 4. 設定ファイルの生成

#### 既存の設定ファイルがある場合

既存ファイルにルールを追記する（従来通り）。

#### 新規作成の場合

2つのファイルを生成する。ルール定義を `{プロジェクトルート}/.plugin-workspace/linting/eslint-rules.mjs` に配置し、プロジェクトルートにはそこからインポートするプロキシを置く。`.plugin-workspace/linting/` ディレクトリがなければ作成する。

**`{プロジェクトルート}/.plugin-workspace/linting/eslint-rules.mjs`**（ルール定義 — ソースオブトゥルース）:

```javascript
export const pluginRules = {
  // ユーザーが選択したルールをここに記載
};
```

**`eslint.config.mjs`**（プロジェクトルート — プロキシ）:

```javascript
import tseslint from "typescript-eslint";
import { pluginRules } from "./.plugin-workspace/linting/eslint-rules.mjs";

export default tseslint.config(
  ...tseslint.configs.recommended,
  { rules: pluginRules },
);
```

`prefer-readonly` を有効にする場合は `parserOptions.project` の設定が必要であることをユーザーに伝える。

### 5. ユーザーへの確認

生成する設定ファイルの内容をユーザーに提示し、承認を得てから書き込む。

### 6. 動作確認

設定ファイル書き込み後、`npx eslint --max-warnings=0 .` を実行して動作を確認する。エラーが多すぎる場合はユーザーと相談して対応を決める。

### 7. 完了報告

有効にしたルール一覧を報告する。
