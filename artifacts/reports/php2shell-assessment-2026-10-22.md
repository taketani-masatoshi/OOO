# PHP2Shell 影響評価（2026-10-22）

## 概要

2026-10-21 に公開された PHP の重大脆弱性（通称 **PHP2Shell**）を、OOO / OpenOrgOS / Community の実装と運用資産に照らして判定した。

| CVE | 内容 | CVSS |
|-----|------|------|
| CVE-2026-109618 | OOM 処理中のメモリ破損による未認証 RCE | 9.2 |
| CVE-2026-109619 | リクエスト間に残るグローバル状態（UAF）による未認証 RCE | 9.2 |

修正版: PHP **8.5.12 / 8.4.27 / 8.3.36 / 8.2.35**。IPA・CISA・ENISA・CERT-EU が即時更新を勧告。

出典:
- https://thephp.foundation/blog/2026/10/21/todays-php-security-release-and-how-were-strengthening-php-security/
- https://www.ipa.go.jp/security/security-alert/2026/alert20261022.html
- https://www.cisa.gov/news-events/alerts/2026/10/21/critical-vulnerabilities-php-require-immediate-patching

## OOO 製品コード（Core / Community / Web）

**判定: 影響なし（コード修正不要）**

根拠:
- リポジトリ内に `.php` / `composer.json` / `composer.lock` は無い。
- 開発マシン上に `php` バイナリは無い（`php not found`）。
- Docker ベースイメージはすべて Node.js（`node:20-alpine` / `node:22-*`）または digidoc 用の Java（`eclipse-temurin:17`）。
- 公開面は Vercel（静的 / Next.js）と Node 系アプリ。PHP-FPM / mod_php / php-cgi は起動していない。

したがって、製品リポジトリに対するパッチ適用や依存更新は不要。

## 運用上の残リスク（製品外）

**判定: 要オペレーター対応（リポジトリからは修正不可）**

| 資産 | 根拠 | 推奨アクション |
|------|------|----------------|
| **malkk.com（WordPress）** | `Core/tenants/mal/docs/web-updates.md` に wp-admin 操作手順あり。WordPress は PHP 上で動作する | ホスティングの PHP を修正版へ更新。更新不能なら公開遮断。WAF は暫定のみ |
| その他の PHP 製 SaaS / CMS | リポジトリ外の個人・法人サイトは本調査の対象外 | 一覧化し、ベンダーの案内に従う |

※ Steward / OOO リポジトリから malkk.com の WordPress は直接編集できない（同ドキュメント明記）。

## 実施した点検

1. `*.php` / Composer の有無をワークスペース全体で検索（worktree / node_modules 除外）。
2. Dockerfile の `FROM` 行を全アプリで確認。
3. `php` プロセス・バイナリの有無を確認。
4. テナント文書から WordPress 参照を抽出。

## 結論

- **製品開発内容に PHP2Shell 由来の修正対象は無い。**
- **運用の WordPress（malkk.com）は別経路で PHP を即時更新すること。** 本リポジトリのコード変更では代替できない。
