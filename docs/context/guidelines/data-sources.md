# データソース管理

## 概要

コンテキストドキュメント作成に使用するデータソースの管理方法を説明します。

## Google Drive構成

### メインフォルダ

[FN_未来創造 > Farmnote-Cloud-Platform-Data/](https://drive.google.com/drive/u/0/folders/1SayV_vsO6TBO7vU79eLzDYCtd1WVHx_a)

### 主要フォルダ構成

- `Research_Data/`: 調査データ
- `Meeting_Records/`: 会議記録
- `Design_Assets/`: デザイン資産
- `Business_Documents/`: ビジネス文書
- `Archive/`: アーカイブ

## データソース別管理

### 1. ユーザー調査データ

**場所**: `Research_Data/User_Research/`
**内容**:

- インタビュー記録（音声・動画・文字起こし）
- アンケート結果（Excel・CSV）
- ペルソナ資料（画像・PDF）
- ユーザーストーリー（Word・PDF）

**命名規則**: `[YYYY-MM-DD]_UR_[Description]_v[Version].{ext}`

### 2. 市場調査データ

**場所**: `Research_Data/Market_Research/`
**内容**:

- 競合分析レポート
- 市場規模調査
- 業界レポート
- トレンド分析

**命名規則**: `[YYYY-MM-DD]_MR_[Description]_v[Version].{ext}`

### 3. 技術調査データ

**場所**: `Research_Data/Technical_Research/`
**内容**:

- 技術評価レポート
- アーキテクチャ調査
- 性能分析データ
- プロトタイプ

**命名規則**: `[YYYY-MM-DD]_TR_[Description]_v[Version].{ext}`

### 4. 会議記録

**場所**: `Meeting_Records/`
**内容**:

- 戦略会議の録音・議事録
- プロダクト会議の資料
- 技術会議の記録

**命名規則**: `[YYYY-MM-DD]_MTG_[Type]_[Description].{ext}`

## データ品質管理

### メタデータ必須項目

- 作成日・更新日
- 責任者
- ステータス（Draft/Review/Approved/Archive）
- 重要度（High/Medium/Low）
- 関連ドキュメント

### バージョン管理

- メジャーバージョン: 大きな変更
- マイナーバージョン: 小さな修正
- 日付付きバックアップ

## アクセス制御

### 権限レベル

- **編集者**: プロダクトチーム、経営陣
- **閲覧者**: 関連部門、外部コンサルタント
- **制限**: 機密情報は特定メンバーのみ

### 共有設定

- 内部共有: チームメンバーのみ
- 外部共有: 必要最小限の権限
- 期限設定: 一時的な共有には期限を設定

## 検索・整理

### タグシステム

```text
#user-research #interview #farmer #persona
#market-research #competitor #analysis
#technical #architecture #evaluation
#meeting #strategy #decision
```

### カラーラベル

- 🔴 重要: 戦略決定に影響するデータ
- 🟡 検討中: 現在検討中のデータ
- 🟢 完了: 処理完了済みのデータ
- 🔵 参考: 参考資料として保存

## 同期・連携

### GitHubとの連携

このファイルでGoogle Driveのデータソースを管理し、Cursorでのチャット時に参照します。

### 使用例

```text
@docs/context/guidelines/data-sources.md
Google Drive: Farmnote-Cloud-Platform-Data/Research_Data/01_User_Research/
```

## 関連文書

- @docs/context/guidelines/cursor-context-howto.md
- @docs/knowledge/glossary/domain-glossary.md
