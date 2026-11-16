import json
import sys

data = json.load(sys.stdin)
cmd = data.get('tool_input', {}).get('command', '')
triggers = ['buildkite plan this', 'buildkite build this', 'buildkite apply this']
posts_comment = 'gh pr comment' in cmd or ('gh api' in cmd and 'comments' in cmd)

if posts_comment and any(t in cmd for t in triggers):
	print('BLOCKED: buildkite trigger comments are not yours to post.')
	print('Every push to a PR builds and plans automatically. Push to the branch (a rebase onto main counts) for a fresh plan.')
	print('Applies are posted only by the user. Tell the user what is ready to apply instead.')
	sys.exit(1)
