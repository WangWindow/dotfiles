import json
import csv
import io
from pathlib import Path
from typing import Any
from dataclasses import dataclass, field
from collections import OrderedDict

# 配置
TRANSLATION_FILE = "翻译.json"
DATA_DIR = "www/data-jp"
OUTPUT_DIR = "www/data-cn"


@dataclass
class TranslationMatcher:
    """纯 Python 翻译匹配器：Trie 最长匹配 + 简单 LRU 缓存。

    - trie: 前缀树，按字符逐步匹配，避免每个位置遍历大量 key。
    - cache: 限制大小的 LRU，提升重复文本/重复行的翻译速度。
    """

    trie: dict
    cache_max: int = 50_000
    cache: "OrderedDict[str, str]" = field(default_factory=OrderedDict)

    def cache_get(self, key: str) -> str | None:
        val = self.cache.get(key)
        if val is not None:
            self.cache.move_to_end(key)
        return val

    def cache_put(self, key: str, val: str) -> None:
        self.cache[key] = val
        self.cache.move_to_end(key)
        if len(self.cache) > self.cache_max:
            self.cache.popitem(last=False)


def read_text_file(file_path):
    """Read file bytes and decode using common encodings; handle BOM (utf-8-sig)."""
    raw = Path(file_path).read_bytes()
    for enc in ("utf-8-sig", "utf-8", "cp932", "shift_jis", "latin-1"):
        try:
            return raw.decode(enc)
        except Exception:
            continue
    return raw.decode("utf-8", errors="replace")


def load_translation(file_path):
    """加载翻译JSON文件。自动检测并处理 BOM/编码。"""
    print(f"加载翻译文件: {file_path}")
    try:
        text = read_text_file(file_path)
        return json.loads(text)
    except Exception as e:
        print(f"加载翻译文件出错: {e}")
        return {}


def build_lookup_table(translation_map) -> TranslationMatcher:
    """构建匹配器（Trie + LRU），用于大文件的高速替换。"""
    print("正在构建查找表(Trie)...")

    trie: dict = {}
    terminal = "\0"  # 作为终止标记；正常文本中几乎不会出现

    for key, value in translation_map.items():
        if not key:
            continue

        node = trie
        for ch in key:
            node = node.setdefault(ch, {})
        node[terminal] = value

    # 把 terminal 标记也塞进 matcher 里（避免全局变量/闭包开销）
    matcher = TranslationMatcher(trie={"_root": trie, "_terminal": terminal})
    return matcher


def translate_text(text, lookup_table: TranslationMatcher):
    """
    使用查找表翻译文本。
    替换文本中出现的所有key。
    """
    if not isinstance(text, str):
        return text

    # LRU 命中直接返回
    cached = lookup_table.cache_get(text)
    if cached is not None:
        return cached

    # 尝试解析嵌套的JSON字符串 (针对插件参数)
    try:
        stripped = text.strip()
        if stripped.startswith("{") or stripped.startswith("["):
            parsed = json.loads(text)
            if isinstance(parsed, (dict, list)):

                def recursive_helper(obj):
                    if isinstance(obj, dict):
                        return {k: recursive_helper(v) for k, v in obj.items()}
                    elif isinstance(obj, list):
                        return [recursive_helper(v) for v in obj]
                    elif isinstance(obj, str):
                        return translate_text(obj, lookup_table)
                    else:
                        return obj

                translated_parsed = recursive_helper(parsed)
                return json.dumps(
                    translated_parsed, ensure_ascii=False, separators=(",", ":")
                )
    except Exception:
        pass

    root = lookup_table.trie["_root"]
    terminal = lookup_table.trie["_terminal"]

    result: list[str] = []
    i = 0
    n = len(text)

    while i < n:
        node = root
        j = i
        last_val: str | None = None
        last_j = i

        # Trie 向前走，记录“最长的终止匹配”
        while j < n:
            ch = text[j]
            nxt = node.get(ch)
            if nxt is None:
                break
            node = nxt
            j += 1
            val = node.get(terminal)
            if val is not None:
                last_val = val
                last_j = j

        if last_val is not None:
            result.append(last_val)
            i = last_j
        else:
            result.append(text[i])
            i += 1

    translated = "".join(result)
    lookup_table.cache_put(text, translated)
    return translated


def _is_event_command_dict(obj: Any) -> bool:
    return (
        isinstance(obj, dict)
        and "code" in obj
        and "indent" in obj
        and "parameters" in obj
        and isinstance(obj.get("code"), int)
        and isinstance(obj.get("indent"), int)
        and isinstance(obj.get("parameters"), list)
    )


def _process_event_command_list(commands: list[dict], lookup_table) -> list[dict]:
    """对RPG Maker事件命令列表做更贴近引擎的翻译处理。

    关键点：
    - Show Text: code=101 后面会跟若干 code=401 行，这些 401 共同组成一个多行文本。
      翻译表里经常用 "A\nB" 作为一个 key；若逐行翻译就无法命中。
    - Show Scrolling Text: code=105 后面会跟若干 code=405 行，同理。
    """

    def translate_any(value: Any) -> Any:
        if isinstance(value, str):
            return translate_text(value, lookup_table)
        if isinstance(value, list):
            return [translate_any(v) for v in value]
        if isinstance(value, dict):
            return {k: translate_any(v) for k, v in value.items()}
        return value

    out: list[dict] = []
    i = 0

    while i < len(commands):
        cmd = commands[i]
        if not _is_event_command_dict(cmd):
            out.append(cmd)
            i += 1
            continue

        code = cmd["code"]

        # 101: Show Text + 401 continuations
        if code == 101:
            out.append(
                {
                    "code": cmd["code"],
                    "indent": cmd.get("indent", 0),
                    "parameters": translate_any(cmd.get("parameters", [])),
                }
            )
            j = i + 1
            lines: list[str] = []
            indent_for_401 = cmd.get("indent", 0)
            while (
                j < len(commands)
                and _is_event_command_dict(commands[j])
                and commands[j]["code"] == 401
            ):
                if commands[j].get("parameters"):
                    lines.append(commands[j]["parameters"][0])
                else:
                    lines.append("")
                indent_for_401 = commands[j].get("indent", indent_for_401)
                j += 1

            if lines:
                combined = "\n".join(lines)
                translated = translate_text(combined, lookup_table)
                for line in translated.split("\n"):
                    out.append(
                        {"code": 401, "indent": indent_for_401, "parameters": [line]}
                    )

            i = j
            continue

        # 105: Show Scrolling Text + 405 continuations
        if code == 105:
            out.append(
                {
                    "code": cmd["code"],
                    "indent": cmd.get("indent", 0),
                    "parameters": translate_any(cmd.get("parameters", [])),
                }
            )
            j = i + 1
            lines: list[str] = []
            indent_for_405 = cmd.get("indent", 0)
            while (
                j < len(commands)
                and _is_event_command_dict(commands[j])
                and commands[j]["code"] == 405
            ):
                if commands[j].get("parameters"):
                    lines.append(commands[j]["parameters"][0])
                else:
                    lines.append("")
                indent_for_405 = commands[j].get("indent", indent_for_405)
                j += 1

            if lines:
                combined = "\n".join(lines)
                translated = translate_text(combined, lookup_table)
                for line in translated.split("\n"):
                    out.append(
                        {"code": 405, "indent": indent_for_405, "parameters": [line]}
                    )

            i = j
            continue

        # 其它事件命令：沿用旧行为，递归翻译 parameters 中的字符串
        out.append(
            {
                "code": cmd["code"],
                "indent": cmd.get("indent", 0),
                "parameters": translate_any(cmd.get("parameters", [])),
            }
        )
        i += 1

    return out


def process_json_file(file_path, output_path, lookup_table):
    """处理JSON文件。"""
    print(f"处理JSON文件: {file_path} -> {output_path}")
    try:
        text = read_text_file(file_path)
        data = json.loads(text)

        def recursive_translate(obj):
            if isinstance(obj, dict):
                # 事件页 / 公共事件等结构：{ ..., "list": [ {code, indent, parameters}, ... ] }
                if "list" in obj and isinstance(obj.get("list"), list) and obj["list"]:
                    list_val = obj["list"]
                    if all(_is_event_command_dict(x) for x in list_val):
                        new_obj = {
                            k: recursive_translate(v)
                            for k, v in obj.items()
                            if k != "list"
                        }
                        new_obj["list"] = _process_event_command_list(
                            list_val, lookup_table
                        )
                        return new_obj

                return {k: recursive_translate(v) for k, v in obj.items()}
            elif isinstance(obj, list):
                # 兼容某些文件顶层就是事件命令数组
                if obj and all(_is_event_command_dict(x) for x in obj):
                    return _process_event_command_list(obj, lookup_table)
                return [recursive_translate(v) for v in obj]
            elif isinstance(obj, str):
                return translate_text(obj, lookup_table)
            else:
                return obj

        translated_data = recursive_translate(data)

        with open(output_path, "w", encoding="utf-8") as f:
            json.dump(translated_data, f, ensure_ascii=False, indent=4)

    except Exception as e:
        print(f"处理JSON文件出错 {file_path}: {e}")


def process_csv_file(file_path, output_path, lookup_table):
    """处理CSV文件。"""
    print(f"处理CSV文件: {file_path} -> {output_path}")
    try:
        rows = []
        fieldnames = None

        text = read_text_file(file_path)
        f = io.StringIO(text)
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames
        for row in reader:
            rows.append(row)

        if not fieldnames:
            print(f"警告: 未找到字段 {file_path}")
            return

        translated_rows = []
        for row in rows:
            new_row = {}
            for k, v in row.items():
                if k == "Message":
                    new_row[k] = translate_text(v, lookup_table)
                else:
                    new_row[k] = v
            translated_rows.append(new_row)

        with open(output_path, "w", encoding="utf-8", newline="") as f:
            writer = csv.DictWriter(f, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(translated_rows)

    except Exception as e:
        print(f"处理CSV文件出错 {file_path}: {e}")


def main():
    translation_file = Path(TRANSLATION_FILE)
    data_dir = Path(DATA_DIR)
    output_dir = Path(OUTPUT_DIR)

    if not translation_file.exists():
        print(f"未找到翻译文件: {translation_file}")
        return

    translation_map = load_translation(translation_file)
    if not translation_map:
        print("未找到任何翻译内容。")
        return

    lookup_table = build_lookup_table(translation_map)

    for file_path in data_dir.rglob("*"):
        if file_path.is_file():
            # 计算相对路径并构建输出路径
            relative_path = file_path.relative_to(data_dir)
            output_path = output_dir / relative_path

            # 确保输出目录存在
            output_path.parent.mkdir(parents=True, exist_ok=True)

            if file_path.suffix.lower() == ".json":
                process_json_file(file_path, output_path, lookup_table)
            elif file_path.suffix.lower() == ".csv":
                process_csv_file(file_path, output_path, lookup_table)


if __name__ == "__main__":
    main()
