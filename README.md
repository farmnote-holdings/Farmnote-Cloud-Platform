# Farmnote-Cloud-Platform

Ver.3の開発用

## ドキュメント構成

ここでのドキュメントは、 LLM を活用しドキュメント生成しやすいようにコンテキストをまとめて配置する
以下のディレクトリ構成・命名に則って配置すること

### ディレクトリ構成

```text
docs/
├── strategy/                    # プロダクト戦略関連
│   └── vision/                 # ビジョン・ミッション
│       ├── company-vision.md
│       ├── product-vision.md
│       └── mission-statement.md
├── context/                     # チャットコンテキスト管理
│   ├── prompt/                  # チャット用プロンプト
│   │   ├── core-prompts.md
│   │   ├── feature-discussion.md
│   │   └── strategy-review.md
│   ├── templates/              # ドキュメントテンプレート
│   │   ├── strategy-template.md
│   │   ├── meeting-template.md
│   │   └── decision-template.md
│   └── guidelines/             # 作業ガイドライン
│       ├── document-standards.md
│       ├── review-process.md
│       └── change-management.md
├── knowledge/                   # ナレッジ
│   ├── domain/                  # ドメイン知識
│   │   ├── agriculture-knowledge.md
│   │   ├── cloud-platform.md
│   │   └── industry-trends.md
│   ├── glossary/                # 用語
│   │   ├── domain-glossary.md          # ドメイン用語（農業関連）
│   │   ├── product-glossary.md         # プロダクト用語
│   │   └── abbreviations.md            # 略語集
│   ├── ui/                      # デザイン
│   │   ├── components.md
│   │   ├── design-guideline.md
│   │   └── design-system.md
│   ├── technical/               # 技術知識
│   │   ├── architecture.md
│   │   ├── tech-stack.md
│   │   └── constraints.md
│   └── business/                # ビジネス知識
│       ├── market-insights.md
│       ├── customer-insights.md
│       └── competitive-intel.md
├── decisions/                   # 決定事項管理
│   ├── active-decisions/       # 検討中・決定済み
│   │   ├── feature-priorities-2024.md
│   │   └── architecture-choice.md
│   ├── decision-log/           # 決定履歴
│   │   ├── 2024-decisions.md
│   │   └── 2023-decisions.md
│   └── rationale/              # 決定根拠
│       ├── technical-rationale.md
│       └── business-rationale.md
├── research/                    # 調査・分析結果
│   ├── user-research/          # ユーザー調査
│   │   ├── interviews/
│   │   ├── surveys/
│   │   └── personas/
│   ├── market-research/        # 市場調査
│   │   ├── competitor-analysis/
│   │   ├── market-sizing/
│   │   └── trend-analysis/
│   └── technical-research/     # 技術調査
│       ├── technology-evaluation/
│       ├── architecture-research/
│       └── performance-analysis/
├── planning/                    # 計画関連
│   ├── roadmaps/               # ロードマップ
│   │   ├── product-roadmap.md
│   │   └── business-roadmap.md
│   ├── milestones/             # マイルストーン
│   │   ├── 2024-milestones.md
│   │   └── 2025-milestones.md
│   └── timelines/              # タイムライン
│       ├── release-schedule.md
│       └── feature-timeline.md
├── meeting-note/               # 議事録
├── meeting-record/             # 議事録用生データ
├── system-design/              # 着手中の開発の詳細な設計
├── working-documents/          # 作成中のドキュメント
└── temp/                       # 一時作業用(コミットされない)
```

### 命名規則

#### ファイル命名規則

- 形式: kebab-case.md
- フォーマット: [重要度・更新度]-[ファイルタイプ]-[日付].md
  - 重要度・更新頻度に応じて
    - core-: コア戦略（変更頻度低）
    - active-: アクティブな検討事項（変更頻度高）
    - archive-: アーカイブ（参照のみ）
    - つけなくてもよい
- 例:

    ```text
      core-product-vision.md
      active-feature-priorities.md
      archive-market-analysis-2024.md
      product-vision.md
    ```

### 生データについて

コンテキストを生成するために収集したデータや、議事録の生データなどはサイズが大きいことがあるため github では管理せず、 google drive で管理する

配置ルール

- [FN_未来創造/xxxx](https://drive.google.com/drive/u/0/folders/0AMHu3OG_TRqYUk9PVA) 以下に配置する
- ディレクトリは作成せずファイル名で識別し、なるべくフラットに管理する
  - google drive では、階層でファイル識別を表現すると検索時に何のファイルかわかりづらくなるため
- 命名ルール `[YYYY-MM-DD]_[Category]_[Description]_[Version].{extension}`
  - Category … コンテキストドキュメントカテゴリーが識別できる程度に適当なもの
  - Version … 検討を重ねた場合など。省略可能。

## ファイルの追加・更新フロー

特に規定しない
