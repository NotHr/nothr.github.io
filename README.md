# nothr.in — BSSG

The content, stylesheet, and navigation/main/footer layout from
`git@github.com:NotHr/nothr.in.git`, migrated to
[BSSG — Bash Static Site Generator](https://bssg.dragas.net/).

BSSG is pinned as a Git submodule in `vendor/bssg`; site content and
customizations live separately. GitHub uses SSH; the non-GitHub BSSG upstream
uses HTTPS.

## Build

Requires Make, Bash 4+, Pandoc, and standard GNU/Linux utilities.

```sh
make init  # First checkout: initialize BSSG
make       # Build into site/
```

Use `make help` to list all commands. `make build` and `make all` also build
the site; `make clean` removes generated output and cache.

Publish `site/` at your domain root. The build uses **upstream BSSG**, with
Pandoc as its configured Markdown renderer. It generates the blog listing,
RSS, sitemap, and robots.txt. Original `.html` URLs remain available alongside
BSSG's clean URLs. Fonts, images, and the resume are copied from source assets
on every build.

Builds use temporary output, replacing `site/` only after success. Old generated
pages disappear on rebuild. `site/` is disposable and ignored by Git.

## Edit

- `pages/*.md`: home, now, links, and tools.
- `src/*.md`: posts. Set `title`, ISO `date` (`YYYY-MM-DD`), and `slug` in YAML
  frontmatter. Add comma-separated topics, e.g. `tags: linux, self-hosting`.
  BSSG generates `/tags/` and a page for each tag; post tag links appear below
  the content. Keep slugs and tags URL-safe (letters, digits, hyphens).
- `themes/nothr/style.css`: the only active stylesheet, using self-hosted Iosevka
  and compatibility rules hiding duplicate headings while keeping post titles
  and publication dates visible.
- `templates/header.html`, `templates/footer.html`: original HTML layout in
  BSSG's template format.
- `static/`: public assets only; its contents are copied into the output root.
- `config.sh.local`: BSSG settings, site identity, paths, and URL formats.

### Public assets

The folder name `static` is **not** part of a public URL:

| Source file | Public URL |
| --- | --- |
| `static/images/profile.jpg` | `/images/profile.jpg` |
| `static/images/blog-profile.jpg` | `/images/blog-profile.jpg` |
| `static/fonts/iosevka/Iosevka-Regular-latin-v1.woff2` | `/fonts/iosevka/Iosevka-Regular-latin-v1.woff2` |
| `static/resume.pdf` | `/resume.pdf` |

Put new pictures in `static/images/`. Edit CSS only in
`themes/nothr/style.css`; BSSG publishes it as `/css/style.css`.
Do not create another `static/static/` folder or edit generated files in `site/`.

Iosevka 34.9.1 is bundled locally in regular, bold, italic, and bold italic;
visitors do not contact a font CDN. It is free/open-source under the SIL Open
Font License 1.1, included at `static/fonts/iosevka/LICENSE.md`.
Font binaries come from the upstream
[PkgWebFont-Iosevka-34.9.1.zip release](https://github.com/be5invis/Iosevka/releases/tag/v34.9.1).

The bundled fonts are Latin-focused subsets (~43–48 KB each), retaining Latin
and extended Latin, punctuation, and basic arrows. Other scripts use system
fallback fonts. To reproduce from the upstream WOFF2 files, use FontTools with
Brotli support (`pip install 'fonttools[woff]'`):

```sh
pyftsubset Iosevka-Regular.woff2 \
  --unicodes='U+0000-024F,U+1E00-1EFF,U+2000-206F,U+20AC,U+2190-2199,U+FFFD' \
  --flavor=woff2 --output-file=Iosevka-Regular-latin-v1.woff2
```

Repeat for Bold, Italic, and BoldItalic. `static/_headers` gives fonts a one-year
immutable browser cache on Cloudflare Workers Static Assets and Pages; the regular
font is preloaded. When replacing a font, increment its filename version and
update both the stylesheet and preload URL. HTML and CSS are not cached immutably.

The blog-list page is generated newest-first from `src/`; do not create a
handwritten `pages/blogs.md`. Existing Markdown body text is preserved.

## Deploy over SSH

```sh
make deploy
# Optional alternative destination:
make deploy DEPLOY_TARGET=user@host:/var/www/site
```

Deployment builds first, then uses rsync over SSH. A normal build never deploys.

## Verify

```sh
make test  # Alias: make check
```

## BSSG updates

Build through `make` so the blog-list page and legacy `.html` aliases are
included. The Bash scripts are implementation helpers; `deploy.sh` remains a
compatibility wrapper for `make deploy`.

To update BSSG deliberately, pull in the submodule, run `make test`, and commit
the updated submodule revision with the site.
