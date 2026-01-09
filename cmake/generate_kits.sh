#!/bin/bash

# 脚本的目标是扫描系统中的编译器并生成一个全局的 cmake-kits.json 文件

# 定义输出文件的路径
OUTPUT_FILE="$HOME/.config/nvim/cmake/cmake-kits.json"

echo "🔍 Starting compiler scan..."

# 初始化一个空的 JSON 数组
JSON_ARRAY="[]"

# --- 1. 检查 GCC ---
if command -v gcc &>/dev/null; then
  echo "  -> Found GCC..."
  # 获取编译器路径
  GCC_PATH=$(command -v gcc)
  GXX_PATH=$(command -v g++)
  # 获取版本信息用于命名
  GCC_VERSION=$($GCC_PATH --version | head -n 1)

  # 使用 jq 来安全地构建 JSON 对象并添加到数组中
  JSON_ARRAY=$(echo "$JSON_ARRAY" | jq \
    --arg name "$GCC_VERSION (Global)" \
    --arg c_compiler "$GCC_PATH" \
    --arg cxx_compiler "$GXX_PATH" \
    '. += [{ "name": $name, "compilers": { "C": $c_compiler, "CXX": $cxx_compiler } }]')
else
  echo "  -> GCC not found."
fi

# --- 2. 检查 Clang ---
if command -v clang &>/dev/null; then
  echo "  -> Found Clang..."
  # 获取编译器路径
  CLANG_PATH=$(command -v clang)
  CLANGXX_PATH=$(command -v clang++)
  # 获取版本信息用于命名
  CLANG_VERSION=$($CLANG_PATH --version | head -n 1)

  # 使用 jq 将 Clang 信息添加到数组中
  JSON_ARRAY=$(echo "$JSON_ARRAY" | jq \
    --arg name "$CLANG_VERSION (Global)" \
    --arg c_compiler "$CLANG_PATH" \
    --arg cxx_compiler "$CLANGXX_PATH" \
    '. += [{ "name": $name, "compilers": { "C": $c_compiler, "CXX": $cxx_compiler } }]')
else
  echo "  -> Clang not found."
fi

# --- 3. 写入最终文件 ---
# 使用 jq 的 pretty print 功能输出格式化的 JSON
echo "$JSON_ARRAY" | jq '.' >"$OUTPUT_FILE"

echo "✅ Global cmake-kits.json has been successfully generated at:"
echo "   $OUTPUT_FILE"
