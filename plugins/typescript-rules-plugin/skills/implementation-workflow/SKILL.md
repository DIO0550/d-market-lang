---
name: implementation-workflow
description: TypeScript実装ワークフロースキル。新機能開発やバグ修正を開始する際のエントリーポイントとして、状況に応じて適切なスキルをSkillツールで実行させる。品質チェック（テスト・lint・型チェック）とブランチ運用を定義。TypeScriptの実装作業を行う際にSkillツールで実行すること。
user-invocable: false
---

# TypeScript実装ワークフロー

## 関連スキル実行ガイド

| 状況 | Skill ツールで実行するスキル |
|:-|:-|
| コーディング中 | `coding-standards` |
| テスト作成時 | `tdd`, `testing` |
| コード重複検出時 | `code-similarity-ts` |
| コードレビュー時 | `typescript-code-review-skill` |
| パフォーマンス確認時 | `typescript-performance-review-skill` |

## 実装フロー

### 1. 作業開始

```bash
# mainで作業しない！必ず新ブランチを作成
git checkout -b feature/機能名
```

### 2. TDDで実装

→ `tdd` スキルを Skill ツールで実行すること

- Red → Green → Refactor のサイクル
- 先にテストを書いてから実装

### 3. コーディング規約に従う

→ `coding-standards` スキルを Skill ツールで実行すること

- 早期return、不変性、単一責任
- 型定義、命名規則

### 4. 品質チェック（必須）

```bash
pnpm run test        # テスト実行
pnpm run lint        # Lintチェック
pnpm run type-check  # 型チェック
```

**全て通るまでコミット禁止**

## 禁止事項

- `npx` / `pnpm dlx` の使用禁止（`pnpm run` を使用）
- ESLint無効化禁止（`eslint-disable` 系ディレクティブ禁止）
- mainブランチで直接作業禁止

## ブランチ命名規則

| プレフィックス | 用途 |
|:-|:-|
| `feature/` | 新機能追加 |
| `fix/` | バグ修正 |
| `refactor/` | リファクタリング |
| `docs/` | ドキュメント更新 |

補足:
- チームでチケット運用している場合は `feature/123-add-login` のようにチケット番号を付与してよい。
- ブランチ名は英小文字・ハイフン区切りを推奨。

## チェックリスト

```
## 実装前
- [ ] 新ブランチを作成した

## 実装中
- [ ] TDDサイクルを守っている（tddスキルをSkillツールで実行済み）
- [ ] コーディング規約に従っている（coding-standardsスキルをSkillツールで実行済み）

## 実装後
- [ ] `pnpm run test` 通過
- [ ] `pnpm run lint` 通過
- [ ] `pnpm run type-check` 通過
- [ ] コミットルールに従っている
```
