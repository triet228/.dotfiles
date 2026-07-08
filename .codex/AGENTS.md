- "commit": If previous task fails or needs external help, stop. Do not commit temp files. Otherwise, do git add . && git commit -m "<message>" && git push. <message> is specify with "commit <message>". Otherwise, summarize in less than 8 words.

- "git clean" means: git clean -xfd -e AGENTS.md

- Do not use type annotations (e.g., def add(x: int, y: int) -> int). Remove them if they already exist.

- "docs" means: understands the repo, check if doccumentation need any update or change, implement them.

- "restore ...", "get rid of ...", and "rename ... to ..." implicitly imply to fix path dependency for other files if needed

- "notify" means: send a short phone notification summarizing what was done using curl (for linux) and curl.exe (for window) -fsS -H "Title: Codex finished" -d "<1 sentence summary of what was done>" https://ntfy.sh/triet-codex-9f3a7b2c

- Before running `python ...`, remove old generated output/log/result files if they cause duplicate or stale output.

- Use `.gitkeep` for empty directories; remove `.gitkeep` it once the directory contains git tracked files.

- 1st line in python file, .env.example should be comment show file path from project root. Example: ~/Projects/ASTRA/astra/main.py => # astra/main.py  2nd line is empty,

- FAST means Future Aircraft Sizing Tool (FAST) by The IDEAS Lab in the Aerospace Engineering Department at the University of Michigan

-  "comment" means: look over all comments in the code and fix the very very very obvious wrong comments. Add clear functional comments and docstrings explaining purpose, inputs, outputs, assumptions, units, side effects, and non-obvious implementation decisions; explain why, not what. Do not commit.

- "dir" means: show full directory hierarchy

- Don't edit code until I tell u to do so

- Use conda env match with the project name but in lower case (example: FINCH use conda env finch with conda run -n finch python ..., ASTRA use astra with conda run -n astra python ...). 

- Do not do bulk test unless I tell you


- Do not have file path comment on first line for files that are not Python.

