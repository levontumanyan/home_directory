---
name: use-vision
description: use when working with images, screenshots, videos, or any other media files that the primary model cannot natively process. Delegate to the @vision subagent which uses a vision-capable model. Skip this skill if the primary model already supports vision.
---

# Use Vision Subagent

When you encounter image files (PNG, JPEG, GIF, WebP, SVG), screenshots, videos, or other media files that you cannot natively process, delegate to the **vision** subagent using the `task` tool.

## When to use

- The primary model does not support image/vision input (e.g., GLM-5.2, DeepSeek, Qwen Coder)
- You need to read, analyze, or describe the contents of a screenshot, diagram, chart, or photo
- You need to extract text from an image (OCR-like)
- You need to understand visual layout or UI structure from a screenshot

## When NOT to use

- The primary model natively supports vision (e.g., Claude, GPT-4o, Gemini) — just read the image directly
- The file is plain text, JSON, YAML, CSV, or any text-based format — read it normally
- You only need the file's metadata (size, type, dimensions) — use `bash` with `file` or `sips`

## How to delegate

Use the `task` tool with `subagent_type: "general"` and instruct the subagent to read the image file. Always pass the **full absolute path** — opencode may only pass the filename otherwise, forcing the subagent to search for it.

Example task prompt:

```
Read the image at /Users/levontumanyan/repos/home_directory/screenshot.png using the Read tool and describe what you see. Pay attention to any error messages, UI elements, or text content visible in the image.
```

The subagent (configured as the `vision` agent with a vision-capable model) will read the image and return a text description.
