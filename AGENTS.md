# 网站维护与一致性规范（AGENTS.md）

> 本文件是本网站维护时 AI 助手必须遵守的规范。任何新增、修改、校对内容都必须先对照本规范，保持全站一致性。

## 网站概况

- **性质**：航空航天工程课程学习笔记（个人使用，GitHub Pages 静态站）
- **四门课**：空气动力学 Aerodynamics、结构与材料 Structure and Material、飞行力学 Flight Dynamics、工程力学 I Engineering Mechanics I
- **技术栈**：纯静态 HTML + CSS；公式用 KaTeX 服务端预渲染；桁架动画页用 MathJax；Notebooks 为 Jupyter 导出
- **目录结构**：每门课一个子目录（`index.html` + `course-notes.html` + 资料文件），共享 `assets/site.css`
- **构建**：`structure-material/exercises.html` 由 `structure-material/_build/exercises/build.js` 从 `src/*.html` 生成（KaTeX 预渲染），改它必须改源文件并 `npm run build`

---

## 一、术语规范（最高优先级，禁止另造译名）

### 全站统一术语（出现即用此写法）

| 中文 | 英文 | 禁用写法 |
|---|---|---|
| 迎角 | angle of attack | 攻角 |
| Mach 数 | Mach number | 马赫数 |
| Reynolds 数 | Reynolds number | 雷诺数 |
| 黏性 | viscous | 粘性 |
| 升力 | lift | 举力 |
| 翼型 | airfoil | 翼剖面 |
| 环量 | circulation | 循环量 |
| 下洗 | downwash | — |
| 展弦比 | aspect ratio（机翼） | 长宽比 |
| 挠度 | deflection（梁位移） | — |
| 静矩 | first/static moment | 一次矩 |
| 无黏 | inviscid | 无粘、理想流体 |
| 虚功 / 虚位移 | virtual work / displacement | — |
| 单位展长 | per unit span | — |
| 失速 | stall | — |
| 流动分离 | flow separation | — |

### 矢量 vs 向量（按语境区分，两者都合法）

- **物理量 → 用「矢量」**：速度矢量、力矢量、涡量矢量、应力矢量、牵引力矢量、力矩矢量、位置矢量、定位/滑移/自由矢量、矢量积、矢量场、矢量代数、矢量投影、单位矢量（物理语境）
- **线性代数对象 → 用「向量」**：特征向量、基向量、列向量、状态向量、零向量、法向量、载荷向量、应变/应力向量（Voigt 列向量）、振型向量、模态坐标向量、方向向量、单位向量（几何/代数语境）、参考向量、常向量、形函数向量

### 易混淆概念（是不同概念，切勿"统一"错）

- **下沉**（sink rate，飞行下降率）≠ **下洗**（downwash，翼尖涡诱导速度）
- **展长**（span length，"单位展长" per unit span）≠ **翼展**（wingspan，机翼总展长）
- **长宽比**（板屈曲的 plate aspect ratio）≠ **展弦比**（机翼 aspect ratio）
- **流动分离**（flow separation）≠ **失速**（stall，相关但不同概念）

---

## 二、排版与格式规范

### 文字
- 正文中文为主；专业术语**首次出现**时用半角括号标注英文：`迎角 (angle of attack)`
- 中文用**全角**标点，英文/公式用**半角**；禁止"中文,英文"式半角标点紧跟中文
- 人名、品牌名、定理名保留规范写法（Kutta–Joukowski、Prandtl、Bernoulli、Navier–Stokes、Reynolds、Mach）

### 公式
- 一律用 KaTeX 渲染：行内 `$...$`，独立 `$$...$$` 或 `\[...\]`；禁止手写图片公式、禁止乱码/错位符号
- 变量用斜体，矢量用 `\vec{V}`，上下标规范
- 复杂公式用 `\underbrace`、`\boxed` 提升可读性，并配中文注释

### 标题与结构
- 层级：`h1`（页标题）→ `h2`（`.ch-title` 章标题）→ `h3`（节，带 `.sec-no` 编号）→ `h4`（小节）
- 章标题带 `.ch-num` 编号徽章；分部用 `.part-banner`
- 每章末尾必须有「本章要点」总结块（`.keypoints`）

### 图与表
- 图用 `<figure>` + `<figcaption>`，图注带「图 X.Y」编号 + 说明
- 表格三类用对应类名：`formula`（公式表）、`glossary`（术语表）、`symbols`（符号表）

### 勘误标注
- 对课件/教材的笔误、疑点，用「注意」「补充」「课件写的是…应为…」明确标注，不擅改结论、数据、公式结果

---

## 三、页面结构规范（复用骨架，禁止自创布局）

- **首页 `index.html`**：`h1` + 课程 `section`（`h2` + `ul.items` 列表）
- **课程 `index.html`**：`.crumb` 返回首页 → `h1` + `.sub` → 各资料 `section` → `footer`
- **`course-notes.html`**：sidebar 目录导航 + hero + `part-banner` 分部 + `chapter` 章 + 附录三件套（公式速查 / 中英术语表 / 符号表）+ `.pager` 前后翻页
- **`exercises.html`**：构建产物，源文件在 `_build/exercises/src/*.html`

---

## 四、CSS 与样式规范

- 导航页统一用 `assets/site.css`；笔记页用内嵌的**同一套** CSS（`:root` 变量一致）
- 文件小标签 `.links a` 必须 `display: inline-block`（不写页面级内嵌覆盖）
- 颜色/字体变量统一：正文 serif（Noto Serif SC），界面 sans（Noto Sans SC）；深色模式用 `prefers-color-scheme`

---

## 五、维护铁律（每次修改必须遵守）

1. **术语**：先查上文术语表，禁止引入新译名；不确定时保持原术语并标注
2. **结构**：新增课程/页面复制现有骨架，不另起炉灶
3. **样式**：改样式优先改 CSS，不写页面级内嵌覆盖
4. **公式**：一律 KaTeX，不手写乱码、不用图片公式
5. **构建**：改 `exercises.html` 必须改 `_build/exercises/src/` 源文件并重新构建
6. **只改形式不改含义**：不改变核心含义、事实、数据、结论；不破坏代码、链接、公式语法
7. **拿不准处标注待确认**，不擅自改动
