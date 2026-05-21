import json
import sys

data = json.load(sys.stdin)
cmd = data.get('tool_input', {}).get('command', '')
triggers = ['buildkite plan this', 'buildkite apply this']

if any(t in cmd for t in triggers) and 'gh pr update-branch' not in cmd:
	print('BLOCKED: gh pr update-branch must run before triggering buildkite.')
	print('Rewrite as: gh pr update-branch <PR_NUMBER> && gh pr comment <PR_NUMBER> --body "buildkite plan this"')
	sys.exit(1)
