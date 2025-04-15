#!/data/data/com.termux/files/usr/bin/bash

# Fetch and Display Build and Android Version
BUILD_VERSION=$(su -c "getprop ro.build.version.incremental" 2>/dev/null || echo "Unknown")
ANDROID_VERSION=$(su -c "getprop ro.build.version.release" 2>/dev/null || echo "Unknown")
echo "Build Version: $BUILD_VERSION"
echo "Android Version: $ANDROID_VERSION"

# Associative array mapping package names to friendly names
declare -A app_names=(
    ["com.google.android.apps.youtube.music"]="YouTube Music"
    ["com.google.android.youtube"]="YouTube"
    ["com.google.android.apps.photos"]="Google Photos"
    ["com.google.android.apps.tachyon"]="Google Duo"
    ["com.facebook.system"]="Facebook System"
    ["com.facebook.appmanager"]="Facebook App Manager"
    ["com.facebook.services"]="Facebook Services"
    ["com.google.android.apps.maps"]="Google Maps"
    ["com.microsoft.appmanager"]="Microsoft App Manager"
    ["com.google.android.apps.chromecast.app"]="Google Home"
    ["com.google.android.videos"]="Google Play Movies & TV"
    ["com.google.android.apps.subscriptions.red"]="Google One"
    ["com.google.android.gm"]="Gmail"
    ["com.xiaomi.glgm"]="Xiaomi Game Center"
    ["com.microsoft.deviceintegrationservice"]="Microsoft Device Integration"
    ["com.google.android.apps.docs"]="Google Docs"
)

# Array of package names
apps=(
    com.google.android.apps.youtube.music
    com.google.android.youtube
    com.google.android.apps.photos
    com.google.android.apps.tachyon
    com.facebook.system
    com.facebook.appmanager
    com.facebook.services
    com.google.android.apps.maps
    com.microsoft.appmanager
    com.google.android.apps.chromecast.app
    com.google.android.videos
    com.google.android.apps.subscriptions.red
    com.google.android.gm
    com.xiaomi.glgm
    com.microsoft.deviceintegrationservice
    com.google.android.apps.docs
)

# Function to display menu (only used in interactive mode)
display_menu() {
    echo "Select apps to KEEP (not delete). Enter numbers separated by spaces (e.g., '1 3 5')."
    echo "Enter '0' or nothing to proceed with uninstalling all unselected apps."
    echo "---------------------------------------------"
    for i in "${!apps[@]}"; do
        echo "$((i+1)). ${app_names[${apps[$i]}]}"
    done
    echo "---------------------------------------------"
    echo -n "Your selection: "
}

# Initialize array to track apps to keep
declare -A keep_apps

# Check if running interactively (not piped)
if [ -t 0 ]; then
    echo "DEBUG: Running interactively"
    display_menu
    read -r input
    echo "DEBUG: Input received: '$input'"

    if [[ -z "$input" || "$input" == "0" ]]; then
        echo "Proceeding with no apps kept."
    else
        read -ra numbers <<< "$input"
        valid=true
        for num in "${numbers[@]}"; do
            if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#apps[@]}" ]; then
                echo "Invalid input: $num. Proceeding with no apps kept."
                valid=false
                break
            fi
        done
        if [[ "$valid" == "true" ]]; then
            for num in "${numbers[@]}"; do
                index=$((num-1))
                keep_apps[${apps[$index]}]=1
                echo "${app_names[${apps[$index]}]} marked to keep."
            done
        fi
    fi
else
    echo "DEBUG: Running non-interactively (e.g., via curl). No apps kept."
fi

# Uninstall apps not marked to keep
for app in "${apps[@]}"; do
    if [[ -z "${keep_apps[$app]}" ]]; then
        echo "Uninstalling ${app_names[$app]} ($app)..."
        su -c "pm uninstall --user 0 $app" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "${app_names[$app]} uninstalled successfully."
        else
            echo "Failed to uninstall ${app_names[$app]} or app not found."
        fi
    else
        echo "Skipping ${app_names[$app]} (kept by user)."
    fi
done

echo "Debloat process completed."
