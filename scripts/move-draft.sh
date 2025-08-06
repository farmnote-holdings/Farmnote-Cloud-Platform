#!/bin/bash

# Draftファイル移動スクリプト
# 使用方法: ./move-draft.sh <source_file> <target_category> [status]

set -e

# 色付き出力用の関数
print_info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

print_warning() {
    echo -e "\033[33m[WARNING]\033[0m $1"
}

print_error() {
    echo -e "\033[31m[ERROR]\033[0m $1"
}

# 使用方法の表示
show_usage() {
    echo "使用方法: $0 <source_file> <target_category> [status]"
    echo ""
    echo "引数:"
    echo "  source_file     移動元のファイルパス"
    echo "  target_category 移動先カテゴリ (concept|architecture|feature|analysis)"
    echo "  status          ステータス (active|completed) [デフォルト: active]"
    echo ""
    echo "例:"
    echo "  $0 draft/in-progress/concept-drafts/2024-01-15_product-concept_exploration_draft_v1.md concept"
    echo "  $0 draft/in-progress/architecture-drafts/2024-01-15_system-design_draft_v1.md architecture completed"
}

# 引数チェック
if [ $# -lt 2 ]; then
    print_error "引数が不足しています"
    show_usage
    exit 1
fi

SOURCE_FILE="$1"
TARGET_CATEGORY="$2"
STATUS="${3:-active}"

# ファイルの存在確認
if [ ! -f "$SOURCE_FILE" ]; then
    print_error "ファイルが見つかりません: $SOURCE_FILE"
    exit 1
fi

# ファイル名から情報を抽出
FILENAME=$(basename "$SOURCE_FILE")
DIRNAME=$(dirname "$SOURCE_FILE")

# draftプレフィックスを削除して新しいファイル名を生成
NEW_FILENAME=$(echo "$FILENAME" | sed 's/_draft_v/_v/')
NEW_FILENAME="${STATUS}_${NEW_FILENAME}"

# カテゴリに応じて移動先を決定
case "$TARGET_CATEGORY" in
    "concept")
        TARGET_DIR="product-concepts/concept-exploration/"
        ;;
    "architecture")
        TARGET_DIR="architecture/system-design/"
        ;;
    "feature")
        TARGET_DIR="feature-planning/feature-exploration/"
        ;;
    "analysis")
        TARGET_DIR="business-analysis/market-analysis/"
        ;;
    *)
        print_error "無効なカテゴリです: $TARGET_CATEGORY"
        echo "有効なカテゴリ: concept, architecture, feature, analysis"
        exit 1
        ;;
esac

# 移動先ディレクトリが存在しない場合は作成
if [ ! -d "$TARGET_DIR" ]; then
    print_info "ディレクトリを作成します: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# 移動先の完全パス
TARGET_PATH="$TARGET_DIR$NEW_FILENAME"

# 移動先に同名ファイルが存在するかチェック
if [ -f "$TARGET_PATH" ]; then
    print_warning "移動先に同名ファイルが存在します: $TARGET_PATH"
    read -p "上書きしますか？ (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "移動をキャンセルしました"
        exit 0
    fi
fi

# ファイルを移動
print_info "ファイルを移動中..."
print_info "移動元: $SOURCE_FILE"
print_info "移動先: $TARGET_PATH"

mv "$SOURCE_FILE" "$TARGET_PATH"

if [ $? -eq 0 ]; then
    print_success "ファイルの移動が完了しました"

    # 移動履歴を記録
    LOG_FILE="move-history.log"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $SOURCE_FILE → $TARGET_PATH" >> "$LOG_FILE"

    print_info "移動履歴を記録しました: $LOG_FILE"
else
    print_error "ファイルの移動に失敗しました"
    exit 1
fi

# 空になったディレクトリを削除（オプション）
if [ -z "$(ls -A "$DIRNAME" 2>/dev/null)" ]; then
    print_info "空になったディレクトリを削除します: $DIRNAME"
    rmdir "$DIRNAME"
fi

print_success "処理が完了しました"