#!/usr/bin/env nix-shell
#!nix-shell -i bash -p android-tools

set -euo pipefail

export D="${1:-192.168.1.185:5555}"

adb connect "${D}"

# Install alternative launcher
wget https://f-droid.org/repo/com.conreo.couchytv_7.apk
adb -s "$D" install com.conreo.couchytv_7.apk
# Set as Home (shell can do this on many builds)
adb -s "$D" shell cmd package set-home-activity com.conreo.couchytv
adb -s "$D" shell cmd shortcut get-default-launcher

# Telemetry, ads & preinstalled junk (safe)
packages=(
    com.google.android.feedback
    com.google.android.tvrecommendations
    com.mitv.tvhome.michannel
    com.mitv.tvhome.mitvplus
    com.miui.tv.analytics
    com.xiaomi.android.tvsetup.partnercustomizer
    com.xiaomi.statistic
    #com.xiaomi.tvqs.overseas
    com.xiaomo.tv.milegal
    com.xm.webcontent
)

# Unused system apps (safe on a TV)
packages+=(
    android.autoinstalls.config.xioami.mibox3
    com.android.companiondevicemanager
    com.android.printspooler
    com.android.providers.contacts
    com.android.providers.userdictionary
    com.google.android.marvin.talkback
)

# Optional — extra RAM / services you don't use
packages+=(
    com.android.dynsystem
    com.google.android.tungsten.setupwraith
    # Netflix preinstalled stubs (skip if you use Netflix)
    com.netflix.ninja
    # Bult in xiaomi software
    com.mitv.dream
    com.mitv.videoplayer
    com.xiaomi.mitv.smartshare
)

for pkg in "${packages[@]}"; do
    adb -s "$D" shell pm disable-user --user 0 "$pkg"
done

uninstall=(
    # stock Google TV home
    com.google.android.tvlauncher
    # Google Assistant/search
    com.google.android.katniss
    com.google.android.tvrecommendations
    # Optional: Xiaomi PatchWall launcher (only if you switched to a custom launcher)
    com.mitv.tvhome.atv
)

for pkg in "${uninstall[@]}"; do
    adb -s $D shell pm uninstall --user 0 "$pkg" || echo "Already uninstalled."
done

# Privacy hardening
settings=(
    'private_dns_mode hostname'
    'private_dns_specifier dns.adguard-dns.com'
    'captive_portal_mode 0'
    'captive_portal_detection_enabled 0'
    # Disable all animations
    'window_animation_scale 0'
    'transition_animation_scale 0'
    'animator_duration_scale 0'
)

for setting in "${settings[@]}"; do
    adb -s $D shell settings put global $setting
done

# AOT ("speed") compile the apps you use most, for faster cold starts
compilePkgs=(
    app.smarttube.fdroid
    com.android.vending
    com.conreo.couchytv
    com.zerotier.one
    org.xbmc.kodi
)
for pkg in "${compilePkgs[@]}"; do
    adb -s $D shell cmd package compile -m speed -f "$pkg"
done

# Trim caches
adb -s $D shell pm trim-caches 50G
