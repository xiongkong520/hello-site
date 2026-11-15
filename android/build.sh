#!/usr/bin/env bash
# 在 GitHub Actions runner（x86_64，自带 Android SDK）上编译 WebView 壳子 APK
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"
OUT="$ROOT/out"
rm -rf "$OUT"; mkdir -p "$OUT/obj" "$OUT/dex"

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-/usr/local/lib/android/sdk}}"
BT=$(ls -d "$SDK"/build-tools/*/ 2>/dev/null | sort -V | tail -1)
BT="${BT%/}"
PLATFORM=$(ls -d "$SDK"/platforms/android-*/android.jar 2>/dev/null | sort -V | tail -1)
[ -n "$BT" ] && [ -n "$PLATFORM" ] || { echo "找不到 Android SDK"; exit 1; }
echo "SDK=$SDK"; echo "BT=$BT"; echo "PLATFORM=$PLATFORM"

echo "== javac =="
javac -source 8 -target 8 -nowarn -classpath "$PLATFORM" -d "$OUT/obj" $(find src -name "*.java")

echo "== d8 =="
"$BT/d8" --release --min-api 24 --lib "$PLATFORM" --output "$OUT/dex" "$OUT/obj/com/mimichong/eat/"*.class

echo "== aapt2 =="
"$BT/aapt2" compile --dir res -o "$OUT/res.zip"
"$BT/aapt2" link -o "$OUT/base.apk" -I "$PLATFORM" \
  --manifest AndroidManifest.xml \
  --min-sdk-version 24 --target-sdk-version 34 \
  "$OUT/res.zip"

echo "== 打包 dex =="
python3 - "$OUT" <<'PY'
import sys, zipfile, os
out = sys.argv[1]
base = os.path.join(out, "base.apk")
dst = os.path.join(out, "withdex.apk")
zin = zipfile.ZipFile(base, "r")
zout = zipfile.ZipFile(dst, "w", zipfile.ZIP_DEFLATED)
for item in zin.infolist():
    data = zin.read(item.filename)
    zout.writestr(item, data)
zin.close()
with open(os.path.join(out, "dex", "classes.dex"), "rb") as f:
    zout.writestr("classes.dex", f.read())
zout.close()
print("packed:", os.path.getsize(dst), "bytes")
PY

echo "== zipalign =="
"$BT/zipalign" -f 4 "$OUT/withdex.apk" "$OUT/aligned.apk"

echo "== 生成签名密钥 =="
keytool -genkeypair -keystore "$OUT/keystore.jks" -alias app \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass mimichong -keypass mimichong \
  -dname "CN=mimichong,OU=eat,O=mimichong,L=CN,ST=CN,C=CN" 2>/dev/null

echo "== 签名 =="
"$BT/apksigner" sign --ks "$OUT/keystore.jks" \
  --ks-pass pass:mimichong --key-pass pass:mimichong \
  --out "$ROOT/app.apk" "$OUT/aligned.apk"

"$BT/apksigner" verify "$ROOT/app.apk"
ls -l "$ROOT/app.apk"
echo "APK OK"
