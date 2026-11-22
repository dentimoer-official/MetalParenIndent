#!/bin/bash
#
# rename-project.sh
# Renames MetalParenIntdent -> MetalParenIndent everywhere in the project,
# EXCEPT bundle identifiers (they are registered on the developer account
# and in App Store Connect, so they must stay the same).
#
# Usage: run from the folder that contains MetalParenIntdent.xcodeproj
#   bash rename-project.sh
#

set -euo pipefail

OLD="MetalParenIntdent"
NEW="MetalParenIndent"

if [ ! -d "$OLD.xcodeproj" ]; then
    echo "❌ $OLD.xcodeproj 가 없음. .xcodeproj 가 있는 폴더에서 실행해."
    exit 1
fi

if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    echo "❌ 커밋 안 된 변경이 있음. 먼저 커밋하고 다시 실행해."
    exit 1
fi

if pgrep -x Xcode >/dev/null; then
    echo "❌ Xcode 가 켜져 있음. ⌘Q 로 완전히 끄고 다시 실행해."
    exit 1
fi

echo "1) 파일 내용 바꾸는 중 (번들 ID 줄은 그대로 둠)"
grep -rlI "$OLD" . \
    --exclude-dir=.git --exclude-dir=build --exclude-dir=DerivedData \
    --exclude=rename-project.sh \
| while IFS= read -r f; do
    perl -i -pe "s/$OLD/$NEW/g unless /PRODUCT_BUNDLE_IDENTIFIER/" "$f"
    echo "   수정: $f"
done

echo "2) 파일·폴더 이름 바꾸는 중"
find . -depth -name "*$OLD*" -not -path "./.git/*" | while IFS= read -r p; do
    dir=$(dirname "$p")
    base=$(basename "$p")
    target="$dir/${base//$OLD/$NEW}"
    git mv "$p" "$target" 2>/dev/null || mv "$p" "$target"
    echo "   이름 변경: $p -> $target"
done

echo "3) 남은 흔적 확인"
left=$(grep -rI "$OLD" . --exclude-dir=.git --exclude=rename-project.sh || true)
if [ -n "$left" ]; then
    echo "$left"
    echo "   ↑ 위 줄들은 번들 ID 라서 일부러 남겨둔 것 (정상)"
fi

echo "4) 예전 DerivedData 정리"
rm -rf ~/Library/Developer/Xcode/DerivedData/${OLD}-*

echo "✅ 완료. 프로젝트 폴더 이름까지 바꾸려면:"
echo "   cd .. && mv $OLD $NEW && cd $NEW"