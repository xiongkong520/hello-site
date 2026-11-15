# hello-site · 我的第一个网页

一个纯静态单页，用来走通 **GitHub + Cloudflare Pages** 的完整上线流程。
全部代码只有 `index.html` 一个文件，没有构建步骤。

## 🌐 线上地址

**https://mimichong.pages.dev**

## 本地预览

```bash
python3 -m http.server 8000
# 浏览器打开 http://127.0.0.1:8000
```

## 更新网站的两种方式

### 方式一：命令行一键部署（当前用的）

```bash
# 改完 index.html 之后
./deploy.sh
```

`deploy.sh` 做三件事：清空 `dist/` → 把 `index.html` 拷进去 → `wrangler pages deploy`。

第一次用之前需要登录一次（浏览器里点「Authorize」）：

```bash
wrangler login
```

### 方式二：Git 推送自动部署（推荐以后用）

在 Cloudflare 后台把项目和 GitHub 仓库连起来，之后每次 `git push` 自动重新部署。
需要浏览器能打开 GitHub 的 OAuth 授权页 —— 手机上偶尔会被拦，**建议在电脑上操作**：

1. Cloudflare 后台 → Workers 和 Pages → 创建 → Pages → 连接到 Git
2. 授权 GitHub，选仓库 `xiongkong520/hello-site`
3. 构建设置：Framework preset = `None`，Build command 留空，Build output directory = `.`
4. Save and Deploy

> 注意：本项目目前是「直接上传」类型的 Pages 项目，不能事后切换成 Git 连接；
> 要走方式二，需要把现在的项目删掉，按上面步骤重新建一个。


## 连接到 GitHub 实现 push 自动部署

当前项目 `mimichong` 是「直接上传」类型，Cloudflare 不会从 GitHub 拉代码。
想变成「push 自动上线」，需要新建一个 **连接 Git** 类型的 Pages 项目：

1. Cloudflare 后台 → Workers 和 Pages → 创建 → Pages → **导入现有 Git 存储库**
2. 连接 GitHub，授权后选仓库 `xiongkong520/hello-site`
3. 构建设置：
   - Framework preset：`None`
   - Build command：`bash build.sh`
   - Build output directory：`dist`
4. Save and Deploy

之后每次 `git push`，Cloudflare 会自动跑 `build.sh` 并部署。

> 需要浏览器能打开 GitHub 的 OAuth 授权页（手机上部分浏览器会白屏，建议用电脑）。

## Git 命令速查（记住这 5 个就够）

| 命令 | 作用 |
| --- | --- |
| `git status` | 看现在改了哪些文件 |
| `git add .` | 把改动放进暂存区 |
| `git commit -m "说明"` | 存一个版本快照 |
| `git push` | 推到 GitHub |
| `git log --oneline` | 看历史版本 |

最小心智模型：**改文件 → add → commit → push**。四个动作循环。

## 常见坑

- `git push` 要密码：GitHub 早就不接受账号密码了，本机已配好 SSH key（`~/.ssh/id_ed25519`）。
- Cloudflare 部署后 404：纯静态站 Build output directory 要填 `.`（本次用的是上传 `dist/`，同理）。
- 改了没生效：先确认命令跑成功了，再看 Cloudflare 后台 Deployments 里最新一条是不是 Success。
- GitHub 界面没有中文：官方只提供英文 UI（帮助文档和手机 App 部分语言除外）。
  想中文浏览可以装汉化脚本或换带网页翻译的浏览器（注意：手机上的 Via 浏览器对 github.com 不执行用户脚本）。
