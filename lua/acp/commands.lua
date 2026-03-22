--- Chat/频道输入框命令系统
--- / 开头的输入走命令分发，其余走正常消息

local M = {}

-- ============================================================================
-- 命令补全：输入 / 时自动弹出可用命令
-- ============================================================================

--- Chat 级命令定义（补全用）
local chat_command_defs = {
	{ word = "/status", info = "显示当前连接状态" },
	{ word = "/cancel", info = "取消当前 streaming" },
	{ word = "/exit", info = "停止 client 并退出" },
	{ word = "/compact", info = "压缩上下文（暂未接通）" },
	{ word = "/leave", info = "退出频道" },
}

--- 频道级命令定义（补全用）
local channel_command_defs = {
	{ word = "/add", info = "添加 agent: /add [adapter] [name]" },
	{ word = "/stop", info = "停止 agent: /stop <name>" },
	{ word = "/list", info = "列出所有 agent" },
	{ word = "/open", info = "打开 agent 窗口: /open <name>" },
	{ word = "/pick", info = "打开 agent 选择器" },
}

--- Claude Code CLI 命令（通过 ACP prompt 转发）
local claude_command_defs = {
	{ word = "/compact", info = "[claude] 压缩对话上下文" },
	{ word = "/cost", info = "[claude] 显示 token 用量" },
	{ word = "/clear", info = "[claude] 清空对话" },
	{ word = "/model", info = "[claude] 切换模型" },
	{ word = "/memory", info = "[claude] 管理记忆" },
	{ word = "/config", info = "[claude] 配置设置" },
	{ word = "/permissions", info = "[claude] 权限管理" },
	{ word = "/doctor", info = "[claude] 诊断问题" },
	{ word = "/review", info = "[claude] 代码审查" },
	{ word = "/init", info = "[claude] 初始化 CLAUDE.md" },
	{ word = "/help", info = "[claude] 显示帮助" },
	{ word = "/bug", info = "[claude] 报告 bug" },
	{ word = "/login", info = "[claude] 登录" },
	{ word = "/logout", info = "[claude] 登出" },
}

--- 获取补全列表
--- @param context "chat"|"channel" 上下文类型
--- @param prefix string 当前输入的 / 命令前缀
--- @return table[] [{word, info}]
function M.get_completions(context, prefix)
	local defs = {}
	local seen = {}

	-- 先加本级命令
	local local_defs = context == "channel" and channel_command_defs or chat_command_defs
	for _, def in ipairs(local_defs) do
		if not seen[def.word] then
			seen[def.word] = true
			defs[#defs + 1] = def
		end
	end

	-- 再加 Claude Code 命令（去重）
	for _, def in ipairs(claude_command_defs) do
		if not seen[def.word] then
			seen[def.word] = true
			defs[#defs + 1] = def
		end
	end

	-- 按前缀过滤
	if prefix and prefix ~= "/" then
		local filtered = {}
		for _, def in ipairs(defs) do
			if def.word:find(prefix, 1, true) == 1 then
				filtered[#filtered + 1] = def
			end
		end
		return filtered
	end

	return defs
end

--- 在 input buffer 上设置 / 命令自动补全
--- @param input_buf number 输入 buffer
--- @param context "chat"|"channel" 上下文类型
function M.setup_completion(input_buf, context)
	-- 禁用默认补全和 blink.cmp，避免 / 触发文件路径补全
	vim.bo[input_buf].complete = ""
	vim.bo[input_buf].omnifunc = ""
	vim.b[input_buf].acp_input = true

	-- Tab / S-Tab 选择补全项
	vim.keymap.set("i", "<Tab>", function()
		if vim.fn.pumvisible() == 1 then
			return "<C-n>"
		end
		return "<Tab>"
	end, { buffer = input_buf, expr = true, noremap = true })

	vim.keymap.set("i", "<S-Tab>", function()
		if vim.fn.pumvisible() == 1 then
			return "<C-p>"
		end
		return "<S-Tab>"
	end, { buffer = input_buf, expr = true, noremap = true })

	local group = vim.api.nvim_create_augroup("acp_cmd_complete_" .. input_buf, { clear = true })

	-- 进入 buffer 时设置局部 completeopt 和 pumheight
	vim.api.nvim_create_autocmd("BufEnter", {
		group = group,
		buffer = input_buf,
		callback = function()
			vim.opt_local.completeopt = { "menuone", "noinsert", "noselect" }
			vim.opt_local.pumheight = 8
		end,
	})

	vim.api.nvim_create_autocmd("TextChangedI", {
		group = group,
		buffer = input_buf,
		callback = function()
			-- 只在第一行、以 / 开头时触发
			local cursor = vim.api.nvim_win_get_cursor(0)
			if cursor[1] ~= 1 then return end
			local line = vim.api.nvim_buf_get_lines(input_buf, 0, 1, false)[1] or ""
			if not line:match("^/") then return end

			-- 避免打断已有 pumvisible
			if vim.fn.pumvisible() == 1 then return end

			local prefix = line:match("^(/[%w_%-]*)") or "/"
			local items = M.get_completions(context, prefix)
			if #items == 0 then return end

			local complete_items = {}
			for _, item in ipairs(items) do
				complete_items[#complete_items + 1] = {
					word = item.word,
					menu = item.info,
					dup = 0,
				}
			end
			vim.fn.complete(1, complete_items)
		end,
	})
end

local function next_agent_name(channel, adapter)
	local used = {}
	for name in pairs(channel.agents or {}) do
		used[name] = true
	end
	local i = 1
	while used[adapter .. "-" .. i] do
		i = i + 1
	end
	return adapter .. "-" .. i
end

--- 解析命令："/compact foo bar" → "compact", "foo bar"
--- @param text string
--- @return string|nil cmd
--- @return string args
function M.parse(text)
	return text:match("^/(%S+)%s*(.*)")
end

-- ============================================================================
-- Chat 级命令（作用于单个 Chat 实例的 client）
-- ============================================================================

local chat_commands = {}

chat_commands.status = function(chat)
	local lines = {}
	lines[#lines + 1] = "adapter: " .. (chat.adapter_name or "?")
	lines[#lines + 1] = "display: " .. (chat.display_name or chat.adapter_name or "?")
	if chat.client then
		lines[#lines + 1] = "alive: " .. tostring(chat.client.alive)
		lines[#lines + 1] = "session: " .. tostring(chat.client.session_id)
		lines[#lines + 1] = "pid: " .. tostring(chat.client.pid)
	else
		lines[#lines + 1] = "client: nil"
	end
	lines[#lines + 1] = "streaming: " .. tostring(chat.streaming)
	chat:_append_system(table.concat(lines, "\n"))
end

chat_commands.cancel = function(chat)
	chat:cancel()
end

chat_commands.exit = function(chat)
	chat:stop()
	chat:_append_system("已退出")
end

chat_commands.compact = function(chat)
	if not chat.client or not chat.client.alive then
		chat:_append_system("client 未连接")
		return
	end
	chat:_append_system("/compact 暂未接通原生 CLI 命令，当前实现已禁用")
end

chat_commands.leave = function(chat)
	if not chat.display_name then
		chat:_append_system("不在频道中")
		return
	end
	local acp = require("acp")
	local ok, err = acp.bus_leave(chat.display_name)
	if ok then
		chat:_append_system("已退出频道")
	else
		chat:_append_system("退出失败: " .. tostring(err))
	end
end

--- Claude Code 可转发的命令集合
local claude_forwarded = {
	compact = true, cost = true, clear = true, model = true,
	memory = true, config = true, permissions = true, doctor = true,
	review = true, init = true, help = true, bug = true,
	login = true, logout = true,
}

--- 执行 Chat 级命令
--- @param chat table Chat 实例
--- @param text string 原始输入（含 /）
--- @return boolean handled
function M.handle_chat(chat, text)
	local cmd, _ = M.parse(text)
	if not cmd then return false end
	local handler = chat_commands[cmd]
	if handler then
		handler(chat)
		return true
	end
	-- Claude Code 命令：转发给 client 作为 prompt
	if claude_forwarded[cmd] and chat.client and chat.client.alive then
		chat:_append_system("→ 转发 Claude Code 命令: /" .. cmd)
		chat:send(text)
		return true
	end
	chat:_append_system("未知命令: /" .. cmd)
	return true
end

-- ============================================================================
-- 频道级命令（作用于 Channel）
-- ============================================================================

local channel_commands = {}

channel_commands.add = function(channel, args)
	local parts = vim.split(vim.trim(args), "%s+")
	local input = parts[1] or ""
	local name = parts[2]
	local adapter
	-- 无参数：默认 claude
	if input == "" then
		adapter = "claude"
	else
		local adapter_list = require("acp.adapter").list()
		if vim.tbl_contains(adapter_list, input) then
			-- 精确匹配 adapter 名
			adapter = input
		else
			-- 尝试拆分 "adapter-xxx"，如 "claude-2" → adapter=claude, name=claude-2
			local base = input:match("^(.+)%-")
			if base and vim.tbl_contains(adapter_list, base) then
				adapter = base
				name = name or input
			else
				-- 都不匹配：当作 agent 名，adapter 默认 claude
				adapter = "claude"
				name = input
			end
		end
	end
	if not name or name == "" then
		name = next_agent_name(channel, adapter)
	end
	channel:add_agent(name, adapter)
end

channel_commands.stop = function(channel, args)
	local name = vim.trim(args)
	if name == "" then
		channel:post("系统", "/stop <agent_name>", { no_route = true })
		return
	end
	local acp = require("acp")
	local ok, err = acp.bus_leave(name)
	if not ok then
		channel:post("系统", "停止失败: " .. tostring(err), { no_route = true })
	end
end

channel_commands.list = function(channel)
	local agents = channel:list_agents()
	if #agents == 0 then
		channel:post("系统", "无 agent", { no_route = true })
		return
	end
	local lines = {}
	for _, a in ipairs(agents) do
		lines[#lines + 1] = string.format("  %s  [%s]  %s", a.name, a.kind, a.status)
	end
	channel:post("系统", table.concat(lines, "\n"), { no_route = true })
end

channel_commands.open = function(channel, args, view)
	local name = vim.trim(args)
	if name == "" then
		channel:post("系统", "/open <agent_name>", { no_route = true })
		return
	end
	if view then
		view:open_agent_buf(name)
	end
end

channel_commands.pick = function(channel)
	if not channel then
		return
	end
	require("acp.picker").open()
end

--- 执行频道级命令
--- @param channel table Channel 实例
--- @param text string 原始输入（含 /）
--- @param view? table ChannelView 实例（/open 需要）
--- @return boolean handled
function M.handle_channel(channel, text, view)
	local cmd, args = M.parse(text)
	if not cmd then return false end
	local handler = channel_commands[cmd]
	if handler then
		handler(channel, args or "", view)
		return true
	end
	-- 未知命令：拦截并提示，避免当普通消息发出
	local known = {}
	for k in pairs(channel_commands) do
		known[#known + 1] = "/" .. k
	end
	table.sort(known)
	channel:post("系统", "未知命令: /" .. cmd .. "。可用: " .. table.concat(known, " "), { no_route = true })
	return true
end

return M
