# stickydog.github.io

Personal study notes (aerospace engineering) — https://stickydog.github.io

纯静态 HTML 站点，由 GitHub Pages 直接从 `main` 分支根目录发布，不需要任何构建工具。

## 目录结构

```
index.html               首页（课程总目录）
404.html                 找不到页面时显示
favicon.svg              网站图标
assets/site.css          首页与课程目录页共用样式
.nojekyll                让 GitHub Pages 原样发布文件（不经过 Jekyll 处理）

aerodynamics/            每门课一个文件夹
  index.html             该课程的资料目录
  course-notes.html      课程笔记
  handwritten/           手写笔记扫描（PDF）
  homework/              作业与习题
structure-material/
  index.html
```

## 添加资料

1. 把文件放进对应课程文件夹（或其子文件夹）。
2. 在该课程的 `index.html` 里加一条链接；如果想在首页也显示，再在根目录 `index.html` 里加一条。
3. 新课程：新建文件夹，复制一份现有课程的 `index.html` 改标题，并在首页加一个区块。

## 命名约定

- 文件名只用小写英文、数字和连字符，例如 `week05-boundary-layer.pdf`；不要用空格和中文。
- 页面之间一律用相对路径链接（例如 `../index.html`）。
- 单个文件不超过 100 MB；仓库总体建议保持在 1 GB 以内。
