# nothr.github.io

My personal website and blog, built with [BSSG](https://bssg.dragas.net/).

## Build

Requires Make, Bash 4+, Pandoc, and standard GNU/Linux utilities.

```sh
make init  # Initialize the BSSG submodule on first checkout
make       # Generate the website in site/
```

## Edit

- `pages/`: home, now, links, and tools pages.
- `src/`: blog posts in Markdown, with `title`, `date`, `slug`, and optional `tags` in YAML frontmatter.
- `static/`: images, fonts, and resume.
- `themes/nothr/style.css`: styling.
- `templates/`: header and footer.
- `config.sh.local`: site settings.

Edit the source files, then rebuild. Do not edit generated files in `site/` directly.
