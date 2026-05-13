import iterm2
import os

# To run this script:
# open "iterm2://runscript?name=equiquant.py"

async def main(connection):
	app = await iterm2.async_get_app(connection)

	# Create a new window
	window = await iterm2.Window.async_create(connection)
	if not window:
		return

	project_path = os.path.expanduser("~/repos/cloud-lab")

	# Tab 1: Project Root (already exists in new window)
	tab1 = window.current_tab
	await tab1.async_set_title("fibonacci")
	session1 = tab1.current_session
	await session1.async_send_text(f"ssh fibonacci\n")

	# # Tab 2: VS Code and LLM
	# tab2 = await window.async_create_tab()
	# session2 = tab2.current_session
	# await session2.async_send_text(f"cd {project_path} && code . && llm\n")

iterm2.run_forever(main)
