# CLAUDE.md

## リポジトリ概要

**d-market-lang** は言語・フレームワーク別の開発ルールを提供する Claude Code プラグインのマーケットプレイスリポジトリである。

Rust / TypeScript / React など、言語ごとのルール・ワークフロー・hooks 系プラグインを 1 か所に集約している。アプリケーションのソースコードは含まず、プラグイン定義（スキル、エージェント、hooks）のみで構成される。

## 提供プラグイン

| 言語 | プラグイン | 概要 |
|:--|:--|:--|
| Rust | `rust-rules-plugin` | コーディング規約、TDD、テスト規約、実装ワークフローなど Rust 開発の基本ルール |
| Rust | `rust-workflow-plugin` | テスト実行・型チェック・ファイル検索をエージェント経由で実行するワークフロー |
| Rust | `rust-hooks-plugin` | `.rs` ファイル編集後の `rustfmt`/`cargo clippy` チェックと、`git push` 前の品質チェック |
| TypeScript | `typescript-rules-plugin` | 実装ワークフロー、コーディング規約、TDD、テスト、コードレビュー、品質チェック hooks |
| React | `react-rules-plugin` | コンポーネント、カスタムフック、Storybook の開発ルール |

## リポジトリの構成

- `plugins/` 配下に各プラグインを格納
- プラグイン名は `<言語>-<種別>-plugin` の形式とする（例: `rust-rules-plugin`）
- 各プラグインは `plugin.json`、`skills/`、必要に応じて `agents/`・`hooks/`・`scripts/` を持つ
- `.claude-plugin/marketplace.json` がマーケットプレイス全体の定義

## 開発ルール

- プラグインのスキルは `skills/<スキル名>/SKILL.md` に記述する
- エージェントは `agents/<エージェント名>.md` に記述する
- 新しい言語・プラグイン・スキルを追加した場合は `marketplace.json` と `README.md` を更新する
- hooks のスクリプトは実行権限を付与する
- ドキュメントは日本語で記述する
