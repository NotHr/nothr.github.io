#!/usr/bin/env bash
# Build with upstream BSSG, then add aliases for the original site's .html URLs.
set -euo pipefail
export LC_ALL=C
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
cd "$ROOT"

if [[ ! -f vendor/bssg/bssg.sh ]]; then
    printf 'Initialize BSSG first: make init\n' >&2
    exit 1
fi
command -v pandoc >/dev/null 2>&1 || {
    printf 'Error: install Pandoc to render Markdown.\n' >&2
    exit 1
}

# A failed build must not replace the last successful site.
work=$(mktemp -d "$ROOT/build-tmp.XXXXXX")
trap 'rm -rf -- "$work"' EXIT
mkdir -p "$work/pages"
cp -a pages/. "$work/pages/"

# BSSG supports single-line YAML frontmatter. Never evaluate content as shell.
metadata() {
    awk -v key="$1" '
        NR == 1 { if ($0 != "---") exit; next }
        $0 == "---" { exit }
        index($0, key ":") == 1 {
            sub(/^[^:]*:[[:space:]]*/, "")
            sub(/[[:space:]]*$/, "")
            if ($0 ~ /^".*"$/ || $0 ~ /^\047.*\047$/)
                $0 = substr($0, 2, length($0) - 2)
            print; exit
        }
    ' "$2"
}

# Supply the original blog-list page to BSSG alongside the handwritten pages.
# ISO dates in frontmatter allow newest-first lexical sorting.
while IFS= read -r -d '' post; do
    title=$(metadata title "$post")
    date=$(metadata date "$post")
    slug=$(metadata slug "$post")
    [[ -n $slug ]] || slug=$(basename -- "$post" .md)
    printf '%s\t%s\t%s\n' "$date" "$slug" "$title"
done < <(find src -type f -name '*.md' -print0) | sort -r > "$work/posts.tsv"
{
    printf '%s\n' '---' 'title: Blogs | Harshith reddy - nothr' 'slug: blogs' '---' '' '# List of Blogs' ''
    while IFS=$'\t' read -r date slug title; do
        display_date=$(date -u -d "$date" '+%b %d, %Y')
        printf -- '- `%s` - [%s](/blogs/%s.html)\n' "$display_date" "$title" "$slug"
    done < "$work/posts.tsv"
} > "$work/pages/blogs.md"

(
    cd "$ROOT/vendor/bssg"
    BSSG_BUILD_PAGES="$work/pages" \
    BSSG_BUILD_OUTPUT="$work/output" \
    BSSG_BUILD_CACHE="$work/cache" \
        bash ./bssg.sh build --config "$ROOT/config.sh.local"
)

# Keep generated tag/post navigation on the current host, including preview
# deployments. Feeds and canonical URLs retain the configured public domain.
site_url=$(source "$ROOT/config.sh.local"; printf '%s' "${SITE_URL%/}")
while IFS= read -r -d '' html; do
    awk -v site_url="$site_url" '
        function replace_literal(text, old, new, pos, result) {
            while ((pos = index(text, old)) > 0) {
                result = result substr(text, 1, pos - 1) new
                text = substr(text, pos + length(old))
            }
            return result text
        }
        /rel="canonical"/ { print; next }
        {
            $0 = replace_literal($0, "href=\"" site_url "/tags/", "href=\"/tags/")
            $0 = replace_literal($0, "href=\"" site_url "/blogs/", "href=\"/blogs/")
            print
        }
    ' "$html" > "$work/navigation.html"
    mv -- "$work/navigation.html" "$html"
done < <(find "$work/output" -type f -name '*.html' -print0)

# BSSG currently labels a custom homepage "Home"; preserve our original title.
awk '
    /<title>Home<\/title>/ { sub(/<title>Home<\/title>/, "<title>Harshith reddy - nothr</title>") }
    { print }
' "$work/output/index.html" > "$work/home.html"
mv -- "$work/home.html" "$work/output/index.html"

# BSSG publishes clean URLs. Keep those for feeds/canonicals, and retain .html
# aliases so all existing navigation links and external bookmarks still work.
while IFS= read -r -d '' page; do
    slug=$(metadata slug "$page")
    [[ $slug == index ]] && continue
    cp -- "$work/output/$slug/index.html" "$work/output/$slug.html"
done < <(find "$work/pages" -type f -name '*.md' -print0)
while IFS=$'\t' read -r date slug title; do
    cp -- "$work/output/blogs/$slug/index.html" "$work/output/blogs/$slug.html"
done < "$work/posts.tsv"

if [[ -e site || -L site ]]; then
    mv -- site "$work/previous-site"
fi
if ! mv -- "$work/output" site; then
    if [[ -e "$work/previous-site" || -L "$work/previous-site" ]]; then
        mv -- "$work/previous-site" site
    fi
    exit 1
fi
printf 'Built site/ with BSSG successfully.\n'
