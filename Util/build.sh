S2D_BUILD_NUMBER="3706"
S2D_BUILD_NAME="2024.3706"

S2D_DMG="Util/S2D-${S2D_BUILD_NUMBER}.dmg"
if [ ! -f "${S2D_DMG}" ]
then
    echo "Downloading Solar2D"
    curl -L "https://github.com/coronalabs/corona/releases/download/${S2D_BUILD_NUMBER}/Solar2D-macOS-${S2D_BUILD_NAME}.dmg" -o "${S2D_DMG}"
fi

hdiutil attach "${S2D_DMG}" -noautoopen -mount required -mountpoint Util/S2D

echo "Building the app"
BUILDER="Util/S2D/Corona-${S2D_BUILD_NUMBER}/Native/Corona/mac/bin/CoronaBuilder.app/Contents/MacOS/CoronaBuilder"
"$BUILDER" build --lua "Util/build_settings.lua"

hdiutil detach Util/S2D
