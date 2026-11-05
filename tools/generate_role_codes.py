#!/usr/bin/env python3
"""Generate phase-one offline role codes for Safety Observation.

This is a role selector for the offline pilot, not a secure identity system.
Keep the key and digest format in sync with lib/app/role_code.dart.
"""
import argparse
import hashlib
import hmac
import secrets

KEY = b"safety-observation-role-codes-phase-one-2026"
ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"


def generate(role: str) -> str:
    token = "".join(secrets.choice(ALPHABET) for _ in range(10))
    prefix = f"SO1-{role}-{token}"
    signature = hmac.new(KEY, prefix.encode(), hashlib.sha256).hexdigest()[:8].upper()
    return f"{prefix}-{signature}"


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("role", choices=("EMP", "SUP"), help="EMP employee, SUP supervisor")
parser.add_argument("--count", type=int, default=1)
args = parser.parse_args()
if args.count < 1 or args.count > 10000:
    parser.error("--count must be between 1 and 10000")
for _ in range(args.count):
    print(generate(args.role))
