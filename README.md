# 🍳 料理レシピ管理アプリ "Let's Cook!"

お気に入りのレシピを記録・管理できる料理レシピ管理Webアプリです。  
材料・手順・画像をまとめて管理し、買い物リスト機能で食材の準備もスムーズに行えます。

**デモURL:** https://d2b2m401smddic.cloudfront.net

---

## 📸 デモ画面

### レシピ一覧
<!-- TODO: スクリーンショットを追加 -->
> 📷 スクリーンショットを追加予定

### レシピ詳細
<!-- TODO: スクリーンショットを追加 -->
> 📷 スクリーンショットを追加予定

### 買い物リスト
<!-- TODO: スクリーンショットを追加 -->
> 📷 スクリーンショットを追加予定

---

## ✨ 機能一覧

### レシピ管理
| 機能 | 説明 |
|------|------|
| **レシピ一覧** | ジャンル別フィルタリングでレシピを一覧表示 |
| **レシピ詳細** | 材料・手順・栄養情報を詳細表示 |
| **レシピ登録** | タイトル・説明・材料・手順・タグを登録 |
| **レシピ編集** | 既存レシピの内容を編集・更新 |
| **レシピ削除** | 不要なレシピを削除 |
| **画像アップロード** | レシピに料理写真を添付（S3 Presigned URL経由） |

### 検索・絞り込み
| 機能 | 説明 |
|------|------|
| **ジャンル絞り込み** | 和食・洋食・中華・エスニック・その他で絞り込み |
| **キーワード検索** | タイトル・食材・タグからキーワード検索 |
| **調理時間フィルター** | 15分以内 / 30分以内 / 60分以内 / 60分超で絞り込み |

### 買い物リスト
| 機能 | 説明 |
|------|------|
| **リスト作成・削除** | 買い物リストを複数作成・管理 |
| **食材追加** | リストに食材を個別追加 |
| **チェック機能** | 購入済み食材をチェックして管理（進捗バー表示） |
| **食材削除** | リストから不要な食材を削除 |

---

## 🛠 技術スタック

### フロントエンド
| 技術 | バージョン | 用途 |
|------|-----------|------|
| Next.js | 16.2.7 | フロントエンドフレームワーク（App Router・静的エクスポート） |
| React | 19.2.4 | UIライブラリ |
| TypeScript | ^5 | 型安全な開発 |
| Tailwind CSS | ^4 | スタイリング |

### バックエンド
| 技術 | バージョン | 用途 |
|------|-----------|------|
| AWS Lambda | - | サーバレスAPIハンドラー |
| Ruby | 3.2 | Lambdaランタイム |
| AWS API Gateway | HTTP API v2 | APIエンドポイント管理 |

### データストア・ストレージ
| 技術 | 用途 |
|------|------|
| Amazon DynamoDB | レシピ・買い物リストの永続化（PAY_PER_REQUEST） |
| Amazon S3 | レシピ画像の保存 |

### インフラ
| 技術 | 用途 |
|------|------|
| Amazon CloudFront | CDN・HTTPS配信・オリジン振り分け |
| Amazon S3 | フロントエンド静的ファイルの配信 |
| Terraform | インフラのコード管理（IaC） |

---

## ☁️ インフラ構成

```
ユーザー
  │ HTTPS
  ▼
Amazon CloudFront (d2b2m401smddic.cloudfront.net)
  ├── /*        → S3（Next.js 静的ファイル）
  ├── /api/*    → API Gateway → Lambda (Ruby 3.2)
  │                                  │
  │                                  ├── DynamoDB（レシピ・買い物リスト）
  │                                  └── S3（画像 Presigned URL発行）
  └── /images/* → S3（レシピ画像）
```

---

## 🗂 ディレクトリ構成

```
.
├── backend/
│   └── lambda/
│       └── handler.rb          # Lambda ハンドラー（Ruby 3.2）
├── frontend/                   # Next.js（App Router・静的エクスポート）
│   ├── app/
│   │   ├── components/
│   │   │   ├── Header.tsx      # ナビゲーション付きヘッダー
│   │   │   ├── RecipeCard.tsx  # レシピカード
│   │   │   ├── RecipeForm.tsx  # レシピ登録・編集フォーム（画像アップロード含む）
│   │   │   └── GenreFilter.tsx # ジャンルフィルター
│   │   ├── recipes/
│   │   │   ├── page.tsx        # レシピ詳細・編集ページ（?id=xxx）
│   │   │   └── new/page.tsx    # レシピ新規登録ページ
│   │   ├── shopping/
│   │   │   └── page.tsx        # 買い物リストページ
│   │   ├── data/recipes.ts     # ジャンル定数
│   │   └── page.tsx            # レシピ一覧（トップページ）
│   └── lib/
│       └── api.ts              # APIクライアント（型定義付き）
├── infra/                      # Terraform（IaC）
│   └── modules/
│       ├── api_gateway/        # API Gateway (HTTP API v2)
│       ├── lambda/             # Lambda 関数・IAMロール
│       ├── dynamodb/           # DynamoDB テーブル
│       ├── s3/                 # フロントエンド・画像バケット
│       └── cloudfront/         # CDN・OAC・SPAルーティング
└── docs/                       # 設計書一式
    └── architecture.drawio     # AWS構成図
```

---

## 📡 APIエンドポイント

Lambda ハンドラー（`backend/lambda/handler.rb`）が処理するエンドポイント一覧です。

### レシピ

| メソッド | エンドポイント | 説明 |
|---------|--------------|------|
| GET | `/api/v1/recipes` | レシピ一覧（`q` / `genre` / `tag` / `cooking_time` でフィルタ可） |
| GET | `/api/v1/recipes/:id` | レシピ詳細 |
| POST | `/api/v1/recipes` | レシピ作成 |
| PUT | `/api/v1/recipes/:id` | レシピ更新 |
| DELETE | `/api/v1/recipes/:id` | レシピ削除 |

### 画像アップロード

| メソッド | エンドポイント | 説明 |
|---------|--------------|------|
| POST | `/api/v1/upload` | S3 Presigned URL 発行（ブラウザから直接アップロード） |

### 買い物リスト

| メソッド | エンドポイント | 説明 |
|---------|--------------|------|
| GET | `/api/v1/shopping-lists` | 買い物リスト一覧 |
| POST | `/api/v1/shopping-lists` | 買い物リスト作成 |
| PUT | `/api/v1/shopping-lists/:id` | 買い物リスト更新（アイテムのチェック・追加・削除） |
| DELETE | `/api/v1/shopping-lists/:id` | 買い物リスト削除 |

### ヘルスチェック

| メソッド | エンドポイント | 説明 |
|---------|--------------|------|
| GET | `/health` | Lambda 死活確認 |

---

## 🚀 ローカル開発環境のセットアップ

### 前提条件

- Node.js 20以上
- AWS CLI（設定済み）

### 1. リポジトリをクローン

```bash
git clone https://github.com/shibito99/recipe-management-lets-cook.git
cd recipe-management-lets-cook
```

### 2. フロントエンドを起動

```bash
cd frontend
npm install

# API URLを設定（ローカル開発時はAPI Gatewayのエンドポイントを直接指定）
echo "NEXT_PUBLIC_API_URL=https://u2wo63rb4m.execute-api.ap-northeast-1.amazonaws.com" > .env.local
echo "NEXT_PUBLIC_CDN_URL=https://d2b2m401smddic.cloudfront.net" >> .env.local

npm run dev
```

### 3. アクセス

| サービス | URL |
|---------|-----|
| フロントエンド（ローカル） | http://localhost:3000 |
| バックエンドAPI（AWS） | https://u2wo63rb4m.execute-api.ap-northeast-1.amazonaws.com |

---

## 🏗 インフラのデプロイ手順

### 前提条件

- Terraform >= 1.7
- AWS CLI（適切な権限を持つプロファイル設定済み）

### 1. Terraform の初期化・適用

```bash
cd infra
terraform init
terraform apply
```

### 2. Lambda の更新

```bash
# Lambda zip を作成
Compress-Archive -Path backend/lambda/* -DestinationPath infra/modules/lambda/lambda.zip -Force

# Lambda コードを更新
aws lambda update-function-code \
  --function-name recipe-app-api \
  --zip-file fileb://infra/modules/lambda/lambda.zip
```

### 3. フロントエンドのビルド・デプロイ

```bash
cd frontend
npm run build

# S3 にアップロード
aws s3 sync out s3://<frontend-bucket-name> --delete

# CloudFront キャッシュを無効化
aws cloudfront create-invalidation \
  --distribution-id <distribution-id> \
  --paths "/*"
```

---

## 📄 ドキュメント

| ファイル | 内容 |
|---------|------|
| [docs/architecture.drawio](docs/architecture.drawio) | AWS構成図（Draw.ioで閲覧可） |
| [docs/要件定義書.md](docs/要件定義書.md) | ソフトウェア要件定義書 |
| [docs/技術スタック選定書.md](docs/技術スタック選定書.md) | 技術スタック選定書 |
| [docs/アーキテクチャ設計書.md](docs/アーキテクチャ設計書.md) | システムアーキテクチャ設計書 |
| [docs/データベース設計書.md](docs/データベース設計書.md) | データベース設計書 |
| [docs/API設計書.md](docs/API設計書.md) | API設計書 |
| [docs/画面設計書.md](docs/画面設計書.md) | 画面設計書 |
| [docs/インフラ設計書.md](docs/インフラ設計書.md) | インフラ設計書（Terraform） |
| [docs/デプロイ手順書.md](docs/デプロイ手順書.md) | デプロイ手順書 |

---

## 📄 ライセンス

このプロジェクトは学習目的で作成されました。
