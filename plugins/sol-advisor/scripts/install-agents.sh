#!/bin/sh
# Install Sol Advisor's shipped custom-agent templates without changing Codex config.

set -eu

usage() {
  cat <<'EOF'
Usage: install-agents.sh [--target-dir PATH] [--check]

Install Sol Advisor's eight native custom-agent templates:
- Luna / Low implementation
- Luna / Medium implementation
- Terra / Medium implementation
- Terra / High read-only consultant
- Sol / Low read-only consultant
- Sol / Medium read-only consultant
- Sol / High implementation
- Sol / High final review

The installer never overwrites an unrecognized or modified file. It can safely migrate
only exact recognized older Sol Advisor Luna and Terra implementation templates.

Without --target-dir, the target is "$CODEX_HOME/agents" when CODEX_HOME is set,
otherwise "$HOME/.codex/agents".
EOF
}

fail() { printf '%s\n' "ERROR: $*" >&2; exit 1; }
path_exists() { [ -e "$1" ] || [ -L "$1" ]; }
sha256_file() { shasum -a 256 "$1" 2>/dev/null | awk 'NF >= 1 { print $1; exit }'; }

script_dir=$(CDPATH= cd "$(dirname "$0")" && pwd) || exit 1
template_dir=$script_dir/../agents

if [ -n "${CODEX_HOME-}" ]; then
  target_dir=$CODEX_HOME/agents
else
  [ -n "${HOME-}" ] || fail "HOME is unset and CODEX_HOME was not supplied; pass --target-dir."
  target_dir=$HOME/.codex/agents
fi

check_only=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --target-dir)
      [ "$#" -ge 2 ] || fail "--target-dir requires a path"
      target_dir=$2
      shift 2
      ;;
    --check) check_only=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) fail "unknown argument: $1" ;;
  esac
done

case "$target_dir" in
  /*) ;;
  *) target_dir=$(pwd -P)/$target_dir ;;
esac
[ "$target_dir" != "/" ] || fail "refusing to use filesystem root"

luna_low_file=sol-advisor-luna-low-implementer.toml
luna_file=sol-advisor-luna-implementer.toml
terra_file=sol-advisor-terra-implementer.toml
terra_high_consultant_file=sol-advisor-terra-high-consultant.toml
sol_low_consultant_file=sol-advisor-sol-low-consultant.toml
sol_medium_consultant_file=sol-advisor-sol-medium-consultant.toml
sol_impl_file=sol-advisor-sol-implementer.toml
sol_review_file=sol-advisor-sol-reviewer.toml

# Exact historical templates that may be replaced safely. The second Luna/Terra
# digests are this fork's earlier Luna / Max and Terra / High implementation profiles.
legacy_luna_sha256s="fba1b42849d93737e83b094a2ab0b1611f87ac37db7438c8bbdf581f0813f8eb 046bbd78a1a2bc65f8ea5dd927490aef910fb4ae3b66d045c22e29dbd9585886"
legacy_terra_sha256s="06c318e5e93f37452635906394e6ea69fb6a65ba9e6ad7172d37b444e0dc871d 4fa7fcbc2f959159d64a85b9072349e8f1c23dd27df5c7e6465619f56a31d454"

is_known_legacy() {
  digest=$1
  digests=${2-}
  for candidate in $digests; do
    [ "$digest" = "$candidate" ] && return 0
  done
  return 1
}

classify() {
  destination=$1
  template=$2
  legacy_digests=${3-}
  if ! path_exists "$destination"; then
    printf '%s\n' missing
  elif [ -L "$destination" ] || [ ! -f "$destination" ]; then
    printf '%s\n' unsafe
  elif cmp -s "$template" "$destination"; then
    printf '%s\n' current
  else
    digest=$(sha256_file "$destination")
    if [ -n "$legacy_digests" ] && is_known_legacy "$digest" "$legacy_digests"; then
      printf '%s\n' legacy
    else
      printf '%s\n' conflict
    fi
  fi
}

install_one() {
  label=$1
  template=$2
  destination=$3
  legacy_digests=${4-}
  state=$(classify "$destination" "$template" "$legacy_digests")

  if [ "$check_only" -eq 1 ]; then
    [ "$state" = current ] || fail "$label template is $state, not current: $destination"
    printf '%s\n' "CURRENT: $destination"
    return
  fi

  case "$state" in
    current) printf '%s\n' "ALREADY CURRENT: $destination" ;;
    missing)
      cp "$template" "$destination" || fail "could not install $label: $destination"
      printf '%s\n' "INSTALLED: $destination"
      ;;
    legacy)
      cp "$template" "$destination" || fail "could not migrate $label: $destination"
      printf '%s\n' "MIGRATED: $destination"
      ;;
    *) fail "$label destination is $state and will not be overwritten: $destination" ;;
  esac
}

for template in \
  "$template_dir/$luna_low_file" \
  "$template_dir/$luna_file" \
  "$template_dir/$terra_file" \
  "$template_dir/$terra_high_consultant_file" \
  "$template_dir/$sol_low_consultant_file" \
  "$template_dir/$sol_medium_consultant_file" \
  "$template_dir/$sol_impl_file" \
  "$template_dir/$sol_review_file"
do
  [ -f "$template" ] && [ ! -L "$template" ] || fail "missing or unsafe shipped template: $template"
done

if [ ! -d "$target_dir" ]; then
  [ "$check_only" -eq 0 ] || fail "target directory does not exist: $target_dir"
  mkdir -p "$target_dir" || fail "could not create target directory: $target_dir"
fi
[ -d "$target_dir" ] && [ ! -L "$target_dir" ] || fail "target is not a real directory: $target_dir"

install_one "Luna low" "$template_dir/$luna_low_file" "$target_dir/$luna_low_file"
install_one "Luna medium" "$template_dir/$luna_file" "$target_dir/$luna_file" "$legacy_luna_sha256s"
install_one "Terra medium implementer" "$template_dir/$terra_file" "$target_dir/$terra_file" "$legacy_terra_sha256s"
install_one "Terra high consultant" "$template_dir/$terra_high_consultant_file" "$target_dir/$terra_high_consultant_file"
install_one "Sol low consultant" "$template_dir/$sol_low_consultant_file" "$target_dir/$sol_low_consultant_file"
install_one "Sol medium consultant" "$template_dir/$sol_medium_consultant_file" "$target_dir/$sol_medium_consultant_file"
install_one "Sol implementer" "$template_dir/$sol_impl_file" "$target_dir/$sol_impl_file"
install_one "Sol reviewer" "$template_dir/$sol_review_file" "$target_dir/$sol_review_file"

if [ "$check_only" -eq 1 ]; then
  printf '%s\n' "CHECK PASSED: all eight Sol Advisor native roles match exactly."
else
  printf '%s\n' "INSTALL PASSED: all eight Sol Advisor native roles are current."
fi
