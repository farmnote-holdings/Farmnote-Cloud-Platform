# Working Documents

このディレクトリは、プロダクト開発の過程で作成される検討中の資料や思考整理のためのドキュメントを格納します。

## ディレクトリ構成

```
working-documents/
├── draft/                      # 作業中の資料（一時保管）
│   ├── in-progress/           # 作業中の資料
│   │   ├── concept-drafts/    # コンセプト案
│   │   ├── architecture-drafts/ # アーキテクチャ案
│   │   ├── feature-drafts/    # 機能案
│   │   └── analysis-drafts/   # 分析資料
│   ├── review/                # レビュー待ち・レビュー中
│   │   ├── pending-review/    # レビュー待ち
│   │   └── under-review/      # レビュー中
│   └── archive/               # 一時アーカイブ
│       ├── abandoned/         # 破棄された案
│       └── merged/            # 統合された案
├── product-concepts/           # 検討完了：製品コンセプト
│   ├── concept-exploration/    # コンセプト探索
│   ├── user-scenarios/         # ユーザーシナリオ
│   └── value-proposition/      # 価値提案検討
├── architecture/               # 検討完了：アーキテクチャ
│   ├── system-design/          # システム設計
│   ├── data-flow/             # データフロー
│   └── integration-patterns/   # 統合パターン
├── feature-planning/           # 検討完了：機能企画
│   ├── feature-exploration/    # 機能探索
│   ├── user-journeys/         # ユーザージャーニー
│   └── interaction-design/     # インタラクション設計
├── business-analysis/          # 検討完了：ビジネス分析
│   ├── market-analysis/        # 市場分析
│   ├── competitive-analysis/   # 競合分析
│   └── business-models/        # ビジネスモデル
├── templates/                  # 検討用テンプレート
├── scripts/                    # 移動・管理スクリプト
└── move-completed-docs.md      # 移動ガイドライン
```

## 命名規則

- ファイル名: `[YYYY-MM-DD]_[category]_[description]_[version].md`
- 例: `2024-01-15_product-concept_exploration_v1.md`

## 作業フロー

### 1. 作業開始
- `draft/in-progress/` の適切なディレクトリにファイルを作成
- ファイル名に `_draft_v1` を付ける
- テンプレートを使用して作業開始

### 2. 作業中
- 定期的にファイルを更新
- 必要に応じてバージョンを上げる（`_draft_v2`, `_draft_v3`）
- ステータスを `draft/in-progress/README.md` に記録

### 3. レビュー準備
- 作業が一段落したら `draft/review/pending-review/` に移動
- ファイル名を `_review_ready_v1` に変更

### 4. レビュー中
- `draft/review/under-review/` に移動
- ファイル名を `_under_review_v1` に変更

### 5. 検討完了
- 検討が完了したら適切な完了ディレクトリに移動
- 移動スクリプト `scripts/move-draft.sh` を使用
- ファイル名から `draft` プレフィックスを削除

## ファイル管理ルール

1. **作業中のファイル**: `_draft_v1` プレフィックスを使用
2. **レビュー待ち**: `_review_ready_v1` プレフィックスを使用
3. **レビュー中**: `_under_review_v1` プレフィックスを使用
4. **完了したファイル**: `active-` または `completed-` プレフィックスを使用
5. **アーカイブ**: `archive-` プレフィックスを使用

## テンプレート

各カテゴリには以下のテンプレートを用意しています：
- `templates/concept-exploration-template.md`
- `templates/architecture-review-template.md`
- `templates/feature-planning-template.md`