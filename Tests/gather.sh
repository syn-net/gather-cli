#!/bin/sh

echo <<EOF
USAGE: gather [<options>] [<url>]

ARGUMENTS:
  <url>                   The URL to parse

OPTIONS:
  -c, --copy              Copy output to clipboard
  --env <env>             Get input from an environment
                          variable
  -f, --file <file>       Save output to file path. Accepts
                          %date, %slugdate, %title, and %slug
  --html                  Expect raw HTML instead of a URL
  --include-source/--no-include-source
                          Include source link to original
                          URL (default: --include-source)
  --include-title/--no-include-title
                          Include page title as h1 (default:
                          --include-title)
  --inline-links          Use inline links
  --metadata              Include page title, date, source
                          url as MultiMarkdown metadata
  --metadata-yaml         Include page title, date, source
                          url as YAML front matter
  -p, --paste             Get input from clipboard
  --paragraph-links/--no-paragraph-links
                          Insert link references after each
                          paragraph (default:
                          --paragraph-links)
  --readability/--no-readability
                          Use readability (default:
                          --readability)
  -s, --stdin             Get input from STDIN
  -t, --title-only        Output only page title
  --unicode/--no-unicode  Use Unicode characters instead of
                          ascii replacements (default:
                          --unicode)
  --accepted-only         Only save accepted answer from
                          StackExchange question pages
  --include-comments      Include comments on StackExchange
                          question pages
  --min-upvotes <min-upvotes>
                          Only save answers from
                          StackExchange page with minimum
                          number of upvotes (default: 0)
  --nv-url                Output as an Notational
                          Velocity/nvALT URL
  --nv-add                Add output to Notational
                          Velocity/nvALT immediately
  --nvu-url               Output as an nvUltra URL
  --nvu-add               Add output to nvUltra immediately
  --nvu-notebook <nvu-notebook>
                          Specify an nvUltra notebook for
                          the 'make' URL
  --url-template <url-template>
                          Create a URL scheme from a
                          template using %title, %text,
                          %notebook, %source, %date,
                          %filename, and %slug
  --fallback-title <fallback-title>
                          Fallback title to use if no title
                          is found, accepts %date
  --url-open              Open URL created from template
  --save <save>           Save settings to NAME
  --config <config>       Load settings from NAME
  -v, --version           Display current version number
  -h, --help              Show help information.
EOF

BAD_URL="https://stackoverflow.com/questions/55381517/create-a-shell-escaped-posix-path-in-macos"
GOOD_URL="https://nshipster.com/swift-regular-expressions/"
#gather --copy "$GOOD_URL"
#gather --env ".env"
gather --file /tmp/output.md "$GOOD_URL"
#gather --html --copy
gather --no-include-source --file /tmp/output_no-source.md "$GOOD_URL"
gather --no-include-title --file /tmp/output_no-title.md "$GOOD_URL"
gather --inline-links --file /tmp/output_inline-links.md "$GOOD_URL"
gather --metadata --file /tmp/output_metadata.md "$GOOD_URL"
# This test breaks mdless parsing because of the --- inclusion in the first
# three lines.
gather --metadata-yaml --file /tmp/output_metadata-yaml.md "$GOOD_URL"
#gather --paste #--html
gather --no-paragraph-links --file /tmp/output_no-paragraph-links.md "$GOOD_URL"
gather --no-readability --file /tmp/output_no-readability.md "$GOOD_URL"
echo "$GOOD_URL" | gather --file /tmp/output_no-readability.md --stdin
gather --title-only --file /tmp/output_title-only.md "$GOOD_URL"
gather --no-unicode --file /tmp/output_no-unicode.md "$GOOD_URL"
gather --accepted-only --file /tmp/output_accepted-only.md "$BAD_URL"
gather --include-comments --file /tmp/output_include-comments.md "$BAD_URL"
gather --min-upvotes 1 --file /tmp/output_min-upvotes-1.md "$BAD_URL"
gather --min-upvotes 5 --file /tmp/output_min-upvotes-5.md "$BAD_URL"
gather --min-upvotes 100 --file /tmp/output_min-upvotes-100.md "$BAD_URL"
gather --nv-url "$GOOD_URL"
#gather --nv-add
#gather --nvu-nootbook
gather --url-template ./url-template.tmpl "$GOOD_URL"
gather --fallback-title gather-test --file /tmp/output_fallback-title.md "$GOOD_URL"
gather --url-open --file /tmp/output_url-open.md "$GOOD_URL"
gather --save ./gather-cli.json
gather --config ./gather-cli.json
gather --version
