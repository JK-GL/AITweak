#!/bin/sh
# AI King Repo 索引生成器
# 用法: sh scripts/make-repo.sh
# 作用: 扫描 debs/ 下所有 .deb，生成 Packages / Packages.gz / Release

set -e
cd "$(dirname "$0")/.."

ORIGIN="AI Tweak"
LABEL="AI Tweak"
DESC="AI 生成的越狱插件源 · AI-generated jailbreak tweaks"

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "[1/4] 扫描 debs/ ..."
COUNT=0
: > Packages.tmp
for f in debs/*.deb; do
  [ -f "$f" ] || continue
  NAME=$(basename "$f")
  [ "$NAME" = "*" ] && continue
  SIZE=$(wc -c < "$f" | tr -d ' ')
  MD5=$(md5sum "$f" | awk '{print $1}')
  SHA1=$(sha1sum "$f" | awk '{print $1}')
  SHA256=$(sha256sum "$f" | awk '{print $1}')

  rm -rf "$TMP/ctl"; mkdir -p "$TMP/ctl"
  if ! dpkg-deb -e "$f" "$TMP/ctl" 2>/dev/null; then
    echo "  ! 跳过(无法解包): $NAME"
    continue
  fi

  {
    cat "$TMP/ctl/control"
    printf 'Filename: %s\n' "$NAME"
    printf 'Size: %s\n' "$SIZE"
    printf 'MD5sum: %s\n' "$MD5"
    printf 'SHA1: %s\n' "$SHA1"
    printf 'SHA256: %s\n' "$SHA256"
    printf 'Source: %s\n' "$ORIGIN"
    printf '\n'
  } >> Packages.tmp

  COUNT=$((COUNT+1))
  echo "  + $NAME"
done

echo "[2/4] 写入 Packages (共 $COUNT 个) ..."
mv Packages.tmp Packages

echo "[3/4] 压缩 ..."
gzip -9 -c Packages > Packages.gz
command -v bzip2 >/dev/null 2>&1 && bzip2 -9 -c Packages > Packages.bz2 || true

echo "[4/4] 写 Release ..."
{
  printf 'Origin: %s\n' "$ORIGIN"
  printf 'Label: %s\n' "$LABEL"
  printf 'Suite: stable\n'
  printf 'Version: 1.0\n'
  printf 'Codename: ios\n'
  printf 'Architectures: iphoneos-arm iphoneos-arm64 iphoneos-arm64e\n'
  printf 'Components: main\n'
  printf 'Description: %s\n' "$DESC"
} > Release

echo "完成。产物: Packages / Packages.gz / Release"
