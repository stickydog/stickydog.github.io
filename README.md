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
  tutorials/             Tutorial 习题解答（PDF）
  code/                  MATLAB 编程作业（填空版 / 答案版，my-work/ 为自己的作答）
  lab/                   风洞实验说明、数据与代码（my-work/ 为自己的脚本）
  notebooks/             交互演示：.ipynb 原件 + 导出的 .html 网页版
structure-material/
  index.html
  course-notes.html
  exercises.html         习题与解答网页（全部 Tutorial / Home Exercise / Trial Exam，含补充说明与勘误）
  truss-stiffness-animation.html  桁架刚度法动画演示（单文件交互网页，对应 Lecture 7 例 3）
  exercises/             习题网页用到的示意图（截取自原课件）
  _build/exercises/      习题网页的源文件：改 src/*.html 后在该目录运行 npm install && npm run build
  handwritten/           手写笔记（GoodNotes 导出 PDF）
  tutorials/             Tutorial 带解答版（PDF）
  homework/              课后作业解答 + HSB 屈曲图表（PDF）
  exam/                  模拟考试解答（PDF）
flight-dynamics/
  index.html
  course-notes.html
  homework/
mechanics/               Engineering Mechanics I（工程力学 / 静力学）
  index.html
  course-notes.html
  lectures/              课件 Lecture 1–17（缺 9、12–14）
  exercises/             Central Exercise 幻灯片（W5 起带手写解答）
  exam/                  Test Exam（无解答）
```

## 添加资料

1. 把文件放进对应课程文件夹（或其子文件夹）。
2. 在该课程的 `index.html` 里加一条链接；如果想在首页也显示，再在根目录 `index.html` 里加一条。
3. 新课程：新建文件夹，复制一份现有课程的 `index.html` 改标题，并在首页加一个区块。

## 显示文字约定（同一级别用同一种写法）

- 课程名（首页区块标题、课程页大标题）：`English 中文`，例如 `Aerodynamics 空气动力学`。
- 课程页分区标题：`中文 English`，例如 `习题解答 Tutorials`。
- 条目标题：有编号的写成 `英文编号 · 中文主题`（`Tutorial 1 · 流动运动学`、`Home Exercise 4 · 屈曲`、`Notebook 2 · 涡量与环量`）；无编号的写成 `中文 English`。编号不补零。
- 标签：课程笔记一律写 `第 1–N 章`；首页资料卡片写 `N 次习题课`；其余写 `来源 · N 页`。
- 笔记章标题右侧的来源标签用英文原名：`Lecture 3 · CE W4`、`Slides p. 30–71`。
- 返回首页：课程页顶部和笔记顶栏都固定显示 `← 首页`。

## 命名约定

- 文件名只用小写英文、数字和连字符，例如 `week05-boundary-layer.pdf`；不要用空格和中文。
- 例外：MATLAB 代码和它读取的数据文件保留原名（函数名必须与文件名一致，脚本里也按原名读取数据）。
- 页面之间一律用相对路径链接（例如 `../index.html`）。
- 单个文件不超过 100 MB；仓库总体建议保持在 1 GB 以内。
