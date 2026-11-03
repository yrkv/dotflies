#!/usr/bin/env python3
import argparse
import io
import json
import os
import subprocess
import sys

# ANSI escape codes for terminal styling
C_RESET = "\033[0m"
C_BOLD = "\033[1m"
C_DIM = "\033[2m"
C_CYAN = "\033[36m"
C_GREEN = "\033[32m"
C_YELLOW = "\033[33m"
C_RED = "\033[31m"
C_MAGENTA = "\033[35m"


def detect_language(nb: dict, kind: str) -> str:
    """Resolve the appropriate bat syntax language for a cell."""
    if kind == "markdown":
        return "markdown"
    if kind != "code":
        return "text"

    meta = nb.get("metadata", {})
    lang = (
        meta.get("kernelspec", {}).get("language")
        or meta.get("language_info", {}).get("name")
        or meta.get("language_info", {}).get("file_extension", ".py")
    )
    if lang == ".py":
        return "python"
    if lang.startswith("."):
        return lang[1:]
    return lang or "python"


def highlight_with_bat(source: str, lang: str, show_lines: bool) -> str:
    """Syntax-highlight cell source using bat, falling back to plain text."""
    style = "numbers" if show_lines else "plain"
    try:
        res = subprocess.run(
            [
                "bat",
                "--color=always",
                f"--style={style}",
                "--paging=never",
                "--language",
                lang,
            ],
            input=source,
            text=True,
            capture_output=True,
            check=False,
        )
        if res.returncode == 0:
            return res.stdout
    except FileNotFoundError:
        pass

    # Fallback if bat is not installed or fails
    if show_lines:
        lines = source.splitlines()
        return "\n".join(f"{C_DIM}{i:4d}{C_RESET}  {line}" for i, line in enumerate(lines, 1)) + "\n"
    return source if source.endswith("\n") else source + "\n"


def format_output_block(label: str, color: str, content: str, max_lines: int) -> str:
    """Format cell output with a left gutter border and automatic line truncation."""
    lines = content.rstrip("\n").splitlines()
    if not lines:
        return ""

    total = len(lines)
    truncated = 0
    if max_lines > 0 and total > max_lines:
        lines = lines[:max_lines]
        truncated = total - max_lines

    out = [f"  {color}╭─ [{label}]{C_RESET}"]
    for line in lines:
        out.append(f"  {color}│{C_RESET} {line}")

    if truncated > 0:
        out.append(
            f"  {color}╰─{C_RESET} {C_DIM}... ({truncated} more lines truncated; "
            f"use --max-output-lines 0 to show all){C_RESET}\n"
        )
    else:
        out.append(f"  {color}╰──────────{C_RESET}\n")

    return "\n".join(out)


def render_outputs(outputs: list, max_lines: int) -> str:
    """Extract and style stream, result, display, and error outputs from a code cell."""
    chunks = []
    for output in outputs:
        otype = output.get("output_type", "")

        if otype == "stream":
            name = output.get("name", "stdout")
            text = output.get("text", "")
            if isinstance(text, list):
                text = "".join(text)
            color = C_RED if name == "stderr" else C_DIM
            chunks.append(format_output_block(name, color, text, max_lines))

        elif otype in ("execute_result", "display_data"):
            data = output.get("data", {})
            rendered = data.get("text/plain") or data.get("text/markdown") or ""
            if isinstance(rendered, list):
                rendered = "".join(rendered)

            # Note non-text rich outputs (e.g., images)
            rich_types = [k for k in data.keys() if k.startswith("image/")]
            if rich_types and not rendered:
                rendered = f"<{', '.join(rich_types)} output omitted in terminal>"

            exec_count = output.get("execution_count")
            label = f"Out[{exec_count}]" if exec_count is not None else "display"
            if rendered:
                chunks.append(format_output_block(label, C_YELLOW, rendered, max_lines))

        elif otype == "error":
            tb = output.get("traceback", [])
            if tb:
                text = "\n".join(tb)
            else:
                ename = output.get("ename", "Error")
                evalue = output.get("evalue", "")
                text = f"{ename}: {evalue}"
            chunks.append(format_output_block("error", C_RED, text, max_lines))

    return "\n".join(filter(None, chunks))


def main():
    parser = argparse.ArgumentParser(
        description="Browse Jupyter notebooks in your terminal with bat and less."
    )
    parser.add_argument("file", help="Path to the .ipynb notebook file")
    parser.add_argument(
        "-o", "--outputs", action="store_true", help="Show code cell execution outputs"
    )
    parser.add_argument(
        "-n", "--line-numbers", action="store_true", help="Show line numbers inside cells"
    )
    parser.add_argument(
        "--max-output-lines",
        type=int,
        default=30,
        help="Maximum lines per output block before truncating (0 for unlimited, default: 30)",
    )
    args = parser.parse_args()

    if not os.path.isfile(args.file):
        print(f"Not found: {args.file}", file=sys.stderr)
        sys.exit(1)

    try:
        with open(args.file, "r", encoding="utf-8") as f:
            nb = json.load(f)
    except Exception as e:
        print(f"Error reading or parsing notebook: {e}", file=sys.stderr)
        sys.exit(1)

    buf = io.StringIO()
    cells = nb.get("cells", [])

    # Notebook banner
    buf.write(
        f"{C_BOLD}📓 {os.path.basename(args.file)}{C_RESET} "
        f"{C_DIM}({len(cells)} cells · search '/\\[Cell' in less to navigate){C_RESET}\n"
    )

    for i, cell in enumerate(cells, 1):
        kind = cell.get("cell_type", "raw")
        source = cell.get("source", "")
        if isinstance(source, list):
            source = "".join(source)

        lang = detect_language(nb, kind)

        # Build Navigation Anchor Header: e.g., [Cell 1/Code] In[4]
        kind_label = kind.capitalize()
        color = C_CYAN if kind == "code" else (C_GREEN if kind == "markdown" else C_MAGENTA)

        exec_str = ""
        if kind == "code":
            exec_count = cell.get("execution_count")
            exec_label = str(exec_count) if exec_count is not None else " "
            exec_str = f" {C_DIM}In[{exec_label}]{C_RESET}"

        anchor = f"[Cell {i}/{kind_label}]"
        rule = "─" * max(4, 52 - len(anchor))
        buf.write(f"\n{color}{C_BOLD}── {anchor}{C_RESET}{exec_str} {C_DIM}{rule}{C_RESET}\n")

        # Highlight cell source
        if source.strip():
            highlighted = highlight_with_bat(source, lang, args.line_numbers)
            buf.write(highlighted)
            if not highlighted.endswith("\n"):
                buf.write("\n")
        else:
            buf.write(f"{C_DIM}  <empty cell>{C_RESET}\n")

        # Render outputs if enabled
        if args.outputs and kind == "code":
            out_block = render_outputs(cell.get("outputs", []), args.max_output_lines)
            if out_block:
                buf.write("\n" + out_block)

    content = buf.getvalue()

    # In-Memory Paging directly into less -R
    try:
        proc = subprocess.Popen(["less", "-R"], stdin=subprocess.PIPE, text=True)
        proc.communicate(input=content)
        sys.exit(proc.returncode)
    except FileNotFoundError:
        # Fallback if less is unavailable
        sys.stdout.write(content)
    except KeyboardInterrupt:
        sys.exit(130)


if __name__ == "__main__":
    main()

