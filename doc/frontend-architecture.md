# Aura 前端代码级架构文档

本文档面向后续功能扩展和维护，基于当前仓库中的 Flutter 前端实现整理。代码范围主要是 `lib/`、`pubspec.yaml`、`assets/icons/` 和与前端 API 契约相关的 `openapi.json`。

## 1. 项目定位

Aura Weather 是一个 Flutter 天气应用。当前前端以单页首页为核心，访问后端 API 获取用户位置、实时天气、逐小时预报、逐日预报、空气质量和生活指数数据，再组合成天气首页。其中用户位置接口依赖本地持久化的设备 ID。

当前技术栈如下：

| 类别 | 实现 |
| --- | --- |
| UI 框架 | Flutter，Material 3 |
| 状态管理 | `provider` + `ChangeNotifier` |
| 网络请求 | `http.Client` |
| 本地持久化 | `shared_preferences` 保存 `device_id` |
| ID 生成 | `uuid` |
| 时间格式化 | `intl` |
| 静态资源 | `assets/icons/` 下的 pixel weather icons |
| 静态检查 | `flutter_lints`，通过 `flutter analyze` 运行 |

## 2. 目录结构

当前前端核心目录如下：

```text
lib/
  main.dart                         # 应用入口，Provider 注入，MaterialApp 配置
  config/
    app_config.dart                 # API base URL 配置
  data/
    api_repository.dart             # 后端 API 访问层
  models/
    location.dart                   # 位置响应模型
    weather_now.dart                # 实时天气模型
    weather_hourly.dart             # 逐小时天气模型
    weather_daily.dart              # 逐日天气模型
    indices.dart                    # AQI 与生活指数模型
  viewmodels/
    weather_view_model.dart         # 首页数据编排和状态更新
    weather_ui_state.dart           # 首页 UI 状态快照
  ui/
    home_screen.dart                # 首页容器和主组件编排
    hourly_forecast_card.dart       # 逐小时预报卡片
    daily_forecast_card.dart        # 逐日预报卡片
    details_grid.dart               # 当前天气详情网格
    aqi_section.dart                # 空气质量展示
    location_bottom_sheet.dart      # 位置选择弹窗，目前仍是模拟数据
    shapes/                         # 自定义 CustomPainter 视觉元素
  utils/
    weather_icons.dart              # 天气 icon code 到本地图片资源的映射

assets/icons/                       # 天气图标资源
openapi.json                        # 后端 API 契约
pubspec.yaml                        # Flutter 依赖与资产声明
```

## 3. 运行时架构

当前架构是典型的轻量 MVVM 分层：

```mermaid
flowchart TD
  main[lib/main.dart] --> provider[MultiProvider]
  provider --> vm[WeatherViewModel]
  main --> app[AuraWeatherApp / MaterialApp]
  app --> home[HomeScreen]
  home --> consumer[Consumer<WeatherViewModel>]
  consumer --> state[WeatherUiState]

  vm --> repo[ApiWeatherRepository]
  repo --> config[AppConfig.apiBaseUrl]
  repo --> prefs[SharedPreferences device_id]
  repo --> api[Aura API]

  api --> location[LocationResponse]
  api --> now[WeatherNow]
  api --> hourly[List<HourlyForecast>]
  api --> daily[List<DailyForecast>]
  api --> aqi[AqiNow]
  api --> indices[List<IndexInfo>]

  state --> cards[Home Cards]
  cards --> icons[getWeatherIcon]
  cards --> painters[CustomPainter shapes]
```

职责边界：

| 层 | 文件 | 职责 |
| --- | --- | --- |
| 应用入口 | `lib/main.dart` | 创建 Provider 树，配置 `MaterialApp`、主题和首页 |
| ViewModel | `lib/viewmodels/weather_view_model.dart` | 编排异步加载流程，把 Repository 结果合成为 UI 状态 |
| UI State | `lib/viewmodels/weather_ui_state.dart` | 保存页面需要展示的不可变状态快照 |
| Repository | `lib/data/api_repository.dart` | 处理设备 ID、请求头、API 调用和 JSON 到模型的转换入口 |
| Model | `lib/models/*.dart` | 把后端响应转换为 UI 可直接消费的数据结构 |
| UI | `lib/ui/*.dart` | 只读取 state 或组件参数，渲染 Material 组件、图片和自定义绘制 |
| Utils | `lib/utils/weather_icons.dart` | 天气图标资源选择 |
| Config | `lib/config/app_config.dart` | API base URL 常量 |

## 4. 应用入口和依赖注入

入口文件是 `lib/main.dart`。

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherViewModel()),
      ],
      child: const AuraWeatherApp(),
    ),
  );
}
```

关键点：

1. 当前只有一个全局状态对象：`WeatherViewModel`。
2. `WeatherViewModel` 在 `ChangeNotifierProvider` 中创建，生命周期由 Provider 管理。
3. `AuraWeatherApp` 返回 `MaterialApp`，使用 `ThemeData.colorScheme.fromSeed` 创建亮色和暗色主题。
4. `themeMode: ThemeMode.system`，应用跟随系统明暗模式。
5. `home: const HomeScreen()`，当前没有路由表，也没有多页面导航架构。

扩展影响：

1. 新增全局级状态时，优先在 `MultiProvider.providers` 中增加新的 `ChangeNotifierProvider`。
2. 新增独立页面时，可以从 `home` 扩展到 `routes`、`onGenerateRoute` 或 Router API。当前代码还未引入路由抽象。
3. 新增主题级 token 时，应集中放在 `ThemeData` 或独立 theme 文件中，避免在业务组件中散落常量。

## 5. 状态管理

### 5.1 WeatherUiState

`lib/viewmodels/weather_ui_state.dart` 定义首页展示状态：

```dart
class WeatherUiState {
  final bool isLoading;
  final String? errorMessage;
  final LocationResponse? location;
  final WeatherNow? weatherNow;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;
  final AqiNow? aqiNow;
  final List<IndexInfo> indices;
}
```

状态设计特点：

1. 使用字段聚合一个页面所需的全部数据。
2. 列表字段默认是空列表，减少 UI 层空判断。
3. 可空字段表示某个数据块暂不可用，例如 `weatherNow`、`aqiNow`。
4. 通过 `copyWith` 生成新状态，再由 ViewModel 调用 `notifyListeners()` 通知 UI。

注意事项：

1. 当前 `copyWith` 无法把可空字段显式设置回 `null`，因为 `null` 会被解释为保留旧值。例如 `errorMessage: null` 无法清空已有错误信息。当前加载开始时调用 `copyWith(isLoading: true, errorMessage: null)`，如果旧状态已有错误文本，理论上不会被清空。
2. 这不是文档任务要修复的问题，但后续扩展错误状态或刷新流程时需要留意。

### 5.2 WeatherViewModel

`lib/viewmodels/weather_view_model.dart` 是当前最重要的数据编排层。

生命周期：

1. 构造函数中立即调用 `loadWeatherData()`。
2. `loadWeatherData()` 先设置 `isLoading: true` 并通知 UI。
3. 通过 Repository 获取位置。
4. 根据 `longitude,latitude` 拼接天气 API 的 `location` query 参数。
5. 使用 `Future.wait` 并发请求天气相关接口。
6. 聚合结果后更新 `WeatherUiState`。
7. `dispose()` 时关闭 Repository 内部的 `http.Client`。

加载流程：

```mermaid
sequenceDiagram
  participant UI as HomeScreen
  participant VM as WeatherViewModel
  participant Repo as ApiWeatherRepository
  participant API as Backend API

  UI->>VM: Provider 创建 VM
  VM->>VM: loadWeatherData()
  VM->>UI: isLoading = true, notifyListeners()
  VM->>Repo: getLocation()
  Repo->>API: GET /user/location
  API-->>Repo: LocationResponse
  VM->>Repo: 并发请求 weather/aqi/indices
  Repo->>API: GET /weather/now
  Repo->>API: GET /weather/hourly
  Repo->>API: GET /weather/daily
  Repo->>API: GET /aqi/now
  Repo->>API: GET /indices
  API-->>Repo: JSON responses
  Repo-->>VM: Model objects
  VM->>UI: WeatherUiState, notifyListeners()
```

容错策略：

1. 每个天气接口都被 `_tryFetch` 包裹。
2. 单个接口失败时返回 `null`，不直接中断整次加载。
3. `weatherNow == null` 且 hourly、daily 都为空时，认为核心天气数据加载失败。
4. 加载失败时设置 `errorMessage: "Failed to load weather data. Pull to retry."`。
5. UI 错误页上提供 `Retry` 按钮，再次调用 `viewModel.loadWeatherData()`。

扩展建议：

1. 新增页面级数据时，先扩展 `WeatherUiState` 字段。
2. 再在 `WeatherViewModel.loadWeatherData()` 中添加 Repository 调用。
3. 如果新增接口不是首页首屏必需，建议继续沿用 `_tryFetch` 的软失败模式。
4. 如果新增接口是核心数据，必须把它纳入失败判定条件。

## 6. API Repository

`lib/data/api_repository.dart` 负责所有当前后端 API 调用。

### 6.1 配置

API base URL 位于 `lib/config/app_config.dart`，通过 Dart 编译时环境变量注入：

```dart
static final String apiBaseUrl = _loadApiBaseUrl();
// 内部使用 String.fromEnvironment('AURA_API_BASE_URL')
// 未设置时抛出 StateError
```

本地开发时，从示例文件复制并编辑 `.env.json`，然后通过 `--dart-define-from-file` 注入：

```bash
cp .env.example.json .env.json   # 编辑其中的 URL
flutter run --dart-define-from-file=.env.json
```

也可以单次注入：

```bash
flutter run --dart-define=AURA_API_BASE_URL=<api-base-url>
```

`.env.json` 已在 `.gitignore` 中，不会提交到仓库。所有 Repository 请求仍通过 `${AppConfig.apiBaseUrl}` 拼接。

### 6.2 设备 ID 和请求头

Repository 内部维护 `_deviceId` 缓存：

1. 优先从内存 `_deviceId` 返回。
2. 若为空，从 `SharedPreferences` 读取 `device_id`。
3. 若本地不存在，用 `Uuid().v4()` 生成并写入 `SharedPreferences`。
4. `_getHeaders()` 返回：

```dart
{
  'Content-Type': 'application/json',
  'X-Device-ID': deviceId,
}
```

目前只有位置相关接口传入 `_getHeaders()`，天气查询接口没有附带 `X-Device-ID`。

### 6.3 已接入接口

| 方法 | HTTP | 路径 | 返回模型 | 说明 |
| --- | --- | --- | --- | --- |
| `getLocation()` | GET | `/user/location` | `LocationResponse` | 获取当前设备保存的位置 |
| `saveLocation()` | POST | `/user/location` | `void` | 保存经纬度和城市名 |
| `getWeatherNow()` | GET | `/weather/now` | `WeatherNow` | 实时天气 |
| `getHourlyForecast()` | GET | `/weather/hourly` | `List<HourlyForecast>` | 逐小时预报 |
| `getDailyForecast()` | GET | `/weather/daily` | `List<DailyForecast>` | 逐日预报 |
| `getAqiNow()` | GET | `/aqi/now` | `AqiNow` | 当前空气质量 |
| `getIndices()` | GET | `/indices` | `List<IndexInfo>` | 生活指数，当前请求 `type=0` 表示全部 |

位置默认逻辑：

1. `getLocation()` 遇到 404 时，会调用 `saveLocation(longitude: 108.9398, latitude: 34.3416, cityName: "西安")`。
2. 保存默认位置后再次递归调用 `getLocation()`。
3. 这意味着新设备默认城市是西安。

请求和响应处理特点：

1. 响应体使用 `utf8.decode(response.bodyBytes)` 后再 `jsonDecode`，可以正确处理非 ASCII 文本。
2. 只有 HTTP 200 被视为成功。
3. 失败时抛出 `Exception`，由 ViewModel 的 `_tryFetch` 或外层 `try/catch` 处理。
4. `dispose()` 调用 `_client.close()`，由 `WeatherViewModel.dispose()` 触发。
5. 天气、AQI、生活指数和城市搜索请求当前默认使用 `lang=zh`，天气请求还硬编码 `unit=m`。`openapi.json` 中这些 query 参数是可选项，默认语言为 `zh`，后续如果增加语言或单位设置，需要把这些值从用户偏好或系统 locale 传入 Repository。

新增 API 的推荐步骤：

1. 在 `lib/models/` 增加响应模型，或者扩展现有模型。
2. 在 `ApiWeatherRepository` 中增加方法，保持请求参数和后端契约一致。
3. 在 ViewModel 中调用新方法并写入 `WeatherUiState`。
4. 在 UI 组件中通过 state 或构造参数消费数据。
5. 如果是用户相关接口，确认是否需要 `X-Device-ID`。

## 7. 数据模型

模型层位于 `lib/models/`，主要作用是把后端 JSON 响应转换为 UI 可直接消费的 Dart 对象。

### 7.1 LocationResponse

`lib/models/location.dart` 定义两个类型：

1. `Location`：包含 `longitude`、`latitude`、`cityName`。
2. `LocationResponse`：包含 `deviceId`、`longitude`、`latitude`、`cityName`、`updatedAt`。

当前 UI 使用的是 `WeatherUiState.location`，类型为 `LocationResponse?`。

字段映射：

| Dart 字段 | JSON 字段 |
| --- | --- |
| `deviceId` | `device_id` |
| `longitude` | `longitude` |
| `latitude` | `latitude` |
| `cityName` | `city_name` |
| `updatedAt` | `updated_at` |

### 7.2 WeatherNow

`lib/models/weather_now.dart` 从响应中的 `now` 对象解析实时天气。

核心字段：

| Dart 字段 | JSON 来源 | 类型处理 |
| --- | --- | --- |
| `temp` | `now.temp` | `int.tryParse`，默认 0 |
| `feelsLike` | `now.feelsLike` | `int.tryParse`，默认 0 |
| `condition` | `now.text` | 字符串，默认空字符串 |
| `icon` | `now.icon` | 字符串，默认空字符串 |
| `precip` | `now.precip` | `double.tryParse`，默认 0.0 |
| `windSpeed` | `now.windSpeed` | `int.tryParse`，默认 0 |
| `windDir` | `now.windDir` | 字符串，默认空字符串 |
| `visibility` | `now.vis` | `double.tryParse`，默认 0.0 |
| `humidity` | `now.humidity` | `int.tryParse`，默认 0 |
| `dewPoint` | `now.dew` | `int.tryParse`，默认 0 |
| `pressure` | `now.pressure` | `int.tryParse`，默认 0 |

代码注释明确指出当前 API 在 `now` 对象中会以字符串形式返回数字。

### 7.3 HourlyForecast

`lib/models/weather_hourly.dart` 表示逐小时预报项。

字段：

1. `time`：从 `fxTime` 解析为 `DateTime` 后用 `DateFormat('HH:mm')` 格式化。
2. `icon`：来自 `icon`。
3. `temp`：从 `temp` 字段解析为 int。

`ApiWeatherRepository.getHourlyForecast()` 从响应的 `hourly` 数组生成 `List<HourlyForecast>`。

### 7.4 DailyForecast

`lib/models/weather_daily.dart` 表示逐日预报项。

字段：

1. `date`：`fxDate` 格式化为 `MM/dd`。
2. `dayOfWeek`：当天显示 `Today`，其他日期显示 `EEE`。
3. `tempMax`、`tempMin`：最高和最低温。
4. `icon`：使用 `iconDay`。
5. `pop`：降水概率。
6. `sunrise`、`sunset`：日出日落时间。
7. `uvIndex`：紫外线指数。

`ApiWeatherRepository.getDailyForecast()` 从响应的 `daily` 数组生成 `List<DailyForecast>`。

### 7.5 AqiNow 和 IndexInfo

`lib/models/indices.dart` 包含两个模型：

1. `AqiNow`：从响应中的 `now` 对象解析 `aqi` 和 `category`。
2. `IndexInfo`：解析生活指数项，包括 `type`、`name`、`category`、`text`。

当前 UI 只展示了 `AqiNow`，`WeatherUiState.indices` 已保存生活指数列表，但首页尚未渲染该列表。

## 8. UI 组件结构

### 8.1 HomeScreen

`lib/ui/home_screen.dart` 是当前唯一主页面。

顶层结构：

1. `Scaffold`
2. `Consumer<WeatherViewModel>`
3. 根据 `WeatherUiState` 分支展示 loading、error 或内容页

状态分支：

| 状态 | UI |
| --- | --- |
| `state.isLoading == true` | 居中的 `CircularProgressIndicator` |
| `state.errorMessage != null` | 错误文本 + Retry 按钮 |
| 正常状态 | 渐变背景 + `CustomScrollView` |

正常内容结构：

```text
CustomScrollView
  SliverAppBar
    menu icon
    city name
    location icon -> LocationBottomSheet
  SliverToBoxAdapter
    hero section: 当前温度，体感温度，最高/最低温
    HourlyForecastCard
    DailyForecastCard
    DetailsStaggeredGrid
    AqiSection
```

`HomeScreen` 的组件编排规则：

1. 若 `weatherNow` 或 `dailyForecast` 不完整，则不展示 hero section 和 details grid。
2. 小卡片组件内部自行处理空数据，例如 `HourlyForecastCard` 和 `DailyForecastCard` 在列表为空时返回 `SizedBox.shrink()`。
3. 页面背景使用从 `primaryContainer` 到 `surface` 的线性渐变。
4. `SliverAppBar` 置顶且浮动，颜色通过 `Color.alphaBlend` 与顶部渐变保持一致。

### 8.2 HourlyForecastCard

`lib/ui/hourly_forecast_card.dart` 展示横向逐小时列表。

输入：`List<HourlyForecast> hourlyData`

渲染：

1. 空列表时不占位。
2. 使用 `surfaceContainer` 背景和 24 圆角。
3. `ListView.separated(scrollDirection: Axis.horizontal)` 横向滚动。
4. 每个 item 展示时间、天气图标和温度。
5. 天气图标通过 `getWeatherIcon(forecast.icon, size: 28)` 获取。

### 8.3 DailyForecastCard

`lib/ui/daily_forecast_card.dart` 展示横向逐日预报。

输入：`List<DailyForecast> dailyData`

渲染：

1. 标题固定为 `10-Day forecast`。
2. 横向 `ListView.separated`。
3. 第一项被视为今天，使用 `primaryContainer` 背景和 primary 边框。
4. 展示星期、图标、降水概率、最高和最低温。
5. 降水概率 `pop > 0` 时才显示。

### 8.4 DetailsStaggeredGrid

`lib/ui/details_grid.dart` 展示当前天气详情。

输入：

1. `WeatherNow weather`
2. `DailyForecast todayForecast`

内部采用两列 Row + Column 手写 staggered grid，而不是依赖第三方瀑布流组件。

当前详情卡片：

| 卡片 | 数据来源 | 特点 |
| --- | --- | --- |
| Precipitation | `weather.precip` | 显示最近 24h 降水量 |
| Wind | `weather.windSpeed`、`weather.windDir` | 背景使用 `BlobPainter` |
| Sunrise & Sunset | `todayForecast.sunrise`、`todayForecast.sunset` | 使用 `SineWavePainter`，进度当前为固定 0.6 |
| UV Index | `todayForecast.uvIndex` | 使用 `ScallopedEdgePainter`，并映射 Low 到 Extreme 文案 |
| Visibility | `weather.visibility` | 使用 `ConcentricWavesPainter` |
| Pressure | `weather.pressure` | 使用 `GaugePainter`，按 980 到 1040 hPa 映射进度 |
| Humidity | `weather.humidity`、`weather.dewPoint` | 使用 `LiquidWavePainter` |

扩展新详情卡片时，优先复用 `_buildCardBase()`，保持圆角、背景和裁剪一致。

### 8.5 AqiSection

`lib/ui/aqi_section.dart` 展示空气质量。

输入：`AqiNow? aqiNow`

渲染规则：

1. `aqiNow == null` 时不展示。
2. 显示 AQI 数值和 category。
3. 根据 AQI 数值映射颜色：绿色、黄色、橙色、红色、紫色。

### 8.6 LocationBottomSheet

`lib/ui/location_bottom_sheet.dart` 是位置选择弹窗。

当前实现状态：

1. 是 `StatefulWidget`，内部持有 `TextEditingController`。
2. `_savedLocations` 是硬编码模拟列表。
3. 搜索框 `onSubmitted` 仅关闭弹窗，注释中标记应触发 `POST /api/v1/user/location`。
4. 点击保存地点也仅关闭弹窗，注释中标记应更新 location 并重新拉取数据。

这是后续位置搜索、保存和切换功能的主要扩展点。

## 9. 天气图标与视觉资产

图标资源在 `assets/icons/` 下，并在 `pubspec.yaml` 中声明：

```yaml
flutter:
  assets:
    - assets/icons/
```

`lib/utils/weather_icons.dart` 提供：

```dart
Widget getWeatherIcon(String iconCode, {double size = 24})
```

实现方式：

1. `_iconAsset(iconCode)` 把天气 icon code 映射到本地 png。
2. `Image.asset` 加载图片，并启用 `gaplessPlayback: true`。
3. 未匹配的 icon code 默认返回 `weather_cloudy_pixel.png`。

当前覆盖的类别包括：

1. 晴天和夜间晴天。
2. 多云和部分多云。
3. 雨、雷雨、冰雹、雪、雨夹雪。
4. 雾、霾、沙尘。
5. 极端高温和低温。

README 标注图标来源为 `pixel-icon-provider`。

新增图标映射时，需要同时确认：

1. `assets/icons/` 中存在对应 png。
2. `pubspec.yaml` 的 assets 配置能覆盖资源目录。
3. `_iconAsset` 中添加 icon code 分支。
4. 调用方只传后端返回的 icon code，不直接引用资产路径。

## 10. 自定义绘制组件

自定义视觉绘制位于 `lib/ui/shapes/`。

| 文件 | 类型 | 用途 |
| --- | --- | --- |
| `blob_shape.dart` | `BlobPainter`、`BlobShapeCard` | Wind 卡片背景 blob |
| `concentric_waves.dart` | `ConcentricWavesPainter` | Visibility 卡片圆形波纹 |
| `gauge_chart.dart` | `GaugePainter` | Pressure 半圆仪表盘 |
| `liquid_wave.dart` | `LiquidWavePainter` | Humidity 水位波浪 |
| `scalloped_edge.dart` | `ScallopedEdgePainter` | UV 卡片底部波浪边 |
| `sine_wave.dart` | `SineWavePainter` | Sunrise & Sunset 太阳轨迹 |

这些 painter 都是展示型组件，没有直接访问状态层。需要数据驱动的 painter 通常通过构造参数传入 `progress`、`value` 或颜色。

`blob_shape.dart` 中还定义了 `BlobShapeCard` 包装组件，但当前代码没有导入或使用它。后续可以删除，或者在需要复用 blob 背景卡片时正式接入。

注意事项：

1. `GaugePainter`、`LiquidWavePainter`、`SineWavePainter` 的 `shouldRepaint` 当前返回 `true`。
2. 其他静态 painter 多数返回 `false`。
3. 后续如果引入动画，应重新评估 `shouldRepaint` 和 repaint boundary，避免首页滚动时不必要重绘。

## 11. 数据流和依赖方向

当前依赖方向整体保持单向：

```text
main.dart
  -> viewmodels
    -> data
      -> config
      -> models
  -> ui
    -> viewmodels
    -> models
    -> utils
    -> ui/shapes
```

关键规则：

1. UI 不直接调用 `ApiWeatherRepository`，而是通过 `WeatherViewModel`。
2. Repository 不依赖 UI，也不依赖 ViewModel。
3. Model 不依赖 Repository 和 UI。
4. Utils 中的 `weather_icons.dart` 依赖 Flutter UI，因为它直接返回 `Widget`。
5. `ui/shapes` 只负责绘制，不持有业务状态。

后续维护时应避免：

1. 在 UI 组件中直接拼接 API URL。
2. 在 Model 中访问 `BuildContext`、Theme 或 Provider。
3. 在 Repository 中创建 Widget 或处理页面状态。
4. 在多个组件中重复解析同一份 JSON 字段。

## 12. 错误处理和空数据策略

当前错误和空数据处理分布如下：

| 位置 | 策略 |
| --- | --- |
| Repository | 非 200 响应抛出 `Exception` |
| ViewModel `_tryFetch` | 单个天气接口异常转为 `null` |
| ViewModel 外层 catch | 位置获取等关键流程失败时写入 `errorMessage` |
| HomeScreen | loading、error、content 三分支 |
| 卡片组件 | 空列表或 null 数据时返回 `SizedBox.shrink()` |
| Model | 解析失败时多数字段使用 0 或空字符串兜底 |

当前策略偏向“尽量展示已有数据”。例如 AQI 失败不会阻止实时天气和预报展示。

需要注意的限制：

1. `_tryFetch` 捕获异常后丢弃具体错误，UI 无法知道哪个模块失败。
2. Model 默认值可能让 UI 显示 0，而不是缺失状态。
3. `WeatherUiState.copyWith` 对可空字段的清空能力有限。
4. `HourlyForecast.fromJson` 和 `DailyForecast.fromJson` 中日期解析失败会静默返回空字符串。

这些限制不一定需要立即修改，但新增功能时要明确某个数据块失败时应该隐藏、显示默认值，还是显示局部错误。

## 13. 扩展指南

### 13.1 新增一个天气数据卡片

推荐步骤：

1. 确认数据是否已存在于 `WeatherUiState`。
2. 如果已存在，在 `lib/ui/` 新建独立 StatelessWidget，输入明确的 model 或 primitive 字段。
3. 在 `HomeScreen` 的内容 Column 中插入新组件。
4. 空数据时组件内部返回 `SizedBox.shrink()`，与现有卡片风格保持一致。
5. 视觉上复用 `surfaceContainer`、24 圆角和 Theme 色值。

### 13.2 新增一个后端接口

推荐步骤：

1. 对照 `openapi.json` 确认路径、query、headers 和响应结构。
2. 在 `lib/models/` 中增加模型和 `fromJson`。
3. 在 `ApiWeatherRepository` 中增加方法。
4. 在 `WeatherViewModel.loadWeatherData()` 中决定是否并发加载。
5. 在 `WeatherUiState` 中增加字段。
6. 在 UI 中消费新字段。
7. 明确失败策略：是否允许局部失败，是否影响页面整体错误状态。

### 13.3 接入真实位置搜索和切换

当前入口是 `LocationBottomSheet`。

推荐改造路径：

1. Repository 已有 `saveLocation({longitude, latitude, cityName})`，但 UI 尚未调用。
2. 需要先明确“搜索城市或 zip code”对应的后端接口。如果后端只接受经纬度，前端还需要城市搜索或地理编码接口。
3. 在 `WeatherViewModel` 中增加位置保存或切换方法，例如接收经纬度后调用 `saveLocation()`，再调用 `loadWeatherData()`。
4. `LocationBottomSheet` 不应直接操作 Repository，应该通过 ViewModel 方法触发业务流程。
5. 保存地点列表当前是 mock 数据，接入真实收藏列表前需要新增 model、repository 方法和 state 字段。

### 13.4 展示生活指数 indices

当前数据已经在 `WeatherUiState.indices` 中保存，但 UI 尚未展示。

推荐步骤：

1. 新建 `IndicesSection` 或类似组件。
2. 输入 `List<IndexInfo>`。
3. 空列表时隐藏组件。
4. 根据 `type`、`name`、`category`、`text` 展示卡片或列表。
5. 在 `HomeScreen` 的 `AqiSection` 前后插入。

### 13.5 引入多页面导航

当前只有 `home: const HomeScreen()`。

如果新增设置页、城市管理页或详情页，可以选择：

1. 简单页面：在 `MaterialApp` 增加 `routes`。
2. 需要参数传递：使用 `onGenerateRoute` 或封装 route builder。
3. 深链或复杂导航：再考虑 Router API。

新增页面时应避免把所有状态继续塞进 `WeatherViewModel`。如果页面有独立生命周期和数据源，建议创建新的 ViewModel 并在合适的 Provider 作用域注入。

## 14. 当前限制和待关注点

以下是从当前代码直接观察到的限制，供后续规划使用：

1. `LocationBottomSheet` 的保存地点列表是 mock 数据。
2. 位置搜索提交和地点点击都只关闭弹窗，尚未触发真实保存或刷新。
3. `WeatherUiState.indices` 已存在，但生活指数没有对应 UI 展示。
4. `SineWavePainter` 的太阳进度在 details grid 中固定为 `0.6`，不是根据当前时间计算。
5. `AppConfig.apiBaseUrl` 需要通过 `--dart-define-from-file` 或 `--dart-define` 注入，未设置时会抛出 `StateError`。
6. 当前没有 `test/` 目录，尚未观察到 Dart 或 Flutter widget tests。
7. 当前没有抽象 Repository interface，ViewModel 直接实例化 `ApiWeatherRepository`，这会增加单元测试替换依赖的成本。
8. `copyWith` 对 nullable 字段清空不友好，后续复杂状态流可能需要调整。
9. 天气接口请求没有附带 `X-Device-ID`，只有位置接口使用设备 ID 请求头。是否需要统一取决于后端契约。
10. 天气、AQI、生活指数和城市搜索请求默认使用 `lang=zh`，天气请求硬编码 `unit=m`，尚未接入系统语言、用户单位偏好或设置页。
11. `BlobShapeCard` 当前未使用，属于可清理的死代码或待接入的视觉封装。

## 15. 验证和维护清单

修改前端功能后，建议按以下顺序验证：

1. 运行静态分析：`flutter analyze`。
2. 如果新增测试，运行对应 `flutter test`。
3. 启动应用，验证 loading、成功、错误三种页面状态。
4. 验证 API 不可用或局部接口失败时，页面是否仍符合预期。
5. 验证浅色和深色主题下新增组件是否可读。
6. 验证小屏宽度下横向列表、bottom sheet 和详情网格是否溢出。
7. 如果新增图片资源，确认 `pubspec.yaml` assets 覆盖路径并能被 `Image.asset` 加载。

文档维护原则：

1. 新增架构层或关键目录时同步更新“目录结构”和“运行时架构”。
2. 新增 API 时同步更新“API Repository”和“数据模型”。
3. 新增页面或组件编排时同步更新“UI 组件结构”。
4. 修改失败策略时同步更新“错误处理和空数据策略”。
