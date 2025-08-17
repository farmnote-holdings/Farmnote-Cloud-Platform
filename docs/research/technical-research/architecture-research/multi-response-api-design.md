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

## 5. AWS Lambda環境でのSocket実装におけるインフラ構成

### 5.1. Lambda環境でのSocket実装の課題

#### 5.1.1. 主な制約事項
- **実行時間制限**: Lambda関数は最大15分の実行時間制限
- **接続維持**: サーバーレス環境では長時間接続の維持が困難
- **ステート管理**: 関数間での状態共有が困難
- **スケーラビリティ**: 同時接続数の管理が複雑

#### 5.1.2. Socket実装方式の比較

##### 方式A: API Gateway WebSocket + Lambda
```yaml
# serverless.yml 設定例
functions:
  websocket-handler:
    handler: handlers/websocket.handler
    events:
      - websocket:
          route: $connect
      - websocket:
          route: $disconnect
      - websocket:
          route: $default
    timeout: 30
    memorySize: 512

  chat-processor:
    handler: handlers/chat.handler
    events:
      - websocket:
          route: chat-message
    timeout: 900  # 15分
    memorySize: 1024
```

**メリット**
- AWSネイティブな実装
- 自動スケーリング
- 統合された認証・認可

**デメリット**
- 複雑な状態管理
- コストが高くなる可能性
- デバッグが困難

##### 方式B: ElastiCache + Lambda
```yaml
# serverless.yml 設定例
resources:
  Resources:
    RedisCluster:
      Type: AWS::ElastiCache::ReplicationGroup
      Properties:
        ReplicationGroupDescription: "Chat session cache"
        NodeType: cache.t3.micro
        NumCacheClusters: 1
        Engine: redis
        Port: 6379

functions:
  chat-handler:
    handler: handlers/chat.handler
    environment:
      REDIS_ENDPOINT: !GetAtt RedisCluster.PrimaryEndPoint.Address
    vpc:
      securityGroupIds:
        - sg-xxxxxxxxx
      subnetIds:
        - subnet-xxxxxxxxx
```

**メリット**
- 状態管理が容易
- リアルタイム性が高い
- スケーラブル

**デメリット**
- VPC設定が必要
- コールドスタート時間の増加
- 複雑なネットワーク設定

##### 方式C: DynamoDB Streams + Lambda
```yaml
# serverless.yml 設定例
functions:
  chat-processor:
    handler: handlers/chat.handler
    events:
      - http:
          path: /chat
          method: post
    environment:
      DYNAMODB_TABLE: ${self:service}-chat-sessions

  stream-handler:
    handler: handlers/stream.handler
    events:
      - stream:
          type: dynamodb
          arn: !GetAtt ChatSessionsTable.StreamArn
          batchSize: 1
```

**メリット**
- サーバーレスネイティブ
- 自動スケーリング
- イベント駆動

**デメリット**
- レイテンシーが高い
- 複雑なイベント処理
- コストが高くなる可能性

### 5.2. 推奨アーキテクチャ: ハイブリッド方式

#### 5.2.1. アーキテクチャ概要

```
[クライアント]
    ↓ WebSocket
[API Gateway WebSocket]
    ↓ イベント
[Lambda Functions]
    ↓ 状態管理
[DynamoDB + ElastiCache]
    ↓ 通知
[API Gateway Management API]
    ↓ WebSocket
[クライアント]
```

#### 5.2.2. 詳細実装

```typescript
// handlers/websocket.ts
export const handler = async (event: APIGatewayProxyEvent) => {
  const { routeKey, connectionId } = event.requestContext;

  switch (routeKey) {
    case '$connect':
      return await handleConnect(connectionId);
    case '$disconnect':
      return await handleDisconnect(connectionId);
    case 'chat-message':
      return await handleChatMessage(event, connectionId);
    default:
      return { statusCode: 400, body: 'Unknown route' };
  }
};

// handlers/chat.ts
export const chatHandler = async (event: APIGatewayProxyEvent) => {
  const { connectionId } = event.requestContext;
  const { message } = JSON.parse(event.body || '{}');

  try {
    // 即座の応答
    await sendToClient(connectionId, {
      type: 'status',
      message: '処理を開始しました...',
      timestamp: new Date().toISOString()
    });

    // 非同期処理の開始
    await startAsyncProcessing(connectionId, message);

    return { statusCode: 200, body: 'Processing started' };
  } catch (error) {
    console.error('Chat handler error:', error);
    return { statusCode: 500, body: 'Internal server error' };
  }
};

// handlers/async-processor.ts
export const asyncProcessor = async (event: SQSEvent) => {
  for (const record of event.Records) {
    const { connectionId, message } = JSON.parse(record.body);

    try {
      // 個体検索処理
      await sendToClient(connectionId, {
        type: 'status',
        message: '個体データを検索中...',
        timestamp: new Date().toISOString()
      });

      const individuals = await searchIndividuals(message);

      // 中間結果
      await sendToClient(connectionId, {
        type: 'intermediate',
        message: `${individuals.length}頭の個体が見つかりました`,
        data: { count: individuals.length },
        timestamp: new Date().toISOString()
      });

      // 最終結果
      await sendToClient(connectionId, {
        type: 'result',
        message: '個体リストを生成しました',
        data: { individuals },
        timestamp: new Date().toISOString()
      });

    } catch (error) {
      await sendToClient(connectionId, {
        type: 'error',
        message: 'エラーが発生しました',
        error: error.message,
        timestamp: new Date().toISOString()
      });
    }
  }
};

// utils/websocket.ts
export const sendToClient = async (connectionId: string, data: any) => {
  const apiGateway = new ApiGatewayManagementApi({
    endpoint: process.env.WEBSOCKET_ENDPOINT
  });

  try {
    await apiGateway.postToConnection({
      ConnectionId: connectionId,
      Data: JSON.stringify(data)
    }).promise();
  } catch (error) {
    if (error.statusCode === 410) {
      // 接続が切断されている場合
      await removeConnection(connectionId);
    } else {
      throw error;
    }
  }
};
```

#### 5.2.3. インフラストラクチャ設定

```yaml
# serverless.yml
service: farmnote-chat-platform

provider:
  name: aws
  runtime: nodejs18.x
  region: ap-northeast-1
  environment:
    WEBSOCKET_ENDPOINT: !Sub "${WebsocketsApi}.execute-api.${AWS::Region}.amazonaws.com/${sls:stage}"
    DYNAMODB_TABLE: ${self:service}-connections-${sls:stage}
    REDIS_ENDPOINT: !GetAtt RedisCluster.PrimaryEndPoint.Address

functions:
  websocket-handler:
    handler: handlers/websocket.handler
    events:
      - websocket:
          route: $connect
      - websocket:
          route: $disconnect
      - websocket:
          route: chat-message
    timeout: 30
    memorySize: 512

  async-processor:
    handler: handlers/async-processor.handler
    events:
      - sqs:
          arn: !GetAtt ChatQueue.Arn
          batchSize: 1
    timeout: 900
    memorySize: 1024
    reservedConcurrencyLimit: 10

  connection-cleanup:
    handler: handlers/cleanup.handler
    events:
      - schedule: rate(5 minutes)
    timeout: 60
    memorySize: 256

resources:
  Resources:
    WebsocketsApi:
      Type: AWS::ApiGatewayV2::Api
      Properties:
        Name: ${self:service}-websockets-${sls:stage}
        ProtocolType: WEBSOCKET
        RouteSelectionExpression: "$request.body.action"

    ConnectionsTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: ${self:service}-connections-${sls:stage}
        BillingMode: PAY_PER_REQUEST
        AttributeDefinitions:
          - AttributeName: connectionId
            AttributeType: S
        KeySchema:
          - AttributeName: connectionId
            KeyType: HASH
        TimeToLiveSpecification:
          AttributeName: ttl
          Enabled: true

    ChatQueue:
      Type: AWS::SQS::Queue
      Properties:
        QueueName: ${self:service}-chat-queue-${sls:stage}
        VisibilityTimeoutSeconds: 900
        MessageRetentionPeriod: 1209600
        RedrivePolicy:
          deadLetterTargetArn: !GetAtt ChatDLQ.Arn
          maxReceiveCount: 3

    ChatDLQ:
      Type: AWS::SQS::Queue
      Properties:
        QueueName: ${self:service}-chat-dlq-${sls:stage}

    RedisCluster:
      Type: AWS::ElastiCache::ReplicationGroup
      Properties:
        ReplicationGroupDescription: "Chat session cache"
        NodeType: cache.t3.micro
        NumCacheClusters: 1
        Engine: redis
        Port: 6379
        SecurityGroupIds:
          - !Ref RedisSecurityGroup
        SubnetGroupName: !Ref RedisSubnetGroup

    RedisSecurityGroup:
      Type: AWS::EC2::SecurityGroup
      Properties:
        GroupDescription: "Redis security group"
        VpcId: !Ref VPC
        SecurityGroupIngress:
          - IpProtocol: tcp
            FromPort: 6379
            ToPort: 6379
            SourceSecurityGroupId: !Ref LambdaSecurityGroup

    RedisSubnetGroup:
      Type: AWS::ElastiCache::SubnetGroup
      Properties:
        Description: "Redis subnet group"
        SubnetIds:
          - !Ref PrivateSubnet1
          - !Ref PrivateSubnet2

    LambdaSecurityGroup:
      Type: AWS::EC2::SecurityGroup
      Properties:
        GroupDescription: "Lambda security group"
        VpcId: !Ref VPC
        SecurityGroupEgress:
          - IpProtocol: -1
            CidrIp: 0.0.0.0/0

    VPC:
      Type: AWS::EC2::VPC
      Properties:
        CidrBlock: 10.0.0.0/16
        EnableDnsHostnames: true
        EnableDnsSupport: true

    PrivateSubnet1:
      Type: AWS::EC2::Subnet
      Properties:
        VpcId: !Ref VPC
        CidrBlock: 10.0.1.0/24
        AvailabilityZone: !Select [0, !GetAZs '']

    PrivateSubnet2:
      Type: AWS::EC2::Subnet
      Properties:
        VpcId: !Ref VPC
        CidrBlock: 10.0.2.0/24
        AvailabilityZone: !Select [1, !GetAZs '']
```

### 5.3. コスト最適化戦略

#### 5.3.1. コスト分析

| コンポーネント | 月間コスト（概算） | 最適化ポイント |
|---|---|---|
| API Gateway WebSocket | $1.25/100万メッセージ | メッセージ数の削減 |
| Lambda実行時間 | $0.20/100万リクエスト | 実行時間の短縮 |
| DynamoDB | $1.25/100万読み書き | TTL設定の最適化 |
| ElastiCache | $13.68/月（t3.micro） | インスタンスサイズの調整 |
| SQS | $0.40/100万メッセージ | メッセージサイズの最適化 |

#### 5.3.2. 最適化手法

1. **接続プール**: 不要な接続の早期切断
2. **メッセージバッチング**: 複数メッセージの一括送信
3. **TTL設定**: DynamoDBの自動削除設定
4. **リザーブドキャパシティ**: 予測可能な負荷への対応

### 5.4. 監視とログ

#### 5.4.1. CloudWatch設定

```yaml
# serverless.yml の functions セクションに追加
functions:
  websocket-handler:
    # ... 既存設定 ...
    logRetentionInDays: 14
    tags:
      Environment: ${sls:stage}
      Service: chat-platform

  # CloudWatch Alarms
  Resources:
    HighErrorRateAlarm:
      Type: AWS::CloudWatch::Alarm
      Properties:
        AlarmName: ${self:service}-high-error-rate-${sls:stage}
        MetricName: Errors
        Namespace: AWS/Lambda
        Statistic: Sum
        Period: 300
        EvaluationPeriods: 2
        Threshold: 10
        ComparisonOperator: GreaterThanThreshold
        AlarmActions:
          - !Ref SNSTopic

    HighLatencyAlarm:
      Type: AWS::CloudWatch::Alarm
      Properties:
        AlarmName: ${self:service}-high-latency-${sls:stage}
        MetricName: Duration
        Namespace: AWS/Lambda
        Statistic: Average
        Period: 300
        EvaluationPeriods: 2
        Threshold: 5000
        ComparisonOperator: GreaterThanThreshold
        AlarmActions:
          - !Ref SNSTopic
```

## 6. 技術的考慮事項

### 6.1. パフォーマンス
- **接続プール**: 同時接続数の管理
- **メモリ管理**: 長時間接続でのメモリリーク防止
- **タイムアウト**: 適切なタイムアウト設定
- **コールドスタート**: VPC Lambdaの起動時間対策

### 6.2. エラーハンドリング
- **接続エラー**: 自動再接続機能
- **データエラー**: 不正なデータの処理
- **タイムアウト**: 処理時間の制限
- **DLQ活用**: 失敗したメッセージの再処理

### 6.3. セキュリティ
- **認証**: セッション管理
- **レート制限**: リクエスト頻度の制限
- **データ検証**: 入力データの検証
- **VPC分離**: ネットワークレベルのセキュリティ

### 6.4. 運用考慮事項
- **デプロイ戦略**: Blue-Greenデプロイメント
- **ロールバック**: 問題発生時の迅速な復旧
- **バックアップ**: データの定期バックアップ
- **監視**: リアルタイム監視とアラート

この設計により、AWS Lambda環境でも効率的でスケーラブルなSocket実装が可能になり、Farmnote Cloud PlatformのAIアシスタント機能が、ユーザーにとってより自然で直感的な対話体験を提供できると考えられます。
