# Slowmode — Hardcore Dev Harness Lite

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Version](https://img.shields.io/badge/skill-2.0.0-blue)](./skills/hardcore-dev-harness/SKILL.md)

[English](./README.md) | [简体中文](./README.zh.md)

> 一套可移植的 **Agent Skill**，给 AI 编程助手增加一层轻量工程协议：跨会话上下文、重复建设检查、成功标准、证据闭环、工作树卫生、可选 repo 级自动 handoff commit，以及 lessons 沉淀。

Slowmode 不再是重型 gate / 人格系统。它保留真正有用的检查，删除仪式感。

---

## 快速开始

**安装为 Cursor skill，并打印 User Rule：**

```bash
git clone https://github.com/lz10081/slowmode.git
cd slowmode && ./scripts/install.sh global
```

把打印出的文本粘贴到 **Cursor Settings → Rules → User Rules**，然后新开 Agent 会话。User Rule 只指向 Lite 协议，不再要求每条回复带 gate footer。

**只安装到一个项目：**

```bash
./scripts/install.sh cursor-rule /path/to/your-app
# 或
./scripts/install.sh claude-md /path/to/your-app
```

**可选的一次性 repo 采用配置：**

```markdown
# AGENTS.md

Use Hardcore Dev Harness Lite for implementation/debug/refactor tasks.

Repo overrides:
- handoff_commit: true  # 只有想启用验证后自动 commit 时才加
- Use repo-specific evidence profiles where applicable.
```

只有当项目真的需要跨会话连续性时，才脚手架 `FEATURES.md`、`PROGRESS.md`、`DECISIONS.md`、`tasks/lessons.md`。

---

## 这是什么

Slowmode 是 markdown 指令，不是应用，也不是 npm 包。

| 文件 | 用途 |
|------|------|
| `skills/hardcore-dev-harness/SKILL.md` | 完整 Lite skill，唯一 source of truth |
| `CLAUDE.md` | Claude Code、`AGENTS.md`、自定义指令的单文件版 |
| `.cursor/rules/hardcore-dev-harness.mdc` | 指向 skill 的短 Cursor/Windsurf 项目规则 |
| `skills/hardcore-dev-harness/USER-RULE.txt` | 简短 Cursor 全局 User Rule 文本 |
| `skills/hardcore-dev-harness/PERSISTENCE.md` | 如何保持 Lite 生效且不重新膨胀 |

---

## 解决什么问题

| 痛点 | Lite 对策 |
|------|-----------|
| 重复造已有功能 | 连续性读取后声明一次 `REUSE` / `EXTEND` / `NEW` / `REPLACE` |
| 用户已经给完整 spec，agent 还机械提问 | 把 spec 当边界文档，≤3 条复述验收标准 |
| 成熟 repo 被强行套新骨架 | gate 式 skeleton 只用于 `new_project`；成熟 repo 扩展现有路径 |
| “测试通过”但产品/数据质量不对 | evidence gate 要求真实调用和任务相关验证 |
| 数据 pipeline 被口头 rubber-stamp | pipeline profile 要求 SQL sanity 和可见样本审查 |
| 长任务被杀还声称完成 | long-job rule 要求 sample/time budget 和明确 `Unverified:` |
| working tree 一团乱 | worktree hygiene + 可选验证后 handoff commit |
| 用户纠正被忘记 | 可把反复出现的行为问题写入 `tasks/lessons.md` |

---

## Lite 协议

对 implementation/debug/refactor 工作：

1. 用 ~60 秒预算读取连续性文件：`PROGRESS.md`、`DECISIONS.md`、`FEATURES.md`、相关 lessons。
2. 声明一次 `REUSE` / `EXTEND` / `NEW` / `REPLACE`。
3. 把任务转成成功标准。若用户已有验收标准，≤3 条复述。
4. 沿现有 ownership path 做最小改动。
5. 用与任务匹配的证据验证。
6. 按职责更新状态文件：
   - `FEATURES.md` = 已交付行为 + 验证 + 运行 gotchas。
   - `PROGRESS.md` = 当前工作和下一步，可变。
   - `DECISIONS.md` = 持久架构/产品/数据决策。
   - `tasks/lessons.md` = 反复出现的 agent 行为纠正。
7. 清理工作树。
8. 如果 `AGENTS.md` 设置 `handoff_commit: true`，只提交已验证、完整、可交付的 slice，且只提交本 session 自己改的文件。

纯讨论/问答不跑完整流程。如果问题涉及过去的 tradeoff，读取 `DECISIONS.md`。

---

## Evidence profiles

Lite 内置小型 evidence profile，只列必需证据：

- `pipeline-monolith`：targeted tests、score/job invocation、SQL bucket/count sanity、API check、UI 可见时 browser check、可见样本审查。
- `web-dashboard`：测试/typecheck、数据页面的 API/network check、browser render check、截图或简短视觉说明。
- `cli-script`：`--help`、一次成功真实调用、行为改变时一次失败/非法输入调用、清理生成文件。

项目专属 profile 放在 `AGENTS.md`，不要膨胀全局 skill。

---

## Handoff commit policy

全局默认：**除非用户明确要求，否则不 commit**。

Repo override：如果 repo 的 `AGENTS.md` 设置 `handoff_commit: true`，启用 autonomous handoff mode。

在 handoff mode 下，agent 只有在验证通过、工作是完整可交付 slice、且能只 stage 本 session 有意修改的文件时才 commit。若有无法安全分离的无关 dirty files，则报告 dirty tree，不 commit。

结束顺序：

```text
verify
→ 按需更新 FEATURES / PROGRESS / DECISIONS
→ git status
→ 只 stage 本 session 文件
→ 检查 staged diff
→ 允许且安全时 commit
→ final Plan / Evidence / Commit / Risks / Next handoff
```

---

## 最终 handoff 形状

不再使用每条消息的 gate footer。最终回复使用或压缩：

```markdown
Plan:
- <做了什么 / 选择了什么>

Evidence:
- <命令和结果>

Commit:
- <commit hash 或为什么没 commit>

Risks:
- <剩余风险 / 未验证项>

Next:
- <建议下一步，如有>
```

---

## 安装 targets

```bash
./scripts/install.sh --help
```

常用 targets：

| Target | 效果 |
|--------|------|
| `global` | 安装 Cursor skill 并打印 User Rule 文本 |
| `user-rule` | 打印 Cursor Settings → Rules → User Rules 文本 |
| `cursor-rule [path]` | 复制短 `.mdc` 项目规则 |
| `cursor-skill` | 复制 skill 到 `~/.cursor/skills/hardcore-dev-harness/` |
| `project-skill [path]` | 复制 skill 到 repo 的 `.cursor/skills/` |
| `claude-md [path]` | 复制 `CLAUDE.md` 单文件版 |
| `amp-skill` | symlink 到 Amp skills |
| `templates` | 复制 legacy `FEATURES.md` + `CONTRACT.md` 模板 |

---

## 仓库结构

```text
slowmode/
├── README.md / README.zh.md
├── CLAUDE.md
├── EXAMPLES.md
├── FEATURES.md
├── templates/
├── scripts/install.sh
├── .cursor/rules/hardcore-dev-harness.mdc
└── skills/hardcore-dev-harness/
    ├── SKILL.md
    ├── PERSISTENCE.md
    └── USER-RULE.txt
```

---

## 范例

见 [EXAMPLES.md](./EXAMPLES.md)：continuity opener、success criteria、evidence、pipeline sample review、handoff commit、delegation brief、lessons capture。

---

## 贡献

行为规则变更应保持这些入口一致：

- `skills/hardcore-dev-harness/SKILL.md`
- `CLAUDE.md`
- `.cursor/rules/hardcore-dev-harness.mdc`
- output 形状改变时更新 `EXAMPLES.md`
- 用户使用方式改变时更新 README

见 [CONTRIBUTING.md](./CONTRIBUTING.md)。

---

## 协议

[MIT](./LICENSE) — 可自由使用、修改与分发。
