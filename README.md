# stickydog.github.io

Personal study notes (aerospace engineering) — https://stickydog.github.io

纯静态 HTML 站点，由 GitHub Pages 直接从 `main` 分支根目录发布，不需要任何构建工具。

## 目录结构

```
index.html               首页 (课程总目录)
404.html                 找不到页面时显示
favicon.svg              网站图标
assets/site.css          首页与课程目录页共用样式
robots.txt               禁止搜索引擎收录
.nojekyll                让 GitHub Pages 原样发布文件 (不经过 Jekyll 处理)
AGENTS.md                维护与一致性规范 (术语、排版、页面结构、构建流程)

aerodynamics/            每门课一个文件夹
  index.html             该课程的资料目录
  course-notes.html      课程笔记
  handwritten/           手写笔记扫描 (PDF，待添加)
  tutorials/             Tutorial 习题解答 (PDF)
  code/                  MATLAB 编程作业 (填空版 / 答案版，my-work/ 为自己的作答)
  lab/                   风洞实验说明、数据与代码 (my-work/ 为自己的脚本)
  notebooks/             交互演示：.ipynb 原件 + 导出的 .html 网页版
structure-material/
  index.html
  course-notes.html
  exercises.html         习题与解答网页 (全部 Tutorial / Home Exercise / Trial Exam，含补充说明与勘误)
  truss-stiffness-animation.html  桁架刚度法动画演示 (单文件交互网页，对应 Lecture 7 例 3)
  exercises/             习题网页用到的示意图 (截取自原课件)
  _build/exercises/      习题网页的源文件：改 src/*.html 后在该目录运行 npm install && npm run build
  handwritten/           手写笔记 (GoodNotes 导出 PDF)
  tutorials/             Tutorial 带解答版 (PDF)
  homework/              课后作业解答 + HSB 屈曲图表 (PDF)
  exam/                  模拟考试解答 (PDF)
flight-dynamics/
  index.html
  course-notes.html
  exercises.html         习题与解答网页 (Exercise 1–12 题目 + Tutorial 与手写笔记合并的解答)
  exercises/             Exercise 题目 PDF + 习题网页用到的示意图 (截取自原课件)
  _build/exercises/      习题网页的源文件：改 src/*.html 后在该目录运行 npm install && npm run build
  tutorials/             Tutorial 1–12 讲解幻灯片 + 总复习 Recap (PDF)
  handwritten/           习题课手写笔记 Exercise 1–11 (PDF)
  homework/              课后作业 (图片)
mechanics/               Engineering Mechanics I (工程力学 / 静力学)
  index.html
  course-notes.html
  lectures/              课件 Lecture 1–17 (缺 9、12–14)
  exercises/             Central Exercise 幻灯片 (W5 起带手写解答)
  exam/                  Test Exam (无解答)
```

## 添加资料

1. 把文件放进对应课程文件夹 (或其子文件夹)。
2. 在该课程的 `index.html` 里加一条链接；如果首页卡片里的数量变了，同步修改根目录 `index.html`。
3. 新课程：新建文件夹，复制 `mechanics/index.html` 和 `mechanics/course-notes.html` 作为模板，并在首页加一个区块。

文件命名、显示文字、术语、排版和页面结构的约定统一写在 [AGENTS.md](AGENTS.md)，改动前请先看。
