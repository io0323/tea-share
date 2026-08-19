# TeaShare

TeaShareは茶葉の交換を支援するiOSアプリケーションです。ユーザーは自分の茶葉を出品し、他のユーザーと交換することができます。

## 機能

- **タイムライン**: 募集中の茶葉を一覧表示
- **マップ**: 茶葉の交換スポットを地図で表示
- **プロフィール**: ユーザー情報の管理、出品一覧、取引リクエストの管理
- **茶葉出品**: 画像付きで茶葉を出品
- **取引管理**: 取引リクエストの送信、承認、拒否

## 技術スタック

- **SwiftUI**: UIフレームワーク
- **SwiftData**: データ永続化
- **CoreLocation**: 位置情報
- **MapKit**: 地図表示

## プロジェクト構成

```
tea-share/
├── Models/           # データモデル
│   └── TeaModels.swift
├── Utils/            # ユーティリティ
│   ├── AppConstants.swift
│   ├── CurrentUserManager.swift
│   └── TeaImageStorage.swift
├── Views/            # ビュー
│   ├── AddTea/
│   ├── Map/
│   ├── Profile/
│   └── Timeline/
├── Previews/         # プレビュー
└── TeaShareApp.swift # アプリエントリポイント
```

## データモデル

### 主要モデル

- **User**: ユーザー情報
- **TeaLeaf**: 茶葉の出品情報
- **Trade**: 取引リクエスト

### 列挙型

- **TeaCategory**: 茶葉のカテゴリ（緑茶、紅茶、烏龍茶、ハーブティー、白茶）
- **TradeStatus**: 取引ステータス（募集中、交渉中、交換完了）
- **TeaExpiryStatus**: 賞味期限の状態（期限切れ、期限間近、余裕あり）

## 開発環境

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## ビルド方法

1. Xcodeでプロジェクトを開く
2. ターゲットデバイスを選択（iOSシミュレータまたは実機）
3. Cmd + R でビルド＆実行

## 貢献

1. ブランチを作成
2. 変更をコミット
3. プルリクエストを作成

## ライセンス

MIT License
