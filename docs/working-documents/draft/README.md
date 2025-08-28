# Draft Documents

作業中の資料を一時的に保管するディレクトリです。検討が完了したら適切な場所に移動させてください。

## ディレクトリ構成

```
working-documents/
├── in-progress/            # 作業中の資料
├── review/                 # レビュー待ちの資料
├── archive/                # アーカイブ
└── abandoned/              # 破棄された案
```

## ファイル命名規則

### 作業中のファイル
- 形式: `[YYYY-MM-DD]_[category]_[description]_draft_v[version].md`
- 例: `2024-01-15_product-concept_exploration_draft_v1.md`

### ステータス管理
- **作業中**: `draft_v1`, `draft_v2` など
- **レビュー待ち**: `review_ready_v1`
- **レビュー中**: `under_review_v1`

## 移動ルール

### 作業完了時の移動先
1. **製品コンセプト** → `../product-concepts/`
2. **アーキテクチャ** → `../architecture/`
3. **機能企画** → `../feature-planning/`
4. **ビジネス分析** → `../business-analysis/`

### 移動時のファイル名変更
- `_draft_v1` → `_v1` (draftプレフィックスを削除)
- または適切なプレフィックスに変更（`active-`, `completed-`など）

## クリーンアップルール

- **1ヶ月以上更新がないファイル**: アーカイブまたは削除を検討
- **破棄された案**: `archive/abandoned/` に移動
- **統合された案**: `archive/merged/` に移動

## テンプレート

作業開始時は以下のテンプレートを使用：
- `../templates/concept-exploration-template.md`
- `../templates/architecture-review-template.md`
