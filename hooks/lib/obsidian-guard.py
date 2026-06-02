#!/usr/bin/env python3
"""Exit 2 if the Obsidian CLI command is destructive; exit 0 otherwise.

Reads the full shell command from stdin. The caller handles the confirmation
flag flow; this script just answers yes or no.

Matches destructive verbs only in the subcommand position, not inside argument
values like content="... removed X ...". shlex handles shell quoting.
"""

import shlex
import sys


DESTRUCTIVE = {"delete", "trash", "remove", "destroy", "purge", "wipe"}


cmd = sys.stdin.read().strip()
try:
    tokens = shlex.split(cmd)
except ValueError:
    sys.exit(2)

subcommand = next((token for token in tokens[1:] if "=" not in token), None)
if subcommand is None:
    sys.exit(0)

if any(part.lower() in DESTRUCTIVE for part in subcommand.split(":")):
    sys.exit(2)

sys.exit(0)
