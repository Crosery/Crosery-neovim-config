# lua/acp — ACP Agent 包

自研的 nvim 内置 agent 协议实现，共 17 个文件 / 约 4400 行。`lua/plugins/acp.lua` 是 lazy spec 入口，本包是逻辑实现。

## 分层

```
入口 / 命令       init.lua (501)         :Acp 命令分发
                 commands.lua (358)     频道与 chat 输入框 / 命令补全

频道（多 agent）  bus.lua (136)          Facade：组合 channel + view
                 channel.lua (380)      消息存储、agent 管理、事件
                 channel_view.lua (421) buffer/window 渲染、winbar
                 router.lua (57)        @mention 路由
                 scheduler.lua (258)    main 队列 / prompt 调度 / 兜底
                 registry.lua (141)     全局单例：channels + chats

私聊             chat.lua (599)         1v1 vsplit + 底部输入框

Agent / Task     agent.lua (83)         spawned/local agent 数据模型
                 task.lua (34)          轻量任务原语

底层             client.lua (714)       spawn 进程、ACP 握手、流式
                 jsonrpc.lua (115)      LineBuffer + JSON-RPC 2.0
                 adapter.lua (192)      CLI spawn 配置注册表
                 rpc.lua (184)          nvim --server 暴露的 RPC 入口
                 store.lua (100)        频道快照持久化

工具             picker.lua (127)       fzf-lua 选择列表
```

## 入口 / 命令

`:Acp [子命令]`：
- 无参 → `toggle_or_start`
- `chat <adapter> [api_num]` / `--join [name]` → 私聊或加入频道
- `bus <adapter> [agent_name]` → 频道
- 详见 `init.lua` 第 12-100 行

键位（`lua/plugins/acp.lua`）：
- `<A-u>` → `:Acp`
- `<A-i>` → `:Acp list`

## 数据流

1. `init.lua` 解析命令 → 调用 `registry` 拿单例
2. `bus` / `chat` 创建 → 调用 `client:spawn` 启动 CLI 进程
3. `client` 通过 `jsonrpc` 走 stdin/stdout JSON-RPC 与 CLI 通信
4. 收到消息 → `channel:append` → `channel_view:render`
5. `@mention` → `router:resolve` → `scheduler:enqueue`

## 日志

全部写 `~/.config/nvim/logs/`：
- `acp-bus.log`：channel / router / scheduler
- `acp-chat.log`：chat
- `acp-client.log`：client spawn / RPC

debug 时直接 `tail -f`。

## 持久化

`store.lua` 把频道快照按 `cwd` 编码存盘。`encode_cwd` 把 `/` 替换成 `-`。

## 修改约束

- **bus / channel / view 三件套**：Facade 模式，Bus 代理 channel + view 字段（见 `bus.lua` `__index`）。新增字段在 channel / view 上加，Bus 自动透传。
- **Agent 状态机**：`agent.lua` `status` 字段 `connecting|idle|streaming|disconnected|error`；改状态前必须更新 `last_rpc_time`。
- **JSON-RPC**：和 `codecompanion/utils/jsonrpc.lua` 对齐（`jsonrpc.lua` 顶部注释明示），不要私自改协议字段。
- **新 adapter**：在 `adapter.lua` 注册 spawn 命令 + env，不要在调用方硬编码。

## 当前定位

工作流已改为外部 Claude Code，本包是用户保留的研究方向。不主动启动，按 `<A-u>` 才唤起。不要因为"工作流改了"删除本包。
