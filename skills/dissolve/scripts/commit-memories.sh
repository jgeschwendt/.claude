#!/usr/bin/env bash
# commit-memories.sh — deterministically commit dissolved memories into ~/.claude/@memory
# banks, mirroring the dashboard's commit path (@apps/web/lib/core/memory.ex:
# slug/1, commit_file_name/2, serialize_memory/1, commit_memory/1, regen_index/1,
# read_staging/write_staging). On drift, the app code wins — re-derive from it.
# ✻ 2026-07-12 contract: replaced files ARCHIVE to <bank>/_archive/<stamp>_<file> (never rm);
#   frontmatter carries bi-temporal created (inherited from the oldest replaced file) and
#   updated (now). memory.ex's collision check is fixed — both sides suffix _2, _3, ….
# ✻ app-only divergence: memory.ex caps MEMORY.md at 180 entries (+ overflow line); this
#   script writes all entries — irrelevant until a bank nears 180 memories.
#
# Usage: commit-memories.sh <manifest.json>
#
# Manifest:
#   {
#     "source": "<session id or omit>",
#     "commit": [{"bank","name","description","type","body","replaces":["file.md",…]}],
#     "drop":   [{"bank","name"}]           // judge-dropped: drained from staging only
#   }
#
# Does, per committed memory: slug → collision-safe filename → archive replaces → write file
# → then per bank: regen MEMORY.md → drain .staging.json of committed+dropped → self-verify.
# Prints a report; exit 0 only if every check passes. CLAUDE_MEMORY_ROOT overridable for tests.
set -u
export LC_ALL=C # byte-order sort/collation, matching Elixir's Enum.sort

MANIFEST="${1:?usage: commit-memories.sh <manifest.json>}"
ROOT="${CLAUDE_MEMORY_ROOT:-$HOME/.claude/@memory}"
STAGING="$ROOT/.staging.json"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
FAIL=0

err() { echo "  ✗ $*"; FAIL=1; }

jq empty "$MANIFEST" 2>/dev/null || { echo "FAIL: manifest is not valid JSON"; exit 1; }

# ─── helpers (mirror memory.ex) ─────────────────────────────────────────────────
slugify() { # slug/1: downcase → [^a-z0-9]+ → _ → trim _ → first 60; empty → x+sha1[0:8]
  local s
  s=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/_/g' \
      | sed -E 's/^_+//; s/_+$//' | cut -c1-60)
  [ -n "$s" ] && printf '%s' "$s" || printf 'x%s' "$(printf '%s' "$1" | shasum | cut -c1-8)"
}

fm_field() { # $1=file $2=key — frontmatter value, quotes stripped (parse_fm/1)
  awk -v key="$2" '
    NR==1 && $0=="---" {fm=1; next}
    fm==1 && $0=="---" {exit}
    fm==1 && $0 ~ "^[ \t]*"key":" {
      sub("^[ \t]*"key":[ \t]*",""); gsub(/^["'\'']|["'\'']$/,""); print; exit
    }' "$1"
}

parsed_name() { # parse_memory/1: fm name → first H1 → basename sans .md
  local n
  n=$(fm_field "$1" name)
  [ -n "$n" ] && { printf '%s' "$n"; return; }
  n=$(awk 'NR==1 && $0=="---" {fm=1; next} fm==1 && $0=="---" {fm=2; next} fm!=1 && /^# / {sub(/^# +/,""); print; exit}' "$1")
  [ -n "$n" ] && printf '%s' "$n" || printf '%s' "$(basename "$1" .md)"
}

component_ok() { # component?/1: single safe path segment
  case "$1" in ''|*/*|*..*|.*|_*) return 1 ;; esac
  return 0
}

bank_ok() { # writable?/1 + skill rules: no auto:, no hidden/underscore, safe segment
  case "$1" in ''|auto:*|.*|_*|*/*|*..*) return 1 ;; esac
  return 0
}

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)" # DateTime.utc_now |> truncate(:second) |> to_iso8601
STAMP="$(date -u +%Y%m%dT%H%M%S)"    # archive_file/2 stamp

archive_replace() { # archive_file/2: move into <bank>/_archive/<stamp>_<file> — never rm
  local dir="$1" f="$2"
  [ -e "$dir/$f" ] || return 0
  mkdir -p "$dir/_archive"
  mv "$dir/$f" "$dir/_archive/${STAMP}_$f"
}

regen_index() { # regen_index/1: fixed header + one line per memory file, sorted
  local dir="$1" f name desc
  {
    printf -- '---\nname: MEMORY index\ndescription: One-line map of all durable memories in this knowledge bank\ntype: reference\n---\n\n'
    ls "$dir" 2>/dev/null | sort | while IFS= read -r f; do
      case "$f" in *.md) ;; *) continue ;; esac
      case "$f" in MEMORY.md|_*) continue ;; esac
      name=$(parsed_name "$dir/$f")
      desc=$(fm_field "$dir/$f" description | tr '\t' ' ' | sed -E 's/[[:space:]]+/ /g' | cut -c1-150)
      printf -- '- [%s](%s) — %s\n' "$name" "$f" "$desc"
    done
  } > "$dir/MEMORY.md"
}

# ─── commit each memory ─────────────────────────────────────────────────────────
: > "$TMP/committed.tsv"   # bank \t file \t name
: > "$TMP/replaced.tsv"    # bank \t file
: > "$TMP/banks"
default_source=$(jq -r '.source // ""' "$MANIFEST")

n=$(jq '.commit | length' "$MANIFEST")
i=0
while [ "$i" -lt "$n" ]; do
  bank=$(jq -r ".commit[$i].bank // \"\"" "$MANIFEST")
  name=$(jq -r ".commit[$i].name // \"\"" "$MANIFEST")
  type=$(jq -r ".commit[$i].type // \"\"" "$MANIFEST")
  desc=$(jq -r ".commit[$i].description // \"\" | gsub(\"\\\\s+\"; \" \")" "$MANIFEST")
  body=$(jq -r ".commit[$i].body // \"\" | sub(\"^\\\\s+\"; \"\") | sub(\"\\\\s+$\"; \"\")" "$MANIFEST")
  source=$(jq -r ".commit[$i].source // \"\"" "$MANIFEST")
  [ -n "$source" ] || source="$default_source"
  created=$(jq -r ".commit[$i].created // \"\"" "$MANIFEST")

  if ! bank_ok "$bank"; then err "commit[$i] '$name': illegal bank '$bank'"; i=$((i+1)); continue; fi
  if [ -z "$name" ]; then err "commit[$i]: empty name"; i=$((i+1)); continue; fi
  case "$type" in feedback|project|reference|user) ;; *) err "commit[$i] '$name': illegal type '$type'"; i=$((i+1)); continue ;; esac

  dir="$ROOT/$bank"
  mkdir -p "$dir"
  base="${type}_$(slugify "$name").md"

  # archive replaces first (commit_memory/1 order), plain components only; inherit the
  # oldest replaced file's `created` so lineage survives supersedes (bi-temporal);
  # a manifest-supplied `created` wins, mirroring memory.ex's `f[:created] ||`
  inherited=""
  for r in $(jq -r ".commit[$i].replaces // [] | .[]" "$MANIFEST"); do
    if component_ok "$r"; then
      if [ -e "$dir/$r" ]; then
        rc=$(fm_field "$dir/$r" created)
        if [ -n "$rc" ] && { [ -z "$inherited" ] || [ "$rc" \< "$inherited" ]; }; then inherited="$rc"; fi
        archive_replace "$dir" "$r"
      fi
      printf '%s\t%s\n' "$bank" "$r" >> "$TMP/replaced.tsv"
    else
      err "commit[$i] '$name': unsafe replaces entry '$r' skipped"
    fi
  done
  [ -n "$created" ] || created="${inherited:-$NOW}"

  # collision-safe filename: same parsed name → overwrite; different memory → suffix
  file="$base"
  if [ -e "$dir/$file" ] && [ "$(parsed_name "$dir/$file")" != "$name" ]; then
    k=2
    while :; do
      file="${type}_$(slugify "$name")_${k}.md"
      { [ ! -e "$dir/$file" ] || [ "$(parsed_name "$dir/$file")" = "$name" ]; } && break
      k=$((k+1))
    done
  fi

  { # serialize_memory/1 — field order: name, description, type, created, source, updated
    printf -- '---\nname: %s\ndescription: %s\ntype: %s\n' "$name" "$desc" "$type"
    printf -- 'created: %s\n' "$created"
    [ -n "$source" ] && printf -- 'source: %s\n' "$source"
    printf -- 'updated: %s\n' "$NOW"
    printf -- '---\n\n%s\n' "$body"
  } > "$dir/$file"

  printf '%s\t%s\t%s\n' "$bank" "$file" "$name" >> "$TMP/committed.tsv"
  grep -qxF -- "$bank" "$TMP/banks" || echo "$bank" >> "$TMP/banks"
  i=$((i+1))
done

# ─── regen index per touched bank ───────────────────────────────────────────────
while IFS= read -r bank; do
  [ -n "$bank" ] && regen_index "$ROOT/$bank"
done < "$TMP/banks"

# ─── drain staging of committed + dropped ───────────────────────────────────────
jq '[.commit[]?, .drop[]? | {bank, name}]' "$MANIFEST" > "$TMP/rm.json"
if [ -f "$STAGING" ] && jq -e 'type == "array"' "$STAGING" >/dev/null 2>&1; then
  jq --slurpfile rm "$TMP/rm.json" \
     'map(select(. as $m | ($rm[0] | map(.bank == $m.bank and .name == $m.name) | any) | not))' \
     "$STAGING" > "$TMP/staging.json" && mv "$TMP/staging.json" "$STAGING"
elif [ -f "$STAGING" ]; then
  err "staging file exists but is not a JSON array — left untouched"
fi

# ─── self-verify (replaces the LLM auditor) ─────────────────────────────────────
while IFS=$'\t' read -r bank file name; do
  [ -n "$bank" ] || continue
  p="$ROOT/$bank/$file"
  if [ ! -f "$p" ]; then err "missing committed file: $bank/$file"; continue; fi
  [ "$(head -1 "$p")" = "---" ] || err "$bank/$file: no frontmatter"
  [ "$(fm_field "$p" name)" = "$name" ] || err "$bank/$file: name mismatch"
  case "$(fm_field "$p" type)" in feedback|project|reference|user) ;; *) err "$bank/$file: illegal type" ;; esac
  grep -qF "($file)" "$ROOT/$bank/MEMORY.md" 2>/dev/null || err "$bank/$file: not listed in MEMORY.md"
done < "$TMP/committed.tsv"

while IFS=$'\t' read -r bank file; do
  [ -n "$bank" ] || continue
  grep -qF -- "$(printf '%s\t%s\t' "$bank" "$file")" "$TMP/committed.tsv" 2>/dev/null && continue # re-used name
  [ -e "$ROOT/$bank/$file" ] && err "replaced file still present: $bank/$file"
done < "$TMP/replaced.tsv"

while IFS= read -r bank; do
  [ -n "$bank" ] || continue
  d="$ROOT/$bank"
  listed=$(grep -c '^- \[' "$d/MEMORY.md" 2>/dev/null || echo 0)
  actual=$(ls "$d" 2>/dev/null | grep -c '^[^_].*\.md$' | tr -d ' ')
  actual=$((actual - 1)) # MEMORY.md itself
  [ "$listed" = "$actual" ] || err "$bank/MEMORY.md lists $listed files, bank has $actual"
done < "$TMP/banks"

[ -f "$STAGING" ] && ! jq empty "$STAGING" 2>/dev/null && err ".staging.json is not valid JSON"

committed=$(grep -c . "$TMP/committed.tsv" | tr -d ' ')
residual=0
[ -f "$STAGING" ] && residual=$(jq 'length' "$STAGING" 2>/dev/null || echo '?')
if [ "$FAIL" = 0 ]; then
  echo "PASS: committed=$committed banks=$(sort -u "$TMP/banks" | grep -c . | tr -d ' ') staging-residual=$residual"
else
  echo "FAIL: see ✗ lines above (committed=$committed)"
  exit 1
fi
