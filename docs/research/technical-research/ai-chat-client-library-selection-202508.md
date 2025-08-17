# AIチャットクライアント ライブラリ選定・実装方針決定

## 概要

Farmnote Cloud PlatformのAIアシスタント機能におけるクライアント実装について、今までの検討結果を統合し、ライブラリ選定と実装方針を決定します。

**決定日**: 2025年8月
**決定者**: 開発チーム
**ステータス**: 決定済み

## 1. 検討背景

### 1.1. 要件整理

#### 基本要件
- **React 18対応**: 最新のReact機能を活用
- **TypeScript対応**: 型安全性の確保
- **デザインシステム統合**: Farmnote Cloud Platformのデザイン原則との整合性
- **農業特化機能**: 個体リスト表示、音声入力、専門用語対応

#### Farmnote特化要件
- **音声入力対応**: Web Speech APIとの統合
- **リッチな結果表示**: 個体リスト、チャート、アクションボタンなどの表示
- **農業専門用語対応**: 日本語音声認識の精度向上
- **レスポンシブ対応**: モバイル・タブレット対応
- **アクセシビリティ**: WCAG 2.1 AA準拠

### 1.2. デザイン原則との整合性

Farmnote Cloud Platformのデザイン原則に基づく実装方針：

- **インテリジェント**: AIによる支援を前提とした直感的なUI
- **ストレスフリー**: 音声入力や自然言語入力による負荷軽減
- **成果に貢献**: データ活用による利益を可視化
- **親しみやすい**: ITスキルを問わない使いやすさ
- **統合されている**: 既存アプリケーションとの一貫性

## 2. ライブラリ選定結果

### 2.1. チャットUIライブラリ

#### 選定結果: @chatscope/chat-ui-kit-react

**選定理由**:
1. **音声メッセージ機能**: 標準で音声メッセージ機能を提供
2. **豊富なコンポーネント**: チャットに必要なコンポーネントが充実
3. **TypeScript対応**: 完全な型安全性を確保
4. **アクティブな開発**: 継続的な改善とサポート
5. **カスタマイズ性**: テーマシステムによる柔軟なカスタマイズ

**評価結果**:
| 項目 | 評価 | 詳細 |
|------|------|------|
| 基本機能 | ⭐⭐⭐⭐⭐ | 非常に豊富なコンポーネント |
| カスタマイズ性 | ⭐⭐⭐⭐ | テーマシステムが充実 |
| 音声入力 | ⭐⭐⭐⭐ | 音声メッセージ機能あり |
| リッチ表示 | ⭐⭐⭐⭐ | ファイル、画像、カード表示対応 |
| TypeScript | ⭐⭐⭐⭐⭐ | 完全なTypeScript対応 |
| アクティブ度 | ⭐⭐⭐⭐⭐ | 活発に開発中 |

### 2.2. 技術スタック決定

#### フロントエンド
```typescript
const frontendLibraries = {
  // 基本フレームワーク
  framework: 'React 18',
  language: 'TypeScript 5.0+',

  // 状態管理
  stateManagement: 'Zustand', // 軽量でTypeScript対応が優秀

  // UIコンポーネント
  ui: 'Radix UI', // アクセシビリティ重視
  styling: 'Tailwind CSS', // デザインシステムとの統合

  // チャットUI
  chat: '@chatscope/chat-ui-kit-react', // リッチなチャットUI
  virtualScrolling: 'react-window', // 大量データ対応

  // 音声処理
  voice: 'react-speech-recognition', // Web Speech API
  audio: 'howler.js', // 音声再生

  // データ表示
  charts: 'Recharts', // 軽量で美しい
  tables: 'react-table', // 柔軟なテーブル
  maps: 'react-leaflet', // 地図表示

  // フォーム
  forms: 'react-hook-form', // 高性能フォーム
  validation: 'zod', // TypeScript統合バリデーション

  // その他
  utils: 'date-fns', // 日付処理
  icons: 'lucide-react', // モダンアイコン
  animations: 'framer-motion' // スムーズアニメーション
};
```

#### バックエンド
```typescript
const backendLibraries = {
  // 基本フレームワーク
  framework: 'Express.js',
  language: 'TypeScript 5.0+',
  runtime: 'Node.js 18+',

  // データベース
  orm: 'Prisma', // TypeScript統合ORM
  database: 'PostgreSQL', // リレーショナルDB
  cache: 'Redis', // キャッシュ・セッション

  // AI・ML
  llm: '@google/generative-ai', // Gemini API
  speechToText: '@google-cloud/speech', // Google STT
  nlp: 'compromise', // 軽量NLP

  // ワークフロー
  workflow: 'temporal', // 分散ワークフロー
  stateMachine: 'xstate', // 状態管理

  // ファイル処理
  pdf: 'puppeteer', // PDF生成
  excel: 'exceljs', // Excel処理
  csv: 'csv-parser', // CSV処理

  // API・通信
  http: 'axios', // HTTP通信
  websocket: 'socket.io', // リアルタイム通信
  streaming: 'node-stream', // ストリーミング

  // 認証・セキュリティ
  auth: 'passport', // 認証
  jwt: 'jsonwebtoken', // JWT
  encryption: 'crypto', // 暗号化

  // ログ・監視
  logging: 'winston', // ログ
  monitoring: 'prometheus', // メトリクス
  tracing: 'opentelemetry' // 分散トレーシング
};
```

## 3. 実装方針

### 3.1. アーキテクチャ設計

#### コンポーネント階層構造
```
ChatInterface (Organism)
├── ChatHeader (Molecule)
│   ├── ChatTitle (Atom)
│   ├── VoiceToggle (Atom)
│   └── SettingsButton (Atom)
├── ChatMessages (Organism)
│   ├── MessageList (Molecule)
│   │   ├── UserMessage (Molecule)
│   │   ├── AssistantMessage (Molecule)
│   │   └── SystemMessage (Molecule)
│   └── MessageRenderer (Molecule)
│       ├── TextRenderer (Atom)
│       ├── DataTableRenderer (Atom)
│       ├── ChartRenderer (Atom)
│       ├── ActionButtonRenderer (Atom)
│       └── FileRenderer (Atom)
├── ChatInput (Organism)
│   ├── TextInput (Molecule)
│   ├── VoiceInput (Molecule)
│   ├── QuickActions (Molecule)
│   └── SendButton (Atom)
└── ChatSidebar (Organism)
    ├── ConversationHistory (Molecule)
    ├── SavedQueries (Molecule)
    └── Templates (Molecule)
```

#### 状態管理設計
```typescript
interface ChatState {
  // メッセージ管理
  messages: Message[];
  currentMessage: Message | null;

  // 入力状態
  inputMode: 'text' | 'voice' | 'file';
  isRecording: boolean;
  isProcessing: boolean;

  // UI状態
  sidebarOpen: boolean;
  selectedTemplate: string | null;

  // 音声認識状態
  voiceRecognition: {
    isSupported: boolean;
    isActive: boolean;
    interimResults: string[];
    finalResults: string[];
  };

  // 結果表示状態
  resultDisplay: {
    activeRenderer: string;
    rendererData: any;
    isLoading: boolean;
  };
}
```

### 3.2. リッチな結果表示の実装

#### メッセージレンダラーシステム
```typescript
interface MessageRenderer {
  type: string;
  priority: number;
  canRender: (content: any) => boolean;
  render: (content: any, props: RenderProps) => React.ReactNode;
}

// 個体リストレンダラー（拡張版）
const IndividualListRenderer: MessageRenderer = {
  type: 'individual-list',
  priority: 3,
  canRender: (content) => content.type === 'individual-list',
  render: (content, props) => {
    const [displayMode, setDisplayMode] = useState(content.displayMode || 'table');
    const [selectedIndividuals, setSelectedIndividuals] = useState<Individual[]>([]);

    return (
      <div className="individual-list-container">
        <IndividualListHeader
          title={content.title}
          description={content.description}
          query={content.query}
          displayMode={displayMode}
          onDisplayModeChange={setDisplayMode}
          onExport={props.onExport}
        />

        <SmartSummary individuals={content.individuals} query={content.query} />

        <InteractiveFilters
          filters={content.filters}
          onFilterChange={props.onFilterChange}
        />

        <IndividualListContent
          individuals={content.individuals}
          displayMode={displayMode}
          selectedIndividuals={selectedIndividuals}
          onSelectionChange={setSelectedIndividuals}
          onRowClick={props.onRowClick}
          onAction={props.onAction}
        />

        <BulkActions
          selectedIndividuals={selectedIndividuals}
          onAction={props.onBulkAction}
        />
      </div>
    );
  }
};
```

#### 表示モードの拡張
- **テーブルモード**: 基本的なデータ表示
- **カードモード**: ビジュアル重視の表示
- **タイムラインモード**: 時系列重視の表示
- **マップモード**: 位置情報重視の表示

### 3.3. 音声入力機能の実装

#### Web Speech API統合
```typescript
const VoiceInput: React.FC<VoiceInputProps> = ({
  onResult,
  onError,
  language = 'ja-JP',
  continuous = false
}) => {
  const [isListening, setIsListening] = useState(false);
  const [interimText, setInterimText] = useState('');
  const recognitionRef = useRef<SpeechRecognition | null>(null);

  const startListening = () => {
    if (!('webkitSpeechRecognition' in window)) {
      onError('音声認識がサポートされていません');
      return;
    }

    const recognition = new (window as any).webkitSpeechRecognition();
    recognition.continuous = continuous;
    recognition.interimResults = true;
    recognition.lang = language;

    recognition.onstart = () => setIsListening(true);
    recognition.onend = () => setIsListening(false);
    recognition.onresult = (event: SpeechRecognitionEvent) => {
      let finalTranscript = '';
      let interimTranscript = '';

      for (let i = event.resultIndex; i < event.results.length; i++) {
        const transcript = event.results[i][0].transcript;
        if (event.results[i].isFinal) {
          finalTranscript += transcript;
        } else {
          interimTranscript += transcript;
        }
      }

      setInterimText(interimTranscript);
      if (finalTranscript) {
        onResult(finalTranscript);
      }
    };

    recognition.onerror = (event: SpeechRecognitionErrorEvent) => {
      onError(`音声認識エラー: ${event.error}`);
    };

    recognitionRef.current = recognition;
    recognition.start();
  };

  return (
    <div className="voice-input">
      <Button
        variant={isListening ? "danger" : "primary"}
        icon={isListening ? "stop" : "microphone"}
        onClick={isListening ? stopListening : startListening}
        disabled={!('webkitSpeechRecognition' in window)}
      >
        {isListening ? "録音停止" : "音声入力"}
      </Button>
      {interimText && (
        <div className="interim-text">
          {interimText}
        </div>
      )}
    </div>
  );
};
```

#### 農業専門用語辞書
```typescript
// 農業専門用語の辞書定義
const AGRICULTURE_DICTIONARY = {
  '発情': ['はつじょう', '発情期', '発情症状'],
  '分娩': ['ぶんべん', '出産', '子牛'],
  '搾乳': ['さくにゅう', 'ミルク', '乳量'],
  '給餌': ['きゅうじ', 'エサ', '飼料'],
  '健康チェック': ['けんこうチェック', '体調', '症状'],
  // ... その他の専門用語
};

// 音声認識の精度向上
const enhanceRecognition = (text: string): string => {
  let enhancedText = text;

  Object.entries(AGRICULTURE_DICTIONARY).forEach(([correct, variants]) => {
    variants.forEach(variant => {
      const regex = new RegExp(variant, 'gi');
      enhancedText = enhancedText.replace(regex, correct);
    });
  });

  return enhancedText;
};
```

### 3.4. 複数レスポンスAPI設計

#### Server-Sent Events (SSE) 採用
```typescript
// レスポンスタイプの定義
interface StreamResponse {
  type: 'status' | 'intermediate' | 'result' | 'error' | 'progress';
  message: string;
  data?: any;
  error?: string;
  progress?: {
    current: number;
    total: number;
    percentage: number;
  };
  timestamp: string;
  sessionId?: string;
}

// チャットストリーミングフック
const useChatStream = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isStreaming, setIsStreaming] = useState(false);
  const [progress, setProgress] = useState<Progress | null>(null);

  const sendMessage = async (message: string) => {
    setIsStreaming(true);
    setProgress(null);

    const eventSource = new EventSource(`/api/chat/stream?message=${encodeURIComponent(message)}`);

    eventSource.onmessage = (event) => {
      if (event.data === '[DONE]') {
        eventSource.close();
        setIsStreaming(false);
        setProgress(null);
        return;
      }

      try {
        const data: StreamResponse = JSON.parse(event.data);

        // メッセージタイプに応じた処理
        switch (data.type) {
          case 'status':
            addStatusMessage(data);
            break;
          case 'intermediate':
            addIntermediateMessage(data);
            break;
          case 'result':
            addResultMessage(data);
            break;
          case 'error':
            addErrorMessage(data);
            break;
          case 'progress':
            updateProgress(data.progress);
            break;
        }
      } catch (error) {
        console.error('Parse error:', error);
      }
    };

    eventSource.onerror = (error) => {
      console.error('SSE Error:', error);
      eventSource.close();
      setIsStreaming(false);
      setProgress(null);
    };
  };

  return {
    messages,
    isStreaming,
    progress,
    sendMessage
  };
};
```

## 4. 実装優先順位

### Phase 1: 基本機能（2週間）
1. 基本的なチャットインターフェース
2. テキスト入力・送信機能
3. シンプルなメッセージ表示
4. 基本的な音声入力機能

### Phase 2: リッチ表示機能（3週間）
1. データテーブルレンダラー
2. チャート・グラフレンダラー
3. アクションボタンレンダラー
4. ファイル表示レンダラー

### Phase 3: 農業特化機能（3週間）
1. 個体リストレンダラー（拡張版）
   - 多様な表示モード（テーブル、カード、タイムライン、マップ）
   - インタラクティブフィルタリング
   - 一括アクション機能
   - スマートサマリー
2. 健康状態レンダラー
3. 繁殖計画レンダラー
4. 農業専門用語辞書
5. 音声による個体リスト操作
6. 自然言語での絞り込み機能

### Phase 4: 最適化・改善（1週間）
1. パフォーマンス最適化
2. アクセシビリティ改善
3. エラーハンドリング強化
4. ユーザビリティテスト

## 5. 技術的考慮事項

### 5.1. パフォーマンス最適化
- **仮想化**: React Windowによる大量メッセージ対応
- **遅延読み込み**: コンポーネントの遅延読み込み
- **キャッシュ戦略**: マルチレイヤーキャッシュ

### 5.2. アクセシビリティ対応
- **キーボードナビゲーション**: 完全なキーボード操作対応
- **スクリーンリーダー**: ARIA属性の適切な設定
- **色覚対応**: 色だけでなく形状でも情報を伝達

### 5.3. セキュリティ対策
- **入力検証**: XSS攻撃対策
- **認証・認可**: 適切な権限管理
- **データ暗号化**: 機密情報の保護

## 6. 今後の拡張性

### 6.1. プラグインシステム
- カスタムレンダラーの動的読み込み
- サードパーティ連携のためのAPI
- テーマ・スタイルのカスタマイズ

### 6.2. 多言語対応
- i18n対応
- 音声認識の多言語対応
- 地域固有の農業用語対応

### 6.3. オフライン対応
- Service Workerによるキャッシュ
- オフライン時の音声認識
- 同期機能

## 7. 結論

Farmnote Cloud PlatformのAIアシスタント機能において、以下の方針で実装を進めます：

### 7.1. 技術選定
- **チャットUI**: @chatscope/chat-ui-kit-react
- **状態管理**: Zustand
- **UIコンポーネント**: Radix UI + Tailwind CSS
- **音声認識**: Web Speech API + 農業専門用語辞書
- **ストリーミング**: Server-Sent Events (SSE)

### 7.2. 実装方針
- **デザイン原則との整合性**: Farmnote Cloud Platformの5つのデザイン原則を遵守
- **農業特化機能**: 個体リスト表示、音声入力、専門用語対応を重視
- **パフォーマンス**: 仮想化と遅延読み込みによる最適化
- **アクセシビリティ**: WCAG 2.1 AA準拠

### 7.3. 期待される効果
- **ユーザビリティ向上**: 自然言語による直感的な操作
- **生産性向上**: 音声入力とリッチな結果表示による効率化
- **農業現場での実用性**: 手が塞がる作業中のハンズフリー操作
- **統合性**: 既存アプリケーションとの一貫した体験

この実装方針により、Farmnote Cloud PlatformのAIアシスタント機能が、農業現場での実用性を重視しつつ、リッチでインタラクティブな体験を提供できると考えられます。
