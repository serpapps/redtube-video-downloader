#!/bin/bash

echo "=== RedTube Video Downloader Research Validation ==="
echo "Testing commands and patterns documented in CONTRIBUTING.md"
echo ""

# Test 1: Check yt-dlp extractor support
echo "1. Testing yt-dlp RedTube extractor support:"
if yt-dlp --list-extractors | grep -q "RedTube"; then
    echo "   ✓ RedTube extractor found in yt-dlp"
else
    echo "   ✗ RedTube extractor not found"
fi
echo ""

# Test 2: Validate URL patterns
echo "2. Testing URL pattern validation:"
python3 << 'PYTHON_EOF'
import re

pattern = r'https?://(?:(?:\w+\.)?redtube\.com(?:\.br)?/|embed\.redtube\.com/\?.*?\bid=)(?P<id>[0-9]+)'

test_cases = [
    ("https://www.redtube.com/38864951", "38864951"),
    ("http://embed.redtube.com/?bgcolor=000000&id=1443286", "1443286"),
    ("http://it.redtube.com/66418", "66418"),
    ("https://www.redtube.com.br/103224331", "103224331"),
    ("https://redtube.com/12345", "12345"),
]

all_passed = True
for url, expected_id in test_cases:
    match = re.search(pattern, url)
    if match and match.group('id') == expected_id:
        print(f"   ✓ {url} -> {expected_id}")
    else:
        print(f"   ✗ {url} -> Expected {expected_id}, got {match.group('id') if match else 'None'}")
        all_passed = False

if all_passed:
    print("   ✓ All URL patterns validated successfully")
else:
    print("   ✗ Some URL patterns failed validation")
PYTHON_EOF
echo ""

# Test 3: Check if required tools are available
echo "3. Testing tool availability:"
tools=("yt-dlp" "curl" "grep" "python3")
for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        echo "   ✓ $tool is available"
    else
        echo "   ✗ $tool is not available"
    fi
done
echo ""

# Test 4: Test basic command syntax
echo "4. Testing command syntax (dry run):"
echo "   yt-dlp --help | head -5:"
yt-dlp --help | head -5 | sed 's/^/     /'
echo ""

echo "5. Testing grep patterns for URL extraction:"
cat > test_urls.txt << 'URLS_EOF'
<a href="https://www.redtube.com/12345">Video 1</a>
<iframe src="https://embed.redtube.com/?id=67890">
Visit http://it.redtube.com/54321 for more
Check out https://www.redtube.com.br/98765
URLS_EOF

echo "   Testing URL extraction from sample HTML:"
extracted_urls=$(grep -oE "https?://(?:[^/]*\.)?redtube\.com(?:\.br)?/[0-9]+" test_urls.txt)
extracted_embed=$(grep -oE "embed\.redtube\.com/\?.*?id=[0-9]+" test_urls.txt)

if [ -n "$extracted_urls" ]; then
    echo "   ✓ Standard URLs extracted:"
    echo "$extracted_urls" | sed 's/^/     /'
else
    echo "   ✗ No standard URLs extracted"
fi

if [ -n "$extracted_embed" ]; then
    echo "   ✓ Embed URLs extracted:"
    echo "$extracted_embed" | sed 's/^/     /'
else
    echo "   ✗ No embed URLs extracted"
fi

rm -f test_urls.txt
echo ""

echo "=== Validation Complete ==="
echo "All documented patterns and commands have been tested."
