# 個体リスト表示拡張機能 実装方針

## 概要

AIチャットアプリにおける個体リスト表示機能の拡張について検討します。ユーザーからの自然言語問い合わせに対して、リッチでインタラクティブな個体リストを表示し、農業現場での実用性を最大化する設計を提案します。

## 1. 背景と課題

### 1.1. 現状の課題

ヒアリング結果から以下の課題が明確になっています：

- **個体リスト作成の複雑性**: 「N=と同じ」のような専門用語や複雑な条件設定がITに不慣れなユーザーの障壁となっている
- **大規模牧場での管理困難**: 現行Today機能は長大な「巻き物」状態で管理が困難
- **レポート目的での乱用**: 個体リストがレポート作成ツールとして使われ、リスト数が無尽蔵に増加
- **UIの煩雑化**: 大量のリストによるパフォーマンス低下とUIの複雑化

### 1.2. AIアシスタントによる解決

- **自然言語での指示**: 「不受胎リスト教えて」「削蹄が必要な牛のリストを作って」などの直感的な指示
- **個体リストの95%を代替**: レポート・集計目的の個体リスト作成をAIアシスタントで代替
- **ユーザビリティの大幅向上**: 複雑な条件設定スキルが不要になり、誰でも簡単に牛群データへアクセス

## 2. 個体リスト表示の拡張設計

### 2.1. 基本アーキテクチャ

```typescript
interface IndividualListDisplay {
  // リスト基本情報
  id: string;
  title: string;
  description: string;
  query: string; // 元の問い合わせ文

  // 表示設定
  displayMode: 'table' | 'card' | 'timeline' | 'map';
  sortBy: string;
  sortOrder: 'asc' | 'desc';

  // フィルタリング
  filters: Filter[];
  groupBy?: string;

  // データ
  individuals: Individual[];
  summary: ListSummary;

  // アクション
  actions: Action[];
  exportOptions: ExportOption[];
}
```

### 2.2. 個体データ構造

```typescript
interface Individual {
  id: string;
  name: string;
  earTag: string;
  breed: string;
  birthDate: Date;
  age: number;

  // 健康状態
  healthStatus: HealthStatus;
  symptoms: Symptom[];
  treatments: Treatment[];

  // 繁殖情報
  breedingStatus: BreedingStatus;
  lastBreeding: Date;
  pregnancyStatus: PregnancyStatus;

  // 生産情報
  milkProduction: MilkProduction;
  feedIntake: FeedIntake;

  // 位置情報
  location: Location;
  group: string;

  // 画像・ビジュアル
  photo?: string;
  visualIndicators: VisualIndicator[];

  // 優先度・緊急度
  priority: 'low' | 'medium' | 'high' | 'urgent';
  urgency: number;
}
```

## 3. 表示モードの拡張

### 3.1. テーブルモード（基本）

```typescript
const TableModeRenderer: IndividualListRenderer = {
  type: 'individual-table',
  priority: 1,
  canRender: (content) => content.type === 'individual-list',
  render: (content, props) => (
    <IndividualTable
      individuals={content.individuals}
      columns={getColumnsForQuery(content.query)}
      sortable={true}
      filterable={true}
      selectable={true}
      onSelectionChange={props.onSelectionChange}
      onRowClick={props.onRowClick}
      summaryRow={true}
      exportable={true}
    />
  )
};

// 問い合わせに応じたカラム設定
const getColumnsForQuery = (query: string): Column[] => {
  if (query.includes('発情')) {
    return [
      { key: 'name', label: '個体名', sortable: true },
      { key: 'lastBreeding', label: '最終種付日', sortable: true },
      { key: 'breedingStatus', label: '繁殖状態', sortable: true },
      { key: 'priority', label: '優先度', sortable: true },
      { key: 'actions', label: 'アクション', sortable: false }
    ];
  }

  if (query.includes('健康')) {
    return [
      { key: 'name', label: '個体名', sortable: true },
      { key: 'healthStatus', label: '健康状態', sortable: true },
      { key: 'symptoms', label: '症状', sortable: false },
      { key: 'lastTreatment', label: '最終治療日', sortable: true },
      { key: 'urgency', label: '緊急度', sortable: true }
    ];
  }

  // デフォルトカラム
  return DEFAULT_COLUMNS;
};
```

### 3.2. カードモード（ビジュアル重視）

```typescript
const CardModeRenderer: IndividualListRenderer = {
  type: 'individual-cards',
  priority: 2,
  canRender: (content) => content.type === 'individual-list' && content.displayMode === 'card',
  render: (content, props) => (
    <IndividualCardGrid
      individuals={content.individuals}
      layout="grid"
      cardSize="medium"
      showPhotos={true}
      showStatusIndicators={true}
      onCardClick={props.onRowClick}
      onCardAction={props.onAction}
    />
  )
};

// 個体カードコンポーネント
const IndividualCard: React.FC<{ individual: Individual }> = ({ individual }) => (
  <Card className="individual-card">
    <CardHeader>
      <div className="individual-photo">
        <img src={individual.photo || '/default-cow.png'} alt={individual.name} />
        <StatusIndicator status={individual.healthStatus} />
      </div>
      <div className="individual-info">
        <h3>{individual.name}</h3>
        <p>{individual.earTag}</p>
        <Tag color={getPriorityColor(individual.priority)}>
          {individual.priority}
        </Tag>
      </div>
    </CardHeader>

    <CardBody>
      <div className="individual-stats">
        <Stat label="年齢" value={`${individual.age}歳`} />
        <Stat label="乳量" value={`${individual.milkProduction.daily}kg`} />
        <Stat label="繁殖状態" value={individual.breedingStatus} />
      </div>

      {individual.symptoms.length > 0 && (
        <div className="symptoms">
          <h4>症状</h4>
          <ul>
            {individual.symptoms.map(symptom => (
              <li key={symptom.id}>{symptom.name}</li>
            ))}
          </ul>
        </div>
      )}
    </CardBody>

    <CardFooter>
      <ActionButtons individual={individual} />
    </CardFooter>
  </Card>
);
```

### 3.3. タイムラインモード（時系列重視）

```typescript
const TimelineModeRenderer: IndividualListRenderer = {
  type: 'individual-timeline',
  priority: 3,
  canRender: (content) => content.type === 'individual-list' && content.displayMode === 'timeline',
  render: (content, props) => (
    <IndividualTimeline
      individuals={content.individuals}
      timelineType={getTimelineType(content.query)}
      groupBy="date"
      showMilestones={true}
      onEventClick={props.onEventClick}
    />
  )
};

// 繁殖計画タイムライン
const BreedingTimeline: React.FC<{ individuals: Individual[] }> = ({ individuals }) => (
  <Timeline>
    {individuals.map(individual => (
      <TimelineItem key={individual.id}>
        <TimelineHeader>
          <h4>{individual.name}</h4>
          <Tag color={getBreedingStatusColor(individual.breedingStatus)}>
            {individual.breedingStatus}
          </Tag>
        </TimelineHeader>

        <TimelineBody>
          <div className="breeding-events">
            {individual.breedingEvents.map(event => (
              <TimelineEvent
                key={event.id}
                date={event.date}
                type={event.type}
                description={event.description}
                status={event.status}
              />
            ))}
          </div>
        </TimelineBody>
      </TimelineItem>
    ))}
  </Timeline>
);
```

### 3.4. マップモード（位置情報重視）

```typescript
const MapModeRenderer: IndividualListRenderer = {
  type: 'individual-map',
  priority: 4,
  canRender: (content) => content.type === 'individual-list' && content.displayMode === 'map',
  render: (content, props) => (
    <IndividualMap
      individuals={content.individuals}
      mapType="facility"
      showGroups={true}
      showHealthStatus={true}
      onMarkerClick={props.onRowClick}
      clustering={true}
    />
  )
};
```

## 4. インタラクティブ機能の拡張

### 4.1. リアルタイムフィルタリング

```typescript
const InteractiveFilters: React.FC<{ filters: Filter[]; onFilterChange: (filters: Filter[]) => void }> = ({
  filters,
  onFilterChange
}) => {
  const [activeFilters, setActiveFilters] = useState<Filter[]>(filters);

  const handleFilterChange = (filter: Filter) => {
    const newFilters = activeFilters.map(f =>
      f.id === filter.id ? filter : f
    );
    setActiveFilters(newFilters);
    onFilterChange(newFilters);
  };

  return (
    <div className="interactive-filters">
      <FilterGroup title="健康状態">
        <FilterChip
          label="健康"
          value="healthy"
          checked={activeFilters.some(f => f.value === 'healthy')}
          onChange={(checked) => handleFilterChange({ id: 'health', value: 'healthy', checked })}
        />
        <FilterChip
          label="要観察"
          value="observation"
          checked={activeFilters.some(f => f.value === 'observation')}
          onChange={(checked) => handleFilterChange({ id: 'health', value: 'observation', checked })}
        />
        <FilterChip
          label="治療中"
          value="treatment"
          checked={activeFilters.some(f => f.value === 'treatment')}
          onChange={(checked) => handleFilterChange({ id: 'health', value: 'treatment', checked })}
        />
      </FilterGroup>

      <FilterGroup title="繁殖状態">
        <FilterChip
          label="発情予定"
          value="estrus"
          checked={activeFilters.some(f => f.value === 'estrus')}
          onChange={(checked) => handleFilterChange({ id: 'breeding', value: 'estrus', checked })}
        />
        <FilterChip
          label="妊娠中"
          value="pregnant"
          checked={activeFilters.some(f => f.value === 'pregnant')}
          onChange={(checked) => handleFilterChange({ id: 'breeding', value: 'pregnant', checked })}
        />
      </FilterGroup>
    </div>
  );
};
```

### 4.2. 一括アクション

```typescript
const BulkActions: React.FC<{ selectedIndividuals: Individual[]; onAction: (action: string, individuals: Individual[]) => void }> = ({
  selectedIndividuals,
  onAction
}) => {
  const [isOpen, setIsOpen] = useState(false);

  const actions = [
    { id: 'export', label: 'エクスポート', icon: 'download' },
    { id: 'print', label: '印刷', icon: 'printer' },
    { id: 'share', label: '共有', icon: 'share' },
    { id: 'add-task', label: 'タスク追加', icon: 'plus' },
    { id: 'send-notification', label: '通知送信', icon: 'bell' }
  ];

  return (
    <div className="bulk-actions">
      <Button
        variant="secondary"
        disabled={selectedIndividuals.length === 0}
        onClick={() => setIsOpen(true)}
      >
        一括操作 ({selectedIndividuals.length}件選択)
      </Button>

      <Dropdown isOpen={isOpen} onToggle={setIsOpen}>
        <DropdownMenu>
          {actions.map(action => (
            <DropdownItem
              key={action.id}
              onClick={() => {
                onAction(action.id, selectedIndividuals);
                setIsOpen(false);
              }}
            >
              <Icon name={action.icon} />
              {action.label}
            </DropdownItem>
          ))}
        </DropdownMenu>
      </Dropdown>
    </div>
  );
};
```

### 4.3. スマートサマリー

```typescript
const SmartSummary: React.FC<{ individuals: Individual[]; query: string }> = ({
  individuals,
  query
}) => {
  const summary = useMemo(() => {
    return generateSummary(individuals, query);
  }, [individuals, query]);

  return (
    <div className="smart-summary">
      <SummaryCard title="基本統計">
        <Stat label="総頭数" value={individuals.length} />
        <Stat label="平均年齢" value={`${summary.averageAge}歳`} />
        <Stat label="健康な個体" value={`${summary.healthyCount}頭 (${summary.healthyPercentage}%)`} />
      </SummaryCard>

      <SummaryCard title="繁殖状況">
        <Stat label="発情予定" value={summary.estrusCount} />
        <Stat label="妊娠中" value={summary.pregnantCount} />
        <Stat label="分娩予定" value={summary.deliveryCount} />
      </SummaryCard>

      <SummaryCard title="生産状況">
        <Stat label="平均乳量" value={`${summary.averageMilkProduction}kg`} />
        <Stat label="高乳量個体" value={summary.highMilkCount} />
        <Stat label="低乳量個体" value={summary.lowMilkCount} />
      </SummaryCard>

      {summary.alerts.length > 0 && (
        <AlertCard title="注意事項" type="warning">
          <ul>
            {summary.alerts.map(alert => (
              <li key={alert.id}>{alert.message}</li>
            ))}
          </ul>
        </AlertCard>
      )}
    </div>
  );
};
```

## 5. 音声・自然言語連携

### 5.1. 音声による操作

```typescript
const VoiceControls: React.FC<{ onVoiceCommand: (command: string) => void }> = ({
  onVoiceCommand
}) => {
  const [isListening, setIsListening] = useState(false);
  const [interimText, setInterimText] = useState('');

  const voiceCommands = {
    '並び替え': (text: string) => handleSortCommand(text),
    'フィルター': (text: string) => handleFilterCommand(text),
    'エクスポート': () => handleExportCommand(),
    '印刷': () => handlePrintCommand(),
    '詳細表示': (text: string) => handleDetailCommand(text)
  };

  const handleVoiceInput = (text: string) => {
    const command = Object.keys(voiceCommands).find(cmd => text.includes(cmd));
    if (command) {
      voiceCommands[command](text);
    }
  };

  return (
    <div className="voice-controls">
      <Button
        variant={isListening ? "danger" : "primary"}
        icon={isListening ? "stop" : "microphone"}
        onClick={() => setIsListening(!isListening)}
      >
        {isListening ? "音声操作停止" : "音声操作"}
      </Button>

      {interimText && (
        <div className="voice-feedback">
          「{interimText}」
        </div>
      )}
    </div>
  );
};
```

### 5.2. 自然言語での絞り込み

```typescript
const NaturalLanguageFilter: React.FC<{ onFilter: (filter: string) => void }> = ({
  onFilter
}) => {
  const [filterText, setFilterText] = useState('');

  const handleNaturalLanguageFilter = async (text: string) => {
    // AIによる自然言語の解釈
    const interpretedFilter = await interpretNaturalLanguage(text);
    onFilter(interpretedFilter);
  };

  return (
    <div className="natural-language-filter">
      <Input
        placeholder="例: 乳量が低い個体、発情予定の個体、健康状態が悪い個体..."
        value={filterText}
        onChange={(e) => setFilterText(e.target.value)}
        onKeyPress={(e) => {
          if (e.key === 'Enter') {
            handleNaturalLanguageFilter(filterText);
          }
        }}
      />
      <Button onClick={() => handleNaturalLanguageFilter(filterText)}>
        絞り込み
      </Button>
    </div>
  );
};
```

## 6. パフォーマンス最適化

### 6.1. 仮想化による大量データ対応

```typescript
const VirtualizedIndividualList: React.FC<{ individuals: Individual[] }> = ({ individuals }) => {
  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => (
    <div style={style}>
      <IndividualRow individual={individuals[index]} />
    </div>
  );

  return (
    <List
      height={600}
      itemCount={individuals.length}
      itemSize={80}
      width="100%"
    >
      {Row}
    </List>
  );
};
```

### 6.2. 遅延読み込み

```typescript
const LazyIndividualCard = React.lazy(() => import('./IndividualCard'));

const IndividualCardGrid: React.FC<{ individuals: Individual[] }> = ({ individuals }) => (
  <div className="individual-grid">
    {individuals.map(individual => (
      <Suspense key={individual.id} fallback={<CardSkeleton />}>
        <LazyIndividualCard individual={individual} />
      </Suspense>
    ))}
  </div>
);
```

## 7. 実装優先順位

### Phase 1: 基本表示機能（2週間）
1. テーブルモードの基本実装
2. 基本的なフィルタリング機能
3. エクスポート機能
4. レスポンシブ対応

### Phase 2: ビジュアル表示（2週間）
1. カードモードの実装
2. タイムラインモードの実装
3. マップモードの実装
4. 画像・アイコン表示

### Phase 3: インタラクティブ機能（2週間）
1. リアルタイムフィルタリング
2. 一括アクション機能
3. スマートサマリー
4. 音声操作機能

### Phase 4: 最適化・改善（1週間）
1. パフォーマンス最適化
2. アクセシビリティ改善
3. ユーザビリティテスト
4. フィードバック反映

## 8. 技術スタック

### フロントエンド
- **React 18**: 最新のReact機能を活用
- **TypeScript**: 型安全性の確保
- **React Window**: 仮想化によるパフォーマンス向上
- **React Table**: 高機能なテーブル表示
- **Recharts**: チャート・グラフ表示

### 音声認識
- **Web Speech API**: ブラウザ標準の音声認識
- **農業専門用語辞書**: 認識精度向上

### 地図表示
- **Leaflet**: 軽量な地図ライブラリ
- **React Leaflet**: React統合

### 開発ツール
- **Storybook**: コンポーネント開発・テスト
- **Jest**: ユニットテスト
- **React Testing Library**: 統合テスト

この拡張により、AIチャットアプリの個体リスト表示機能が、農業現場での実用性を重視しつつ、リッチでインタラクティブな体験を提供できると考えられます。
