import json
import sys

data = json.load(sys.stdin)
cmd = data.get('tool_input', {}).get('command', '')

if 'buildkite plan this' in cmd or 'buildkite build this' in cmd:
	print('BLOCKED: plan and build comments do nothing anymore. Every push to a PR builds and plans automatically.')
	print('For a fresh plan, push to the branch (a rebase onto main counts).')
	sys.exit(1)

if 'buildkite apply this' in cmd and 'gh pr update-branch' not in cmd:
	print('BLOCKED: gh pr update-branch must run before triggering buildkite apply.')
	print('Rewrite as: gh pr update-branch <PR_NUMBER> && gh pr comment <PR_NUMBER> --body "buildkite apply this"')
	sys.exit(1)
