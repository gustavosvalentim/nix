#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${1:-.}"

if [ ! -d "$REPO_ROOT" ]; then
  echo "ERROR: repo path does not exist: $REPO_ROOT" >&2
  exit 1
fi

cd "$REPO_ROOT"

emit() {
  local tool="$1"
  local check_type="$2"
  local command="$3"
  printf '%s|%s|%s\n' "$tool" "$check_type" "$command"
}

target_exists_in_makefile() {
  local makefile_path="$1"
  local target="$2"
  grep -Eq "^[[:space:]]*${target}[[:space:]]*:" "$makefile_path" \
    || grep -Eq "^[[:space:]]*\\.PHONY:[[:space:]].*([[:space:]]|^)${target}([[:space:]]|$)" "$makefile_path"
}

MAKEFILE_PATH=""
for candidate in Makefile makefile GNUmakefile; do
  if [ -f "$candidate" ]; then
    MAKEFILE_PATH="$candidate"
    break
  fi
done

if [ -n "$MAKEFILE_PATH" ]; then
  if target_exists_in_makefile "$MAKEFILE_PATH" "test"; then
    emit "make" "test" "make test"
  fi
  if target_exists_in_makefile "$MAKEFILE_PATH" "lint"; then
    emit "make" "lint" "make lint"
  fi
fi

if [ -f "go.mod" ]; then
  emit "go" "test" "go test ./..."
fi

if [ -f "package.json" ]; then
  PACKAGE_MANAGER="npm"
  if [ -f "pnpm-lock.yaml" ]; then
    PACKAGE_MANAGER="pnpm"
  elif [ -f "yarn.lock" ]; then
    PACKAGE_MANAGER="yarn"
  elif [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
    PACKAGE_MANAGER="bun"
  elif [ -f "package-lock.json" ] || [ -f "npm-shrinkwrap.json" ]; then
    PACKAGE_MANAGER="npm"
  fi

  if grep -Eq '"test"[[:space:]]*:' "package.json"; then
    case "$PACKAGE_MANAGER" in
      yarn) emit "yarn" "test" "yarn test" ;;
      bun) emit "bun" "test" "bun test" ;;
      *) emit "$PACKAGE_MANAGER" "test" "$PACKAGE_MANAGER test" ;;
    esac
  fi

  if grep -Eq '"lint"[[:space:]]*:' "package.json"; then
    case "$PACKAGE_MANAGER" in
      yarn) emit "yarn" "lint" "yarn lint" ;;
      bun) emit "bun" "lint" "bun run lint" ;;
      *) emit "$PACKAGE_MANAGER" "lint" "$PACKAGE_MANAGER run lint" ;;
    esac
  fi
fi

if [ -f "pyproject.toml" ] || [ -f "pytest.ini" ] || [ -f "setup.py" ] || [ -f "setup.cfg" ] || [ -f "requirements.txt" ] || [ -d "tests" ]; then
  if command -v pytest >/dev/null 2>&1; then
    emit "python" "test" "pytest"
  elif command -v python3 >/dev/null 2>&1; then
    if python3 -c 'import importlib.util, sys; sys.exit(0 if importlib.util.find_spec("pytest") else 1)' >/dev/null 2>&1; then
      emit "python" "test" "python3 -m pytest"
    fi
  fi
fi
