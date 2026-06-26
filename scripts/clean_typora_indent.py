#!/usr/bin/env python3
"""Clean Typora indentation artifacts from content/docs Markdown.

Hugo/Goldmark renders leading-TAB (or full-width-space) prose lines as indented
code blocks. This strips that leading whitespace ONLY for prose/blank lines that
sit OUTSIDE fenced code blocks (``` / ~~~) and OUTSIDE block math ($$ … $$),
leaving real code/list/math indentation intact.

Usage: python scripts/clean_typora_indent.py [--apply]
Without --apply it does a dry run and only reports.
"""
import glob
import os
import re
import sys

APPLY = "--apply" in sys.argv

LIST_RE = re.compile(r"(?:[-*+] |\d+[.)]\s)")


def is_structural(body: str) -> bool:
    """True if the de-indented line is a markdown block we must not dedent."""
    if body.startswith("#"):  # heading
        return True
    if body.startswith("|"):  # table row
        return True
    if body.startswith(">"):  # blockquote
        return True
    if LIST_RE.match(body):  # list item (indent may be meaningful nesting)
        return True
    return False


def clean(text: str):
    out = []
    in_fence = False
    in_math = False
    changed = 0
    for line in text.split("\n"):
        stripped = line.lstrip()
        # toggle fenced code blocks
        if stripped.startswith("```") or stripped.startswith("~~~"):
            in_fence = not in_fence
            out.append(line)
            continue
        # toggle block math ($$ on its own line)
        if not in_fence and stripped.startswith("$$"):
            # a line that is exactly $$ (open/close) toggles; $$...$$ on one line is inline
            if stripped == "$$":
                in_math = not in_math
            out.append(line)
            continue
        if in_fence or in_math:
            out.append(line)
            continue
        # remove zero-width spaces anywhere in prose
        new = line.replace("​", "")
        # dedent leading tabs / full-width spaces on prose & blank lines only
        if new and new[0] in ("\t", "　"):
            body = new.lstrip("\t　 ")
            if body == "" or not is_structural(body):
                new = body if body == "" else new.lstrip("\t　")
        if new != line:
            changed += 1
        out.append(new)
    return "\n".join(out), changed


def main():
    total_files = 0
    total_lines = 0
    touched = []
    for f in glob.glob("content/docs/**/*.md", recursive=True):
        src = open(f, encoding="utf-8").read()
        new, changed = clean(src)
        if changed:
            total_files += 1
            total_lines += changed
            touched.append((f, changed))
            if APPLY:
                open(f, "w", encoding="utf-8", newline="\n").write(new)
    mode = "APPLIED" if APPLY else "DRY-RUN"
    print(f"[{mode}] files changed: {total_files}, lines changed: {total_lines}")
    for f, c in sorted(touched, key=lambda x: -x[1])[:20]:
        print(f"  {c:4d}  {f}")


if __name__ == "__main__":
    main()
