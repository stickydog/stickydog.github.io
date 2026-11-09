# 网站维护与一致性规范 (AGENTS.md)

> 本文件是 AI 助手维护本网站时必须遵守的规范。任何新增、修改、校对都要先读本文件，改完按"九、提交前自检"逐项核对。
> 规则冲突时的优先级：用户当次的明确指令 > "十、维护铁律" > "二、术语" > 其余各节。本文件没写到的情况，照现有页面的做法办；现有页面之间也不一致时，标注"待确认"并在回复里告诉用户，不要自行定新规矩。

## 目录

一、网站概况　二、术语　三、文字排版　四、公式　五、图与表　六、页面结构　七、样式与脚本　八、文件、命名与构建　九、提交前自检　十、维护铁律

---

## 一、网站概况

- **性质**：航空航天工程课程学习笔记，个人使用；GitHub Pages 从 `main` 分支根目录直接发布 (`.nojekyll`，无 Jekyll 处理)。推送后约 1 分钟生效。
- **禁止搜索引擎收录**：`robots.txt` 保持 `Disallow: /`；每个 HTML 页面的 `<head>` 都要有 `<meta name="robots" content="noindex, nofollow">`。
- **四门课** (目录名 · 显示名)：
  - `aerodynamics/` · Aerodynamics 空气动力学
  - `structure-material/` · Structure and Material 结构与材料
  - `flight-dynamics/` · Flight Dynamics 飞行力学
  - `mechanics/` · Engineering Mechanics I 工程力学
- **页面类型与适用规则**：

| 页面 | 来源 | 适用规则 |
|---|---|---|
| `index.html`、各课程 `index.html`、`404.html` (导航页) | 手写，共用 `assets/site.css` | 全部规则 |
| `*/course-notes.html` (课程笔记) | 单文件：内嵌 CSS/JS、KaTeX 预渲染、图片 base64 内嵌 | 全部规则 |
| `structure-material/exercises.html`、`flight-dynamics/exercises.html` (习题页) | **构建产物**，源文件在各自的 `_build/exercises/` | 全部规则，但只改源文件 (见第八节) |
| `structure-material/truss-stiffness-animation.html` (交互演示) | 手写单文件，自有样式，公式用 MathJax | 术语、文字排版、`<head>` 要求、返回首页链接；样式与公式引擎例外 |
| `aerodynamics/notebooks/*.html` | Jupyter 导出，正文为英文 | **不改正文**，只允许改 `<head>` 元信息 |
| PDF、`.m`、`.mat`、`.txt`、`.zip`、`.pptx`、`.ipynb`、图片 | 原始资料 | 原样保存，不改内容 |

---

## 二、术语 (最高优先级，禁止另造译名)

### 1. 全站统一术语 (出现即用此写法)

**空气动力学 / 飞行力学**

| 中文 | 英文 | 禁用写法 |
|---|---|---|
| 迎角 | angle of attack | 攻角 |
| Mach 数 | Mach number | 马赫数、Mach数 |
| Reynolds 数 | Reynolds number | 雷诺数、Reynolds数 |
| 黏性 / 黏度 | viscous / viscosity | 粘性、粘度 |
| 无黏 | inviscid | 无粘、理想流体 |
| 升力 | lift | 举力 |
| 升力线 | lifting line | 举力线 |
| 诱导阻力 | induced drag | 诱生阻力 |
| 翼型 | airfoil | 翼剖面 |
| 环量 | circulation | 循环量 |
| 下洗 | downwash | — |
| 展弦比 | aspect ratio (机翼) | 长宽比 |
| 单位展长 | per unit span | — |
| 边界层 | boundary layer | 附面层 |
| 失速 | stall | — |
| 流动分离 | flow separation | — |
| 压力系数 | pressure coefficient | 压强系数 |
| 面元法 / 涡面元 | panel method / vortex panel | 面板法、涡面板 |
| 声速；亚声速 / 跨声速 / 超声速 | speed of sound; subsonic / transonic / supersonic | 音速、亚音速、跨音速、超音速 |
| 激波 | shock wave | 冲击波 |
| 配平 | trim | — |

**结构 / 力学**

| 中文 | 英文 | 禁用写法 |
|---|---|---|
| 挠度 | deflection (梁位移) | — |
| 静矩 | first / static moment | 一次矩 |
| 虚功 / 虚位移 | virtual work / displacement | — |
| 载荷 | load | 荷载 |
| 节点 / 节点法 | node, joint / method of joints | 结点、结点法 |
| 切应力 | shear stress | 剪应力 |
| 切应变 | shear strain | 剪应变 |
| 剪力 | shear force (截面内力 Q) | 切力 |
| 剪切模量 | shear modulus | — |
| 屈曲 | buckling | ("失稳"只在泛指稳定性丧失时用) |
| 有限元 | finite element | 有限单元 |
| 固有频率 | natural frequency | 本征频率、自然频率 |
| 振型 | mode shape | 模态形状 |
| 刚度矩阵 | stiffness matrix | 劲度矩阵 |
| 层合板 / 单向层 | laminate / unidirectional ply | 层压板、单层板 |

- "粘"只作动词 (读 zhān) 时保留，如"粘在表面上""粘结""脱粘 (debonding)"；表示黏性的一律用"黏"。
- 剪力 (shear force) 与切应力 (shear stress) 是不同的量，不要把"剪力"改成"切力"。

### 2. 矢量 vs 向量 (按语境区分，两者都合法)

- **物理量 → "矢量"**：速度矢量、角速度矢量、力矢量、涡量矢量、应力矢量、牵引力矢量、力矩矢量、位置矢量、定位 / 滑移 / 自由矢量、矢量积、矢量场、矢量代数、矢量投影、矢量求导、单位矢量 (物理语境)
- **线性代数对象 → "向量"**：特征向量、基向量、列向量、状态向量、零向量、法向量、载荷向量、位移向量、应变 / 应力向量 (Voigt 列向量)、振型向量、模态坐标向量、方向向量、单位向量 (几何 / 代数语境)、参考向量、常向量、形函数向量
- 判断不了时保持原文，并在回复中列出待确认。

### 3. 易混淆概念 (是不同概念，切勿"统一"错)

- **下沉** (sink rate，飞行下降率)≠ **下洗** (downwash，翼尖涡诱导速度)
- **展长** (span length，"单位展长"per unit span)≠ **翼展** (wingspan，机翼总展长)
- **长宽比** (板屈曲的 plate aspect ratio)≠ **展弦比** (机翼 aspect ratio)
- **流动分离** (flow separation)≠ **失速** (stall，相关但不同)
- **剪力** (shear force，截面内力)≠ **切应力** (shear stress，单位面积上的力)
- **支反力** (support reaction)≠ **约束反力** (constraint force，泛指一切约束力)

### 4. 新增术语

- 新课程或新章节出现表中没有的术语：先查本站已有页面 (尤其各附录 B 中英术语表) 里的写法并沿用；全站都没有时，采用全国科学技术名词审定委员会 (术语在线) 的规范名，并在回复中列出新增术语，建议补进上表。

---

## 三、文字排版

### 1. 语言与英文标注
- 正文、标题、目录、表格一律**以中文为主，英文辅助标注**：专业术语**每章首次出现**时在中文后用半角括号标注英文：`迎角 (angle of attack)`。同一章后文不再重复标注。
- **不要用英文原文替换中文术语** (标题、目录、加粗、表格里也不要)，英文只作括号注释；需要对照时查附录 B 中英术语表。
- 题目原文 (习题页 `.q` 块)、课件原名 (Lecture / Tutorial / Home Exercise / Slides 等)、人名保留英文。
- 人名、定理名保留规范写法；两个人名并列用**连接号 en dash `–`**，不用连字符 `-`：Kutta–Joukowski、Navier–Stokes、Prandtl–Glauert、Euler–Bernoulli、Green–Lagrange、Euler–Eytelwein。其他：von Mises、Bernoulli、Reynolds、Mach。

### 2. 空格
- 中文与英文单词、中文与阿拉伯数字之间加一个半角空格：`Mach 数`、`第 3 章`、`共 46 页`、`Lecture 7 例 3`。
- 中文与全角标点之间不加空格；英文与全角标点之间也不加空格。
- 数字与单位之间加空格：`70 GPa`、`26 MB`、`1 m`；`%`、`°` 紧跟数字：`45°`、`50%`。

### 3. 标点
- 中文句子用**全角**标点：，。、；：？！(括号和引号除外，见下)
- 英文短语、公式、代码内部用半角标点。禁止在中文之间夹半角逗号、分号、冒号。
- **括号**：一律用半角括号 `( )`，不用全角括号。括号内的内容照常书写 (中文内容里的逗号仍用全角)。
  - 括号外侧紧挨中文、英文或数字时留一个空格：`迎角 (angle of attack) 增大`、`尖点 (cusp，后缘角为零)，`、`共 18 页 (含解答)`。
  - 括号外侧紧挨标点、行首行尾或另一个括号时不加空格：`升力 (lift)，`、`(见第 9 章)`。
  - 括号内侧不加空格：`(Slide 25)`，不写 `( Slide 25 )`。
  - 公式里 `\text{}` 中的括号同样用半角：`\text{相对厚度 (平直翼)}`。
- **引号**：一律用半角直引号 `"…"`，不用弯引号和直角引号。写在 JS 字符串里的提示文字也一样。
- **范围**：数字、章节、页码范围用 en dash `–`：`第 1–15 章`、`Lecture 2–7`、`p. 30–71`。
- 破折号用 `——`，省略号用 `…` (或 `……`)，不用 `...`。
- 乘号用 `×` (`5.8×10⁶`)，不用字母 x。

### 4. 勘误与补充
- 对课件 / 教材的笔误、疑点，用"注意""补充 (课件未写)""课件写的是……应为……"等明确标注；习题页用 `.note` (补充说明) 和勘误块。不擅改结论、数据、公式结果。
- 拿不准的地方写"待确认"，不要替课件"修正"。

---

## 四、公式

- **一律用 KaTeX 预渲染为静态 HTML** (课程笔记、习题页)。浏览器端不再运行 KaTeX；KaTeX 的 CSS 和 woff2 字体以 base64 内嵌在页面里。新渲染统一用 `katex@0.16.47` (与习题页构建一致)。
- **禁止**图片公式、手写 Unicode 拼凑的复杂公式、未渲染的 `$...$` 源码、乱码 / 错位符号。简单的单个符号 (ψ、Γ、V∞、c<sub>l</sub>) 在导航页卡片里可用 Unicode / `<sub>` `<sup>`。
- **课程笔记**：没有源文件，公式以渲染结果的形式存在；每个 `<span class="katex">` 内的 `<annotation encoding="application/x-tex">` 保存 TeX 源码。修改公式时：取出 annotation 里的 TeX → 修改 → 用 KaTeX 重新渲染 → 替换**整个** `<span class="katex">…</span>` (行间公式是外层的 `<span class="katex-display">`)，不要只改 HTML 里的个别字形。笔记用的输出格式是 HTML + MathML：
  ```js
  katex.renderToString(tex, { displayMode, output: 'htmlAndMathml', throwOnError: true, strict: 'ignore' })
  ```
  替换前后检查：TeX 中的反斜杠没被当作转义 (`\nu`、`\theta`、`\rho` 等最容易出错)、`<`、`>`、`&` 已转义、页面里不残留 `$`。
- **习题页源文件**：行内 `\( ... \)`，行间 `\[ ... \]` (构建脚本只认这两种，不认 `$`)。
- **交互演示页**：MathJax，行内 `$...$`；Jupyter 导出页保持原样。
- 写法：变量斜体，矢量 `\vec{V}` (习题页、笔记)，矩阵 / 列向量粗体 `\mathbf{K}`，下标中的文字用 `\text{}` 或正体；复杂公式可用 `\underbrace`、`\boxed`，并配中文说明。
- 行间公式在笔记中放在 `<div class="eq">` 里；重点公式可加 `.key-eq` (仅 Flight Dynamics 已有样式)。

---

## 五、图与表

### 图
- 结构：`<figure>` → `<span class="image-viewport" …><img alt="…" loading="lazy" decoding="async" src="data:…"></span>` → `<figcaption><span class="fig-no">图 X.Y</span>说明</figcaption>`。`alt` 写图意 (可与图注相同，去掉引号和标签)。
- 编号按章连续：正文 `图 3.1, 3.2, …`；附录 `图 C.1`；以图片形式出现的表格用 `表 X.Y`。新增 / 删除图后，同章后续编号和正文里的引用 (`图 3.4`、`.xref`) 要一起更新。
- 笔记里的图片以 base64 内嵌 (单文件可离线打开)；习题页的图放在 `structure-material/exercises/*.png` (Flight Dynamics 为 `flight-dynamics/exercises/*.png`)，用相对路径引用。
- 图片来源：课件原图截取 / 裁剪；补画部分在 hero 简介或图注里说明。

### 表
- 外层 `<div class="table-wrap">`，表格加列数类 `cols-2` … `cols-5`。
- 每一行的单元格数 (含 `colspan`) 必须等于表头列数；不要出现拆开的单元格或模板残留 (`{{`、`}}`、`$`)。
- 附录专用表类：`formula` (公式速查)、`glossary` (中英术语表)、`symbols` (符号表)。

---

## 六、页面结构 (复用骨架，禁止自创布局)

### 1. 所有页面的 `<head>`
```html
<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="robots" content="noindex, nofollow">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>…</title>
<link rel="icon" href="../favicon.svg" type="image/svg+xml">   <!-- 首页为 favicon.svg，404 为 /favicon.svg -->
```
- `<title>` 格式：
  - 首页：`学习笔记 · Study Notes`
  - 课程目录页：`English 中文 · 学习笔记`，如 `Aerodynamics 空气动力学 · 学习笔记`
  - 课程下的其他页面：`English 页面名 · 学习笔记`，如 `Aerodynamics 课程笔记 · 学习笔记`、`Structure and Material 习题与解答 · 学习笔记`

### 2. 首页 `index.html`
- `h1` 学习笔记 + `.sub` → 每门课一个 `section`：`h2` (`English 中文 <a href="课程目录/">全部资料 →</a>`)+ `ul.items` → `footer`。
- 每门课至少两张卡片：课程笔记卡片 + 资料目录卡片。卡片结构：`<a>` 内含 `.t` 标题、`.tag` 标签、`.d` 描述。

### 3. 课程目录页 `课程/index.html`
- `.crumb` (`<a href="../">← 首页</a>`)→ `h1` (`English 中文`)→ `.sub` (资料类别，用" · "分隔)→ 各资料 `section` → `footer`。
- 分区 `h2`：`中文 English`，如 `习题解答 Tutorials`；需要打包下载时在 `h2` 内加 `<a>打包下载 ↓</a>`。
- 分区说明用 `p.note`；尚无内容的分区用 `<p class="empty">(待添加，放在 xxx/ 文件夹)</p>`。
- 条目两种：
  - 单个文件 → `ul.items > li > a` (`.t` + `.tag` + `.d`)
  - 多个文件 → `ul.items > li > div.card` (`.t` + `.tag` + `.d` + `div.links`)；`.links a` 的主文件不加类，次要 / 原始文件加 `class="alt"`，链接文字写类型 (`答案版 .m`、`原 PDF`、`网页版`)。

### 4. 显示文字约定 (同一级别用同一种写法)
- 课程名 (首页区块标题、课程页大标题)：`English 中文`，例如 `Aerodynamics 空气动力学`。
- 课程页分区标题：`中文 English`，例如 `习题解答 Tutorials`。
- 条目标题：有编号的写成 `英文编号 · 中文主题` (`Tutorial 1 · 流动运动学`、`Home Exercise 4 · 屈曲`、`Notebook 2 · 涡量与环量`、`W5 · 桁架与分布载荷`)；无编号的写成 `中文 English`。编号不补零。
- `.tag` 标签：课程笔记一律写 `第 1–N 章`；首页资料卡片写 `N 次习题课` (没有习题课的课程写最主要的资料数量，如 `1 道作业题`)；其余写 `来源 · N 页` (来源可省略)，文件特别大时加大小：`46 页 · 66 MB`。
- 笔记章标题右侧的来源标签 `.ch-src` 用英文原名：`Lecture 3 · CE W4`、`Slides p. 30–71`、`Lecture 4 · Tutorial 4`。
- 返回首页：课程页顶部 `.crumb` 和笔记 / 习题页顶栏都固定显示 `← 首页`。

### 5. 课程笔记 `course-notes.html`
新课程复制 `mechanics/course-notes.html` 作为模板，清空正文后填写。骨架：
```
header.topbar      a.home-btn"← 首页"· button.menu-btn · .reading-location(#tbTitle) · .gsearch 全站搜索
aside.sidebar      a.brand(.brand-kicker 英文课程名 + .brand-title 课程笔记) · .toc-tools · nav > ol.nav-list(li.nav-part / li.nav-ch)
main
  header.hero      p.kicker(English · 来源范围) · h1(中文课程名 课程笔记) · p.hero-lead · section.home-part×N(h2.part-title + div.cards > a.card)
  div.part-banner#partN (.pb-no 第X部分 · .pb-name · .pb-range 第 a–b 章)
  section.chapter#chN
    h2.ch-title > span.ch-num"第 N 章"+ 标题 + span.ch-src
    p.lead                 章导读
    h3#chN-M > span.sec-no"N.M"  节 (编号连续)
    h4                     小节 (无编号)
    …正文、div.eq、figure、div.table-wrap、p.note
    div.keypoints          章末"本章要点"(p.kp-title + ul)，必须是该章最后一个元素
  div.part-banner#part-app (附录 · 复习工具 · 附录 A–C)
  section.chapter.appendix#appA / #appB / #appC
  footer.foot
```
- 附录：A"公式速查"(`table.formula`) 和 B"中英术语表"(`table.glossary`) 每门课必备；C 按课程选择——符号表 (`table.symbols`)、模拟考试题型概览或整理与校对说明。
- 侧栏目录、hero 卡片、部分横幅里的章节名和编号必须与正文一致；增删章节时同步修改这三处以及 hero 简介里的章数 / 图数。
- 复制模板后还要改：顶栏 `#tbTitle` 的初始文字和脚本里的同一默认值 (如 `'工程力学 I 课程笔记 · 课程总览'`，两处保持一致)、`<meta name="description">`。
- 章节内交叉引用用 `<a class="xref" href="#chN-M">§N.M</a>`。
- 笔记**没有**前后翻页条；翻页靠侧栏目录和全站搜索。

### 6. 习题页 `exercises.html`
- 源文件 `_build/exercises/src/NN-xxx.html`，按文件名顺序拼接；`template.html` 提供顶栏、侧栏、hero 和脚本。
- 每组题：`section.set#id[data-short]` → `h2.set-title` (`span.set-num` + 中英标题 + `span.set-src`)→ `p.lead` → 若干 `article.task#id` (`h3 > span.tno` + 标题；`div.q` 英文原题；`details.sol` 解答，默认收起；`div.note` 补充说明)。
- id 前缀决定分组：`l` 课堂例题、`t` Tutorial (Flight Dynamics 中为合并后的习题课 Exercise Session)、`h` Home Exercise、`e` (`ex`) Trial Exam。课程目录页用 `exercises.html#t1` 这类锚点链接，改 id 时同步改链接。

### 7. 404 页
- 用根路径 (`/assets/site.css`、`/favicon.svg`、`/`)，因为它会在任意路径下显示；这是"一律相对路径"的唯一例外。

### 8. 页脚
- 导航页：`最后更新：YYYY-MM-DD · <a href="https://github.com/stickydog/stickydog.github.io">源文件</a>`
- 课程笔记：`更新于 YYYY-MM-DD · 内容整理自 ……`
- 改了页面内容就把该页日期改为当天；首页日期取全站最近一次更新。

---

## 七、样式与脚本

- 导航页 (首页、课程目录页、404) 只用 `assets/site.css`，不写 `<style>`，不写 `style=""` 行内样式；要新样式就加到 `site.css`。
- `.links a` 必须是 `display: inline-block` (已在 `site.css` 中定义，不要在页面里覆盖)。
- 课程笔记：内嵌 CSS 分两层——所有笔记共用的**基础层** (`:root` 变量、版式、侧栏、图片放大、深色模式，四门课逐字相同)+ 课程专用的**扩展层** (如 Structure and Material 的 `flow-*`、Flight Dynamics 的 `key-eq`/`slide-*`)。改基础层要四个文件一起改；不要在单章里写行内样式覆盖。内嵌脚本 (目录、搜索、阅读位置、图片放大) 四门课相同，只有顶栏默认标题不同。
- 设计变量统一：`--bg #faf9f6`、`--fg #1e1c19`、`--muted #6a655c`、`--line #e4e0d7`、`--accent #1d4f7c`；正文字体 serif (Noto Serif SC)，界面 sans (Noto Sans SC)；深色模式用 `prefers-color-scheme: dark`。习题页 `template.html` 使用同一组变量。
- 交互演示页可以有自己的配色和字体，但要保留 `.crumb` 返回首页和课程笔记的链接。
- 不引入新的外部依赖 (CDN 脚本、框架)；现有的 Google Fonts 和 MathJax CDN 保持不变。

---

## 八、文件、命名与构建

### 命名
- 课程目录名、文件名只用小写英文、数字和连字符：`week05-boundary-layer.pdf`；不要用空格、中文、下划线。
- 例外：MATLAB 代码和它读取的数据文件保留原名 (函数名必须与文件名一致，脚本里也按原名读取数据)。
- 资料子目录按需使用：`lectures/`、`tutorials/`、`exercises/`、`homework/`、`exam/`、`code/`、`lab/`、`notebooks/`、`handwritten/`；自己的作答放在 `my-work/`。
- 页面之间一律用相对路径链接 (`../`、`exercises.html#t1`)，404 页除外。
- **不要重命名或移动已有文件**；确实需要时，同步修改所有指向它的链接，并在回复里说明。

### 大小
- 单个文件不超过 100 MB (GitHub 硬限制)，超过 50 MB 会有警告；仓库总量保持在 1 GB 以内。导航页卡片标签里注明大文件的大小。

### 习题页构建
```bash
cd structure-material/_build/exercises    # 或 flight-dynamics/_build/exercises
npm install          # 首次；node_modules/ 已在 .gitignore 中
npm run build        # 生成 ../../exercises.html
```
- **永远不要直接编辑 `exercises.html`**：标题、页脚、样式改 `template.html`；题目内容改 `src/*.html`；然后重新构建并把 `exercises.html` 一起提交。
- 构建脚本遇到 KaTeX 错误会报错退出 (不会生成半成品)；修好再构建。
- 检查是否有人手改过产物：构建到临时文件后与仓库里的 `exercises.html` 比较，应完全一致。

### 添加资料 (已有课程)
1. 文件放进对应课程文件夹的子目录。
2. 在该课程 `index.html` 的对应分区加一条 (单文件用 `a`，多文件用 `div.card` + `.links`)。
3. 如果改变了首页卡片里的数量 (如习题课次数)，同步改首页 `.tag` / `.d`。
4. 更新页脚日期；有需要时更新 README 的目录树。

### 添加新课程
1. **建目录**：`课程英文名/` (小写、连字符)，按需建子目录。
2. **课程目录页**：复制 `mechanics/index.html`，改 `<title>`、`h1`、`.sub` 和各分区；相对路径 `../favicon.svg`、`../assets/site.css`、`../`。
3. **课程笔记**：复制 `mechanics/course-notes.html`，按第六节第 5 条的骨架填写；`<title>` 写 `English 课程笔记 · 学习笔记`。
4. **首页**：在 `main` 内按课程顺序新增一个 `section` (`h2` + 课程笔记卡片 + 资料卡片)，同步改首页 `<meta name="description">`。
5. **README 与本文件**：README 目录树加上新课程；本文件"一、网站概况"的课程列表加上新课程；新术语按第二节第 4 条处理。
6. 按第九节自检。

---

## 九、提交前自检

**内容**
- [ ] 术语逐一对照第二节；没有新造译名；矢量 / 向量按语境
- [ ] 标点、半角括号、空格、直引号、en dash 符合第三节；全站没有全角括号 `（）` 和弯引号 `“”`
- [ ] 公式全部是渲染好的 KaTeX；页面中无残留 `$`、`\(`、TeX 源码、`{{ }}`、`katex-error`
- [ ] 每章末尾有"本章要点"；节号、图号连续；侧栏 / hero / 正文的章节名一致
- [ ] 表格每行单元格数与表头一致
- [ ] 只改形式，没有改动结论、数据、公式结果

**结构与链接**
- [ ] `<head>` 含 `lang="zh-CN"`、`robots noindex`、`viewport`、favicon，`<title>` 格式正确
- [ ] 所有内部链接和锚点都能打开 (可用脚本遍历 `href` / `src`，检查目标文件和 `id` 是否存在)
- [ ] 新增文件已在课程目录页登记；首页数量标签同步
- [ ] 改过的页面已更新页脚日期

**构建与提交**
- [ ] 改了习题页源文件就重新 `npm run build`，并提交 `exercises.html`
- [ ] 不提交 `node_modules/`、临时文件、系统文件 (`.DS_Store`)
- [ ] 提交信息用中文简要说明改了什么 (例如 `结构与材料：修正附录 C 符号表 K 行`)

---

## 十、维护铁律 (每次修改必须遵守)

1. **术语**：先查第二节，禁止引入新译名；不确定时保持原术语并标注待确认。
2. **结构**：新增课程 / 页面复制现有骨架，不另起炉灶。
3. **样式**：改样式改 CSS (导航页改 `site.css`，笔记改基础层且四门课同步)，不写页面级覆盖。
4. **公式**：一律 KaTeX 预渲染，不手写乱码、不用图片公式、不留 `$`。
5. **构建**：`exercises.html` 只能由 `_build/exercises/` 构建生成。
6. **只改形式不改含义**：不改变核心含义、事实、数据、结论；不破坏代码、链接、锚点、公式语法。
7. **不删除、不重命名用户的文件和内容**，除非用户明确要求。
8. **拿不准处标注待确认**，在回复中列出，不擅自改动。
