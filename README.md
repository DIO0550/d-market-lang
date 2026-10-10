# d-market-lang

言語・フレームワーク別の開発ルールを提供する Claude Code プラグインのマーケットプレイスリポジトリ。

これまで言語ごとに分かれていたマーケットプレイス（`d-market-rust` / `d-market-typescript` / `d-market-react`）のプラグインを 1 か所に集約している。

## インストール

```
/plugin marketplace add DIO0550/d-market-lang
/plugin install <プラグイン名>@d-market-lang
```

## プラグイン一覧

| 言語 | プラグイン | 概要 |
|:--|:--|:--|
| Rust | `rust-rules-plugin` | コーディング規約、TDD、テスト規約、実装ワークフローなど Rust 開発の基本ルール |
| Rust | `rust-workflow-plugin` | テスト実行・型チェック・ファイル検索をエージェント経由で実行するワークフロー |
| Rust | `rust-hooks-plugin` | `.rs` 編集前のスキル発火強制、編集後の `rustfmt`/`cargo clippy`、`git push` 前の品質チェック |
| TypeScript | `typescript-rules-plugin` | 実装ワークフロー、コーディング規約、TDD、テスト、コードレビュー、品質チェック hooks |
| React | `react-rules-plugin` | コンポーネント、カスタムフック、Storybook の開発ルール |

## Rust

### rust-rules-plugin

Rust 開発における基本ルールを定義するプラグイン。

| スキル | 説明 |
|:--|:--|
| `implementation-workflow` | 実装フローのエントリーポイント。ブランチ運用、TDD サイクル、品質チェックの流れを定義 |
| `coding-standards` | コーディング規約。所有権・借用、エラーハンドリング、命名規則、不変性、並行・非同期、lint 抑制、設計ガイドライン（振る舞いの配置・型変換・重複排除。詳細は `references/design-guidelines.md`） |
| `tdd` | TDD Red-Green-Refactor サイクルのルール |
| `testing` | 単体テスト・統合テストの規約。テスト構造、モック方針、テストピラミッド |
| `setup` | プロジェクトの指示ファイルにスキル活用ガイドを追記するセットアップ |

### rust-workflow-plugin

Rust プロジェクトの操作をエージェント経由で実行するワークフロープラグイン。

| スキル | 説明 |
|:--|:--|
| `test` | `cargo test` によるテスト実行（エージェント経由） |
| `type-check` | `cargo check` による型チェック・コンパイル確認（エージェント経由） |
| `file-search` | Rust ファイル・シンボル検索（エージェント経由） |
| `setup` | プロジェクトの指示ファイルにワークフロースキル活用ガイドを追記するセットアップ |

| エージェント | 説明 |
|:--|:--|
| `test-agent` | テスト実行・結果解析を担当 |
| `type-check-agent` | 型チェック・コンパイルエラー解析を担当 |
| `file-search-agent` | ファイル名・コード・シンボル検索を担当 |

### rust-hooks-plugin

Rust ファイル編集後に品質チェックを自動実行する hooks プラグイン。

| hooks イベント | トリガー | 実行内容 |
|:--|:--|:--|
| `PreToolUse` | Edit / Write で `.rs` ファイルを編集する直前 | `rust-rules-plugin` の実装ルールスキル（`implementation-workflow` / `coding-standards` / `tdd` / `testing`）が全て発火済みかを確認し、未発火なら編集をブロック |
| `PostToolUse` | Write / Edit で `.rs` ファイルを変更 | `rustfmt --check` でフォーマット検査、`cargo clippy` で lint チェック（エラーは Claude にフィードバック） |
| `PostToolUse` | `rust-rules-plugin:*` スキル発火 | スキル発火マーカーをセッションごとに記録 |
| `PreToolUse` | Bash で `git push` を実行 | `cargo fmt --all -- --check` と `cargo clippy -- -D warnings` を実行し、エラーがあれば push をブロック（Cargo プロジェクト以外ではスキップ） |

## TypeScript

### typescript-rules-plugin

TypeScript 開発における基本ルール・レビュー・品質チェックを定義するプラグイン。

| スキル | 説明 |
|:--|:--|
| `implementation-workflow` | 実装フローのエントリーポイント。品質チェック（テスト・lint・型チェック）とブランチ運用を定義 |
| `coding-standards` | コーディング規約。早期 return、型定義、null/undefined、モジュール設計、不変性、命名規則、エラーハンドリング、非同期処理 |
| `tdd` | t-wada 式 Red-Green-Refactor サイクル、三角測量、ベイビーステップ |
| `testing` | 単体テスト規約。フラット構造（describe 不使用）、モック使用制限、パラメータ化テスト（Vitest/Jest 対応） |
| `test-rules-config` | テストルール設定ファイル（`.test-rules.yml`）を対話的に作成・更新 |
| `eslint-setup` | `coding-standards` に対応する ESLint 公式ルールをプロジェクトに導入 |
| `code-similarity-ts` | similarity-ts を使ったコード重複検出とリファクタリング計画 |
| `typescript-code-review-skill` | 命名規則・テストコード品質・コメント意図/防御的コードの 3 観点でコードレビュー |
| `typescript-performance-review-skill` | 測定ファーストの観点でフロントエンド・バックエンド・API のパフォーマンスをレビュー |
| `rules-setup` | プロジェクトの指示ファイルにスキル活用ガイドを追記するセットアップ |

| エージェント | 説明 |
|:--|:--|
| `typescript-naming-reviewer` | 命名規則への準拠をレビュー |
| `typescript-test-reviewer` | テストコードの品質・構造・網羅性をレビュー |

| hooks イベント | トリガー | 実行内容 |
|:--|:--|:--|
| `PreToolUse` | Bash | `npx` / `pnpm dlx` の使用をブロック。`git push` 前に型チェック・lint・JSDoc・テストルールを検証 |
| `PreToolUse` | Edit / Write | `.ts`/`.tsx` 編集前のスキル発火を強制。lint 抑制コメントの追加をブロック |
| `PostToolUse` | Write / Edit | 編集後の自動 lint、テストルール検証、JSDoc ルール検証 |
| `PostToolUse` | Skill | スキル発火マーカーをセッションごとに記録 |

## React

### react-rules-plugin

React 開発のルールを定義するプラグイン。TypeScript の基本ルールは `typescript-rules-plugin` と併用する。

| スキル | 説明 |
|:--|:--|
| `component` | 関数コンポーネント、レンダーの純粋性、Props/State 設計、アクセシビリティ、パフォーマンス、React 19、Testing Library |
| `custom-hook` | hook に切り出す基準、API 設計、effect の使いどころ、テスト観点、アンチパターン |
| `storybook` | CSF3.0、Meta/StoryObj 型、Story の種類、argTypes/decorators、play function によるインタラクションテスト |

## ディレクトリ構成

```
d-market-lang/
├── .claude-plugin/
│   └── marketplace.json    # マーケットプレイス定義
├── plugins/
│   ├── rust-rules-plugin/
│   ├── rust-workflow-plugin/
│   ├── rust-hooks-plugin/
│   ├── typescript-rules-plugin/
│   └── react-rules-plugin/
├── CLAUDE.md
├── README.md
└── LICENSE
```

各プラグインは `plugin.json`、`skills/`、必要に応じて `agents/`・`hooks/`・`scripts/` を持つ。

## ライセンス

MIT
