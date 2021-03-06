# Docker入りEC2を作成するTerraformコード
## 前提
- Terraformインストール済み
- Terraformのバージョン：0.12.6

## 使い方
1. ディレクトリ内に公開鍵を配置する。
2. `terraform init` を実行。
3. `terraform apply` を実行。
## 構成
### VPC
- CIDRブロック：10.0.0.0/16
- DNSサポート：有効
- DNSホスト名を使用：有効
### インターネットゲートウェイ
- 上記VPCにアタッチ
### サブネット
- CIDRブロック：10.0.0.0/24
- アベイラビリティゾーン：ap-northeast-1a
### ルートテーブル
- 0.0.0.0あての通信は全て、上記インターネットゲートウェイに流すように設定
- 上記サブネットにアタッチ
### セキュリティグループ
- インバウンド
	- 0.0.0.0/0に22番ポートへのアクセスを許可
	- 0.0.0.0/0に80番ポートへのアクセスを許可
- アウトバウンド：全てのアクセスを許可
### EC2
- AMI：Amazon Linux2(latest)
- セキュリティグループ：上記セキュリティグループを設定
- サブネット：上記サブネットを設定（パブリックサブネット）
- インスタンスタイプ：t2.micro
- 起動時にdocker_install.shスクリプトを実行する
- 同階層に配置してある公開鍵をキーペアとして設定
