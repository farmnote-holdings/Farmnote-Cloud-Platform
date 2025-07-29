# Cursorでのコンテキスト指定方法 HowTo

## 概要

Cursorでのチャット時に、適切なコンテキストを効率的に指定する方法を説明します。

## 1. ファイル指定によるコンテキスト提供

### 1.1 単一ファイルの指定

```text
@docs/strategy/vision/core-product-vision.md
```

**利用シーン**: 特定の戦略文書を参照したい場合

### 1.2 複数ファイルの指定

```text
@docs/strategy/vision/core-product-vision.md
@docs/strategy/market/active-market-analysis.md
@docs/decisions/active-decisions/feature-priorities-2024.md
```

**利用シーン**: 複数の関連文書を同時に参照したい場合

### 1.3 ディレクトリ全体の指定

```text
@docs/strategy/
```

**利用シーン**: 戦略全体の文脈を理解したい場合

## 2. プレフィックスによる効率的な指定

### 2.1 コア戦略の指定

```text
@docs/strategy/**/core-*.md
```

**利用シーン**: 基本的な戦略方針を確認したい場合

### 2.2 アクティブな検討事項の指定

```text
@docs/strategy/**/active-*.md
@docs/decisions/active-decisions/*.md
```

**利用シーン**: 現在検討中の事項を確認したい場合

### 2.3 過去の検討内容の指定

```text
@docs/strategy/**/archive-*.md
@docs/decisions/decision-log/*.md
```

**利用シーン**: 過去の決定根拠を参照したい場合

## 3. 用途別コンテキスト指定パターン

### 3.1 新機能企画時

```text
@docs/strategy/vision/core-product-vision.md
@docs/strategy/roadmap/active-feature-priorities.md
@docs/knowledge/domain/agriculture-knowledge.md
@docs/research/user-research/personas/
```

**説明**: ビジョン、優先度、ドメイン知識、ユーザー情報を統合

### 3.2 戦略レビュー時

```text
@docs/strategy/**/core-*.md
@docs/metrics/business-metrics/*.md
@docs/planning/roadmaps/*.md
```

**説明**: コア戦略、指標、計画を統合して現状評価

### 3.3 技術決定時

```text
@docs/knowledge/technical/architecture.md
@docs/knowledge/technical/constraints.md
@docs/decisions/active-decisions/architecture-choice.md
@docs/research/technical-research/technology-evaluation/
```

**説明**: 技術背景、制約、決定事項、技術調査を統合

### 3.4 市場分析時

```text
@docs/knowledge/business/market-insights.md
@docs/research/market-research/competitor-analysis/
@docs/strategy/market/active-market-analysis.md
@docs/knowledge/business/competitive-intel.md
```

**説明**: 市場知識、競合分析、最新分析を統合

## 4. 高度な指定方法

### 4.1 ワイルドカードを使用した指定

```text
@docs/**/core-*.md
```

**利用シーン**: 全ディレクトリのコア文書を指定

### 4.2 複数パターンの組み合わせ

```text
@docs/strategy/**/core-*.md
@docs/decisions/active-decisions/*.md
@docs/knowledge/domain/*.md
```

**利用シーン**: 複数カテゴリの関連文書を指定

### 4.3 除外パターンの使用

```text
@docs/strategy/**/*.md
!@docs/strategy/**/archive-*.md
```

**説明**: アーカイブを除く全戦略文書を指定（注：Cursorの現在の機能では制限あり）

## 5. 実践的な使用例

### 5.1 プロダクト戦略チャット開始時

```text
プロダクト戦略について相談したいです。
以下のコンテキストを参考にしてください：

@docs/strategy/vision/core-product-vision.md
@docs/strategy/market/core-market-analysis.md
@docs/decisions/active-decisions/feature-priorities-2024.md
```

### 5.2 技術検討時のチャット

```text
新しい技術選定について検討したいです。
以下の制約と背景を考慮してください：

@docs/knowledge/technical/constraints.md
@docs/knowledge/technical/architecture.md
@docs/research/technical-research/technology-evaluation/
```

### 5.3 ユーザー体験改善時のチャット

```text
ユーザー体験の改善について検討したいです。
以下のユーザー情報を参考にしてください：

@docs/research/user-research/personas/
@docs/knowledge/business/customer-insights.md
@docs/metrics/product-metrics/usage-metrics.md
```

## 6. ベストプラクティス

### 6.1 コンテキストの優先順位

1. **コア戦略文書** (core-*)
2. **アクティブな検討事項** (active-*)
3. **関連する知識ベース** (knowledge/)
4. **過去の決定事項** (archive-*)

### 6.2 ファイル数の最適化

- **通常のチャット**: 3-5ファイル
- **複雑な検討**: 5-10ファイル
- **戦略レビュー**: 10-15ファイル

### 6.3 コンテキストの更新

- チャット開始時に最新のコンテキストを指定
- 長いチャットでは定期的にコンテキストを再指定
- 新しい決定事項が生じた場合は即座にコンテキストに追加

## 7. トラブルシューティング

### 7.1 ファイルが見つからない場合

- ファイルパスの確認
- ファイル名の正確性確認
- ディレクトリ構造の確認

### 7.2 コンテキストが多すぎる場合

- プレフィックスによる絞り込み
- 特定のディレクトリに限定
- 用途別パターンの使用

### 7.3 コンテキストが不足している場合

- 関連する知識ベースの追加
- 過去の決定事項の参照
- 調査結果の追加

## 8. テンプレート

### 8.1 基本チャット開始テンプレート

```text
[目的]について相談したいです。
以下のコンテキストを参考にしてください：

@docs/strategy/vision/core-product-vision.md
@docs/strategy/[関連カテゴリ]/[関連ファイル].md
@docs/knowledge/[関連ドメイン]/[関連ファイル].md
```

### 8.2 戦略検討テンプレート

```text
[戦略テーマ]について検討したいです。
以下の戦略文書と背景知識を参考にしてください：

@docs/strategy/**/core-*.md
@docs/decisions/active-decisions/*.md
@docs/knowledge/business/[関連ファイル].md
```

このHowToを参考に、効率的なコンテキスト指定を行ってください。
