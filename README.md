# 🍳 Recipe management app "Let's cook!"

お気に入りのレシピを記録・管理できる料理レシピ管理Webアプリです。
材料・手順・栄養情報をまとめて管理し、買い物リスト機能で食材の準備もスムーズに行えます。

---

## 📸 デモ画面

### レシピ一覧
<!-- TODO: スクリーンショットを追加 -->
> 📷 スクリーンショットを追加予定

### レシピ詳細
<!-- TODO: スクリーンショットを追加 -->
> 📷 スクリーンショットを追加予定

### レシピ登録フォーム
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

### 検索・絞り込み
| 機能 | 説明 |
|------|------|
| **ジャンル絞り込み** | 和食・洋食・中華・エスニック・その他で絞り込み |
| **キーワード検索** | タイトル・説明文からキーワード検索 |
| **調理時間フィルタ** | 最大調理時間で絞り込み |
| **材料名検索** | 使いたい食材からレシピを検索 |
| **タグ絞り込み** | 「簡単」「お弁当」などのタグで絞り込み |
| **ソート** | 新着順・調理時間順・タイトル順 |

### 買い物リスト
| 機能 | 説明 |
|------|------|
| **リスト作成** | 買い物リストを複数作成・管理 |
| **材料一括追加** | レシピから必要な食材を一括で買い物リストに追加 |
| **人数スケーリング** | 作る人数に合わせて材料の分量を自動調整 |
| **チェック機能** | 購入済み食材をチェックして管理 |
| **チェック済み一括削除** | 購入済みアイテムをまとめて削除 |

---

## 🛠 技術スタック

### フロントエンド
| 技術 | バージョン | 用途 |
|------|-----------|------|
| Next.js | 16.2.7 | フロントエンドフレームワーク |
| React | 19.2.4 | UIライブラリ |
| TypeScript | ^5 | 型安全な開発 |
| Tailwind CSS | ^4 | スタイリング |

### バックエンド
| 技術 | バージョン | 用途 |
|------|-----------|------|
| Ruby on Rails | 7.2 | APIサーバー（APIモード） |
| Ruby | 3.3.0 | プログラミング言語 |
| MySQL | 8.0 | データベース |
| Puma | - | アプリケーションサーバー |

### インフラ
| 技術 | 用途 |
|------|------|
| AWS EC2 | アプリケーションサーバー・DBサーバー |
| AWS S3 | フロントエンド配信・画像保存 |
| AWS CloudFront | CDN・HTTPS配信 |
| Nginx | リバースプロキシ |
| Terraform | インフラのコード管理（IaC） |
| Docker / Docker Compose | ローカル開発環境 |

---

## ☁️ インフラ構成

```
Internet
  │ HTTPS
  ▼
CloudFront ─────────────── S3（フロントエンド静的ファイル）
  │ /api/*                 S3（画像ストレージ）
  ▼
EC2（Nginx + Rails + MySQL）
  t3.micro / Amazon Linux 2023
```

---

## 🗂 ディレクトリ構成

```
.
├── backend/              # Ruby on Rails（APIモード）
│   ├── app/
│   │   ├── controllers/api/v1/   # APIエンドポイント
│   │   └── models/               # ActiveRecordモデル
│   ├── db/
│   │   ├── migrate/              # マイグレーションファイル
│   │   └── seeds.rb              # サンプルデータ
│   └── spec/                     # RSpecテスト
├── frontend/             # Next.js（App Router）
│   ├── app/
│   │   ├── components/           # 共通コンポーネント
│   │   ├── recipes/
│   │   │   ├── [id]/             # レシピ詳細ページ
│   │   │   ├── [id]/edit/        # レシピ編集ページ
│   │   │   └── new/              # レシピ登録ページ
│   │   └── page.tsx              # レシピ一覧（トップ）
│   └── lib/
│       └── api.ts                # APIクライアント（型定義付き）
├── infra/                # Terraform（IaC）
│   └── modules/
│       ├── vpc/          # VPC・サブネット・IGW
│       ├── security_group/ # ファイアウォール設定
│       ├── ec2/          # EC2・IAMロール・EIP
│       ├── s3/           # フロントエンド・画像バケット
│       └── cloudfront/   # CDN・OAC・SPAルーティング
├── docs/                 # 設計書一式
└── docker-compose.yml    # ローカル開発環境
```

---

## 🚀 ローカル開発環境のセットアップ

### 前提条件
- Docker Desktop がインストール済みであること
- Node.js 20以上 がインストール済みであること

### 1. リポジトリをクローン

```bash
git clone https://github.com/shibito99/recipe-management-lets-cook.git
cd recipe-management-lets-cook
```

### 2. バックエンドを起動

```bash
# Dockerコンテナを起動（Rails + MySQL）
docker compose up

# 別ターミナルでマイグレーション・シードデータ投入
docker compose exec backend rails db:migrate
docker compose exec backend rails db:seed
```

### 3. フロントエンドを起動

```bash
cd frontend
npm install
npm run dev
```

### 4. アクセス

| サービス | URL |
|---------|-----|
| フロントエンド | http://localhost:3000 |
| バックエンドAPI | http://localhost:3001/api/v1 |

---

## 🧪 テスト

```bash
# バックエンド（RSpec）
docker compose run --rm -e RAILS_ENV=test backend bundle exec rspec

# フロントエンド 型チェック
cd frontend && npx tsc --noEmit
```

---

## 📡 主なAPIエンドポイント

| メソッド | エンドポイント | 説明 |
|---------|--------------|------|
| GET | `/api/v1/recipes` | レシピ一覧（フィルタ・ソート・ページネーション） |
| GET | `/api/v1/recipes/:id` | レシピ詳細 |
| POST | `/api/v1/recipes` | レシピ作成 |
| PATCH | `/api/v1/recipes/:id` | レシピ更新 |
| DELETE | `/api/v1/recipes/:id` | レシピ削除 |
| GET | `/api/v1/tags` | タグ一覧 |
| GET | `/api/v1/shopping_lists` | 買い物リスト一覧 |
| POST | `/api/v1/shopping_lists/:id/items` | アイテム追加（個別 or レシピから一括） |
| DELETE | `/api/v1/shopping_lists/:id/items/checked` | チェック済み一括削除 |

詳細は [docs/API設計書.md](docs/API設計書.md) を参照してください。

---

## 📄 ドキュメント

| ファイル | 内容 |
|---------|------|
| [docs/要件定義書.md](docs/要件定義書.md) | ソフトウェア要件定義書（SRS） |
| [docs/技術スタック選定書.md](docs/技術スタック選定書.md) | 技術スタック選定書 |
| [docs/アーキテクチャ設計書.md](docs/アーキテクチャ設計書.md) | システムアーキテクチャ設計書 |
| [docs/データベース設計書.md](docs/データベース設計書.md) | データベース設計書 |
| [docs/API設計書.md](docs/API設計書.md) | API設計書 |
| [docs/画面設計書.md](docs/画面設計書.md) | 画面設計書 |
| [docs/インフラ設計書.md](docs/インフラ設計書.md) | インフラ設計書（Terraform） |
| [docs/デプロイ手順書.md](docs/デプロイ手順書.md) | デプロイ手順書 |
| [docs/テスト計画書.md](docs/テスト計画書.md) | テスト計画書 |

---

## 📄 ライセンス

このプロジェクトは学習目的で作成されました。
