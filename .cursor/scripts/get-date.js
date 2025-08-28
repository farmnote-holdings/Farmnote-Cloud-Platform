#!/usr/bin/env node

/**
 * 現在の日付を YYYY-MM-DD 形式で取得
 * @returns {string}
 */
function getCurrentDate() {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}

/**
 * 現在の時刻を含む完全な日時文字列をISO 8601形式で取得
 * @returns {string}
 */
function getCurrentDateTime() {
    return new Date().toISOString();
}

/**
 * 現在の日付・時刻情報を取得して表示
 */
function getSystemDateTime() {
    const currentDate = getCurrentDate();
    const currentDateTime = getCurrentDateTime();
  
    console.log('🕐 システム時刻情報');
    console.log('========================');
    console.log(`📅 日付: ${currentDate}`);
    console.log(`⏰ 時刻: ${currentDateTime}`);
    console.log('========================');
  
    return {
        date: currentDate,
        datetime: currentDateTime,
        timestamp: Date.now()
    };
}

// メイン実行
if (require.main === module) {
    try {
        const dateInfo = getSystemDateTime();
      
        // 環境変数として設定
        process.env.SYSTEM_DATE = dateInfo.date;
        process.env.SYSTEM_DATETIME = dateInfo.datetime;
      
        console.log('✅ システム時刻情報を正常に取得しました');
      
    } catch (error) {
        console.error('❌ システム時刻情報の取得に失敗しました:', error.message);
        process.exit(1);
    }
}

module.exports = { getSystemDateTime };
