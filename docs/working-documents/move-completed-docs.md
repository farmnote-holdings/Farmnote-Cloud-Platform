# 検討完了資料の移動ガイドライン

このドキュメントは、作業中の資料（draft）から検討完了後の資料を適切な場所に移動するためのガイドラインです。

## 移動フロー

### 1. 検討完了の判定

以下の条件を満たした場合、検討完了とみなします：

- [ ] 主要な検討項目がすべて完了
- [ ] チーム内でのレビューが完了
- [ ] 決定事項が明確になっている
- [ ] 次のステップが明確になっている

### 2. 移動先の決定

| 資料の種類 | 移動先 | ファイル名プレフィックス |
|------------|--------|------------------------|
| 製品コンセプト | `product-concepts/` | `active-` または `completed-` |
| アーキテクチャ | `architecture/` | `active-` または `completed-` |
| 機能企画 | `feature-planning/` | `active-` または `completed-` |
| ビジネス分析 | `business-analysis/` | `active-` または `completed-` |

### 3. ファイル名の変更

移動時に以下のルールでファイル名を変更：

```bash
# 例: draft → active
2024-01-15_product-concept_exploration_draft_v1.md
↓
active_product-concept_exploration_v1.md
```

### 4. 移動手順

1. **ファイルの内容確認**
   - 検討内容が完了しているか確認
   - 更新履歴が記録されているか確認

2. **ファイル名の変更**
   - `_draft_v1` → `_v1` に変更
   - 必要に応じてプレフィックスを追加

3. **適切なディレクトリに移動**
   - 資料の種類に応じて移動先を決定
   - 必要に応じてサブディレクトリを作成

4. **READMEの更新**
   - 移動先のREADMEに新しいファイルを追加
   - 必要に応じてインデックスを更新

## 移動スクリプト例

```bash
#!/bin/bash

# 移動元と移動先を指定
SOURCE_FILE="draft/in-progress/concept-drafts/2024-01-15_product-concept_exploration_draft_v1.md"
TARGET_DIR="product-concepts/concept-exploration/"
NEW_FILENAME="active_product-concept_exploration_v1.md"

# 移動先ディレクトリが存在しない場合は作成
mkdir -p "$TARGET_DIR"

# ファイル名を変更して移動
mv "$SOURCE_FILE" "$TARGET_DIR$NEW_FILENAME"

echo "移動完了: $SOURCE_FILE → $TARGET_DIR$NEW_FILENAME"
```

## アーカイブルール

### 破棄された案の処理
- 移動先: `draft/archive/abandoned/`
- ファイル名: `abandoned_[元のファイル名]`

### 統合された案の処理
- 移動先: `draft/archive/merged/`
- ファイル名: `merged_[元のファイル名]`
- 統合先のファイル名をコメントで記録

## 注意事項

1. **バックアップ**: 移動前に必ずバックアップを取る
2. **リンク更新**: 他のファイルからの参照がある場合は更新
3. **履歴保持**: 移動履歴を記録する
4. **権限確認**: 移動先ディレクトリの書き込み権限を確認

## 定期クリーンアップ

月次で以下の作業を実施：

1. **古いdraftファイルの確認**
   - 1ヶ月以上更新がないファイルをリストアップ
   - アーカイブまたは削除を検討

2. **アーカイブの整理**
   - 不要になったアーカイブファイルの削除
   - アーカイブの整理・統合

3. **ディレクトリ構造の最適化**
   - 空になったディレクトリの削除
   - ディレクトリ構造の見直し