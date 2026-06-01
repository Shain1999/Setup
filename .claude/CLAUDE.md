# CLAUDE.md

> Project overview goes here — one line on what this repo does.

## Commands

```bash
mise install            # install pinned toolchain (python + uv)
uv sync                 # install dependencies into .venv
uv run ruff check .     # lint
uv run ruff format .    # format
uv run pytest           # tests
```

## Conventions

- Python pinned via `.mise.toml`; always invoke through `uv run`.
- Never read or commit `.env` files — they hold secrets.
- Keep comments about *why*, not *what*.
