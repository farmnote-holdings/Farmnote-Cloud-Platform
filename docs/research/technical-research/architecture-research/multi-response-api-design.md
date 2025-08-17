# 複数レスポンスAPI設計 - 協調動作によるユーザビリティ向上

## 概要

Farmnote Cloud PlatformのAIアシスタント機能において、API側が協調して動作し、一度のリクエストに対して複数のレスポンスを返す仕組みを設計します。これにより、ユーザーはリアルタイムで処理状況を把握でき、より自然で直感的な対話体験を実現できます。

## 1. ユースケース分析

### 1.1. 複数レスポンスが必要な場面

#### 個体リスト生成プロセス
```
ユーザー: "発情予定の牛のリストを作って"

AI: "発情予定の牛を検索中..." (即座に返答)
AI: "検索条件: 最終種付日から21日以上経過" (処理状況)
AI: "該当個体: 15頭見つかりました" (中間結果)
AI: "個体リストを生成中..." (処理状況)
AI: [個体リスト表示] (最終結果)
```

#### 健康状態分析プロセス
```
ユーザー: "14番の牛の健康状態を分析して"

AI: "14番の牛のデータを取得中..." (即座に返答)
AI: "過去30日間のデータを分析中..." (処理状況)
AI: "乳量: 平均25kg/日 (基準値: 28kg/日)" (中間結果)
AI: "活動量: 正常範囲内" (中間結果)
AI: "健康リスク: 低 (乳量低下の可能性)" (最終分析)
AI: [推奨アクション表示] (最終結果)
```

#### 書類生成プロセス
```
ユーザー: "今月の出荷報告書を作成して"

AI: "出荷データを収集中..." (即座に返答)
AI: "データ期間: 2025年1月1日〜31日" (処理状況)
AI: "出荷頭数: 45頭" (中間結果)
AI: "総出荷量: 1,250kg" (中間結果)
AI: "報告書テンプレートを適用中..." (処理状況)
AI: [PDF生成完了] (最終結果)
```

### 1.2. ユーザビリティ向上のポイント

- **即座のフィードバック**: ユーザーの指示に対して即座に応答
- **処理状況の可視化**: 何が行われているかをリアルタイムで表示
- **中間結果の表示**: 処理途中でも有用な情報を提供
- **進捗の把握**: 処理の完了予想時間や段階を表示
- **エラーの早期検出**: 問題が発生した場合の早期対応

## 2. 技術実装方式の比較

### 2.1. Server-Sent Events (SSE)

#### 概要
- HTTP接続を維持し、サーバーからクライアントへの一方向通信
- 標準的なWeb技術で実装可能
- 自動再接続機能あり

#### 実装例

```typescript
// サーバーサイド (Node.js + Express)
app.post('/api/chat/stream', async (req, res) => {
  const { message } = req.body;

  // SSEヘッダー設定
  res.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'Access-Control-Allow-Origin': '*'
  });

  try {
    // 即座の応答
    res.write(`data: ${JSON.stringify({
      type: 'status',
      message: '処理を開始しました...',
      timestamp: new Date().toISOString()
    })}\n\n`);

    // 個体検索処理
    res.write(`data: ${JSON.stringify({
      type: 'status',
      message: '個体データを検索中...',
      timestamp: new Date().toISOString()
    })}\n\n`);

    const individuals = await searchIndividuals(message);

    // 中間結果
    res.write(`data: ${JSON.stringify({
      type: 'intermediate',
      message: `${individuals.length}頭の個体が見つかりました`,
      data: { count: individuals.length },
      timestamp: new Date().toISOString()
    })}\n\n`);

    // 最終結果
    res.write(`data: ${JSON.stringify({
      type: 'result',
      message: '個体リストを生成しました',
      data: { individuals },
      timestamp: new Date().toISOString()
    })}\n\n`);

    res.write('data: [DONE]\n\n');
  } catch (error) {
    res.write(`data: ${JSON.stringify({
      type: 'error',
      message: 'エラーが発生しました',
      error: error.message,
      timestamp: new Date().toISOString()
    })}\n\n`);
  }

  res.end();
});

// クライアントサイド
const useChatStream = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isStreaming, setIsStreaming] = useState(false);

  const sendMessage = async (message: string) => {
    setIsStreaming(true);

    const eventSource = new EventSource(`/api/chat/stream?message=${encodeURIComponent(message)}`);

    eventSource.onmessage = (event) => {
      if (event.data === '[DONE]') {
        eventSource.close();
        setIsStreaming(false);
        return;
      }

      const data = JSON.parse(event.data);

      switch (data.type) {
        case 'status':
          // 処理状況の表示
          setMessages(prev => [...prev, {
            id: Date.now().toString(),
            type: 'status',
            content: data.message,
            timestamp: data.timestamp
          }]);
          break;

        case 'intermediate':
          // 中間結果の表示
          setMessages(prev => [...prev, {
            id: Date.now().toString(),
            type: 'intermediate',
            content: data.message,
            data: data.data,
            timestamp: data.timestamp
          }]);
          break;

        case 'result':
          // 最終結果の表示
          setMessages(prev => [...prev, {
            id: Date.now().toString(),
            type: 'result',
            content: data.message,
            data: data.data,
            timestamp: data.timestamp
          }]);
          break;

        case 'error':
          // エラーの表示
          setMessages(prev => [...prev, {
            id: Date.now().toString(),
            type: 'error',
            content: data.message,
            error: data.error,
            timestamp: data.timestamp
          }]);
          break;
      }
    };

    eventSource.onerror = (error) => {
      console.error('SSE Error:', error);
      eventSource.close();
      setIsStreaming(false);
    };
  };

  return { messages, isStreaming, sendMessage };
};
```

#### メリット
- 実装が比較的簡単
- 標準的なWeb技術
- 自動再接続機能
- 軽量

#### デメリット
- 一方向通信のみ
- 接続数に制限がある場合がある
- プロキシやロードバランサーでの制限

### 2.2. WebSocket

#### 概要
- 双方向通信が可能
- リアルタイム性が高い
- 接続維持によるオーバーヘッド

#### 実装例

```typescript
// サーバーサイド (Node.js + Socket.IO)
io.on('connection', (socket) => {
  socket.on('chat-message', async (data) => {
    const { message, sessionId } = data;

    try {
      // 即座の応答
      socket.emit('chat-response', {
        type: 'status',
        message: '処理を開始しました...',
        sessionId,
        timestamp: new Date().toISOString()
      });

      // 個体検索処理
      socket.emit('chat-response', {
        type: 'status',
        message: '個体データを検索中...',
        sessionId,
        timestamp: new Date().toISOString()
      });

      const individuals = await searchIndividuals(message);

      // 中間結果
      socket.emit('chat-response', {
        type: 'intermediate',
        message: `${individuals.length}頭の個体が見つかりました`,
        data: { count: individuals.length },
        sessionId,
        timestamp: new Date().toISOString()
      });

      // 最終結果
      socket.emit('chat-response', {
        type: 'result',
        message: '個体リストを生成しました',
        data: { individuals },
        sessionId,
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      socket.emit('chat-response', {
        type: 'error',
        message: 'エラーが発生しました',
        error: error.message,
        sessionId,
        timestamp: new Date().toISOString()
      });
    }
  });
});

// クライアントサイド
const useWebSocketChat = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isConnected, setIsConnected] = useState(false);
  const socketRef = useRef<Socket | null>(null);

  useEffect(() => {
    socketRef.current = io('/chat');

    socketRef.current.on('connect', () => {
      setIsConnected(true);
    });

    socketRef.current.on('disconnect', () => {
      setIsConnected(false);
    });

    socketRef.current.on('chat-response', (data) => {
      setMessages(prev => [...prev, {
        id: Date.now().toString(),
        type: data.type,
        content: data.message,
        data: data.data,
        error: data.error,
        timestamp: data.timestamp
      }]);
    });

    return () => {
      socketRef.current?.disconnect();
    };
  }, []);

  const sendMessage = (message: string) => {
    if (socketRef.current && isConnected) {
      socketRef.current.emit('chat-message', {
        message,
        sessionId: generateSessionId()
      });
    }
  };

  return { messages, isConnected, sendMessage };
};
```

#### メリット
- 双方向通信が可能
- リアルタイム性が高い
- 接続状態の管理が容易

#### デメリット
- 実装が複雑
- 接続維持のオーバーヘッド
- ファイアウォールでの制限

### 2.3. HTTP Streaming (Chunked Transfer Encoding)

#### 概要
- HTTPレスポンスをストリーミング
- 標準的なHTTPプロトコル
- プロキシでの制限が少ない

#### 実装例

```typescript
// サーバーサイド
app.post('/api/chat/stream', async (req, res) => {
  const { message } = req.body;

  res.setHeader('Content-Type', 'application/json');
  res.setHeader('Transfer-Encoding', 'chunked');

  const sendChunk = (data: any) => {
    res.write(JSON.stringify(data) + '\n');
  };

  try {
    // 即座の応答
    sendChunk({
      type: 'status',
      message: '処理を開始しました...',
      timestamp: new Date().toISOString()
    });

    // 個体検索処理
    sendChunk({
      type: 'status',
      message: '個体データを検索中...',
      timestamp: new Date().toISOString()
    });

    const individuals = await searchIndividuals(message);

    // 中間結果
    sendChunk({
      type: 'intermediate',
      message: `${individuals.length}頭の個体が見つかりました`,
      data: { count: individuals.length },
      timestamp: new Date().toISOString()
    });

    // 最終結果
    sendChunk({
      type: 'result',
      message: '個体リストを生成しました',
      data: { individuals },
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    sendChunk({
      type: 'error',
      message: 'エラーが発生しました',
      error: error.message,
      timestamp: new Date().toISOString()
    });
  }

  res.end();
});

// クライアントサイド
const useStreamingChat = () => {
  const [messages, setMessages] = useState<Message[]>([]);
  const [isStreaming, setIsStreaming] = useState(false);

  const sendMessage = async (message: string) => {
    setIsStreaming(true);

    try {
      const response = await fetch('/api/chat/stream', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ message })
      });

      const reader = response.body?.getReader();
      const decoder = new TextDecoder();

      if (reader) {
        while (true) {
          const { done, value } = await reader.read();

          if (done) break;

          const chunk = decoder.decode(value);
          const lines = chunk.split('\n').filter(line => line.trim());

          for (const line of lines) {
            try {
              const data = JSON.parse(line);

              setMessages(prev => [...prev, {
                id: Date.now().toString(),
                type: data.type,
                content: data.message,
                data: data.data,
                error: data.error,
                timestamp: data.timestamp
              }]);
            } catch (error) {
              console.error('JSON parse error:', error);
            }
          }
        }
      }
    } catch (error) {
      console.error('Streaming error:', error);
    } finally {
      setIsStreaming(false);
    }
  };

  return { messages, isStreaming, sendMessage };
};
```

#### メリット
- 標準的なHTTPプロトコル
- プロキシでの制限が少ない
- 実装が比較的簡単

#### デメリット
- 一方向通信のみ
- エラーハンドリングが複雑
- 接続管理が困難

## 3. 推奨実装方式

### 3.1. ハイブリッドアプローチ

Farmnote Cloud Platformでは、**Server-Sent Events (SSE)**を基本とし、必要に応じて**WebSocket**を併用するハイブリッドアプローチを推奨します。

#### 選定理由
1. **SSEの利点を活用**: 実装が簡単で標準的
2. **WebSocketの利点を活用**: 双方向通信が必要な場合のみ使用
3. **段階的実装**: まずSSEで基本機能を実装し、後からWebSocketを追加可能

### 3.2. 実装アーキテクチャ

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

  const addStatusMessage = (data: StreamResponse) => {
    setMessages(prev => [...prev, {
      id: Date.now().toString(),
      type: 'status',
      content: data.message,
      timestamp: data.timestamp,
      isStreaming: true
    }]);
  };

  const addIntermediateMessage = (data: StreamResponse) => {
    setMessages(prev => [...prev, {
      id: Date.now().toString(),
      type: 'intermediate',
      content: data.message,
      data: data.data,
      timestamp: data.timestamp,
      isStreaming: true
    }]);
  };

  const addResultMessage = (data: StreamResponse) => {
    setMessages(prev => [...prev, {
      id: Date.now().toString(),
      type: 'result',
      content: data.message,
      data: data.data,
      timestamp: data.timestamp,
      isStreaming: false
    }]);
  };

  const addErrorMessage = (data: StreamResponse) => {
    setMessages(prev => [...prev, {
      id: Date.now().toString(),
      type: 'error',
      content: data.message,
      error: data.error,
      timestamp: data.timestamp,
      isStreaming: false
    }]);
  };

  const updateProgress = (progressData: any) => {
    setProgress(progressData);
  };

  return {
    messages,
    isStreaming,
    progress,
    sendMessage
  };
};
```

### 3.3. UI実装

```typescript
// ストリーミングメッセージコンポーネント
const StreamingMessage: React.FC<{ message: Message }> = ({ message }) => {
  const [displayText, setDisplayText] = useState('');
  const [isTyping, setIsTyping] = useState(false);

  useEffect(() => {
    if (message.isStreaming) {
      setIsTyping(true);
      // タイピングアニメーション
      typeText(message.content, setDisplayText, () => {
        setIsTyping(false);
      });
    } else {
      setDisplayText(message.content);
    }
  }, [message]);

  return (
    <div className={`message ${message.type}`}>
      <div className="message-content">
        {displayText}
        {isTyping && <TypingIndicator />}
      </div>

      {message.data && (
        <div className="message-data">
          <DataRenderer data={message.data} type={message.type} />
        </div>
      )}

      {message.progress && (
        <div className="message-progress">
          <ProgressBar
            current={message.progress.current}
            total={message.progress.total}
            percentage={message.progress.percentage}
          />
        </div>
      )}
    </div>
  );
};

// プログレスバーコンポーネント
const ProgressBar: React.FC<{ current: number; total: number; percentage: number }> = ({
  current,
  total,
  percentage
}) => (
  <div className="progress-bar">
    <div className="progress-fill" style={{ width: `${percentage}%` }} />
    <div className="progress-text">
      {current} / {total} ({percentage}%)
    </div>
  </div>
);
```

## 4. 実装優先順位

### Phase 1: 基本ストリーミング機能（2週間）
1. SSEによる基本的なストリーミング実装
2. ステータスメッセージの表示
3. エラーハンドリング

### Phase 2: リッチなストリーミング機能（2週間）
1. 中間結果の表示
2. プログレスバーの実装
3. タイピングアニメーション

### Phase 3: 高度な機能（1週間）
1. WebSocketとの併用
2. 接続管理の最適化
3. パフォーマンス改善

## 5. 技術的考慮事項

### 5.1. パフォーマンス
- **接続プール**: 同時接続数の管理
- **メモリ管理**: 長時間接続でのメモリリーク防止
- **タイムアウト**: 適切なタイムアウト設定

### 5.2. エラーハンドリング
- **接続エラー**: 自動再接続機能
- **データエラー**: 不正なデータの処理
- **タイムアウト**: 処理時間の制限

### 5.3. セキュリティ
- **認証**: セッション管理
- **レート制限**: リクエスト頻度の制限
- **データ検証**: 入力データの検証

この設計により、Farmnote Cloud PlatformのAIアシスタント機能が、ユーザーにとってより自然で直感的な対話体験を提供できると考えられます。
