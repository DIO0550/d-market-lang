---
name: typescript-code-review-skill
description: TypeScript/React向けコードレビュースキル。命名規則・テストコード品質・コメント意図/防御的コードの3つの観点でレビューを実施。「コードレビューして」「PRレビュー」「命名規則を確認」「テストの品質をチェック」「コメントを確認」「エラー処理を確認」「レビューお願い」などのリクエスト時に使用。
disable-model-invocation: true
---

# TypeScript Code Review Skill

TypeScript/Reactプロジェクト向けのコードレビューを実施する。

## レビュー観点

| 観点 | 説明 | 参照 |
|------|------|------|
| 命名規則 | TypeScript命名規則の準拠 | [naming-review.md](references/naming-review.md) |
| テストコード | FIRST原則、AAA、網羅性の確認 | [test-review.md](references/test-review.md) |
| コメント意図・防御的コード | Why-not/局所的Whyコメントの確認、不要なフォールバック・「念のため」の防御的コードの検出 | [intent-comment-review.md](references/intent-comment-review.md) |

## レビュー対象の決定

1. ユーザーがファイルやディレクトリを指定した場合 → そのファイルをレビュー
2. ブランチ上の変更をレビューする場合 → `git diff main...HEAD` で差分を取得
3. 指定がない場合 → ユーザーにレビュー対象を確認する

## レビューフロー

1. レビュー対象のコードを特定する
2. コードの種類に応じて該当するreferenceを読み込む
   - `.test.ts` / `.test.tsx` を含む → [test-review.md](references/test-review.md) を読む
   - それ以外 → [naming-review.md](references/naming-review.md) と [intent-comment-review.md](references/intent-comment-review.md) を読む
   - 両方含む場合はすべて読む
3. 各referenceの出力形式に従ってレビュー結果を出力
4. 全観点のサマリーを報告

## 重要度分類

| レベル | 意味 | 対応 |
|---|---|---|
| **Blocking** | 即修正必須 | マージ前に必ず修正 |
| **Should Fix** | 修正推奨 | 可能な限りこのPRで対応 |
| **Nice to Have** | 改善提案 | 次回以降でもよい |

## 出力構成

レビュー結果は以下の順で報告する:

1. **サマリー**: レビュー対象ファイル一覧、重要度別の件数
2. **詳細**: 各観点ごとにreferenceの出力形式に従った結果
3. **総評**: 全体的な品質評価と優先的に対応すべき項目
