# AI King Repo

AI 生成的越狱插件源 · AI-generated jailbreak tweaks

## 添加源

在 Sileo / Zebra / Cydia 中添加：

```
https://jk-gl.github.io/AI-Tweak/
```

## 发布新插件（一步搞定）

把 `.deb` 拖进 `debs/` 目录，提交即可。

```
debs/你的插件.deb  →  commit  →  Actions 自动重建索引并部署
```

1~2 分钟后在 Sileo 下拉刷新就能看到。

手机端也能操作：用 GitHub 网页或 App 上传到 `debs/` 就行。

## 目录结构

```
debs/                        放 .deb 文件
scripts/make-repo.sh         索引生成脚本（本地也能跑）
.github/workflows/build.yml  自动构建
Packages / Packages.gz       生成的索引
Release                      源信息
```

## 本地手动重建

```bash
sh scripts/make-repo.sh
```

## 支持架构

- `iphoneos-arm`（老 rootful）
- `iphoneos-arm64`（rootless 无根）
- `iphoneos-arm64e`（无根 arm64e / 隐根转换后）

隐根包需先用 RootHide Patcher 转换，成品命名形如 `*_iphoneos-arm64e.deb`。

## 注意

本地自建包**不要写 `Depends: firmware (>= ...)`**，会让 APT 依赖树损坏，导致 Sileo 崩溃。装完后建议 `apt-get check` 验证一次。
