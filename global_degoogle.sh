#!/data/data/com.termux/files/usr/bin/bash

# If piped, save to temp file and run locally with terminal attached
if [ ! -t 0 ]; then
    TEMP_SCRIPT=$(mktemp /data/data/com.termux/files/home/tmp.XXXXXXXXXX.sh)
    cat > "$TEMP_SCRIPT"
    chmod +x "$TEMP_SCRIPT"
    exec bash -i "$TEMP_SCRIPT"
    rm -f "$TEMP_SCRIPT"
    exit
fi

# Main script starts here
clear
echo "============================================="
echo "         Android Debloater Tool"
echo "============================================="

# Fetch and Display Build and Android Version
BUILD_VERSION=$(su -c "getprop ro.build.version.incremental" 2>/dev/null || echo "Unknown")
ANDROID_VERSION=$(su -c "getprop ro.build.version.release" 2>/dev/null || echo "Unknown")
echo "• Build Version: $BUILD_VERSION"
echo "• Android Version: $ANDROID_VERSION"
echo "---------------------------------------------"

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

# Function to display menu
display_menu() {
    echo "Select apps to KEEP (not uninstall). Enter numbers separated by spaces."
    echo "Example: '1 3 5' will keep YouTube Music, Google Photos, and Facebook System"
    echo "---------------------------------------------"
    for i in "${!apps[@]}"; do
        printf "%2d. %s\n" "$((i+1))" "${app_names[${apps[$i]}]}"
    done
    echo "---------------------------------------------"
    echo " 0. Uninstall ALL listed apps (default)"
    echo "---------------------------------------------"
    echo -n "Your selection: "
}

# Initialize array to track apps to keep
declare -A keep_apps

# Show menu and get input
display_menu
read -r -a selections

# Process input
if [[ ${#selections[@]} -eq 0 ]] || [[ "${selections[0]}" == "0" ]]; then
    echo "Proceeding with uninstalling ALL apps."
else
    valid=true
    for num in "${selections[@]}"; do
        if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#apps[@]}" ]; then
            echo "Invalid selection: $num. Please try again."
            valid=false
            break
        fi
    done
    
    if $valid; then
        for num in "${selections[@]}"; do
            index=$((num-1))
            keep_apps[${apps[$index]}]=1
            echo "Keeping: ${app_names[${apps[$index]}]}"
        done
    else
        echo "Invalid input detected. Proceeding with uninstalling ALL apps."
    fi
fi

echo "---------------------------------------------"
echo "Starting uninstallation process..."
echo "---------------------------------------------"

# Uninstall apps not marked to keep
for app in "${apps[@]}"; do
    if [[ -z "${keep_apps[$app]}" ]]; then
        echo -n "Uninstalling ${app_names[$app]}... "
        result=$(su -c "pm uninstall --user 0 $app" 2>&1)
        
        if [[ $result == *"Success"* ]]; then
            echo "✓ Success"
        elif [[ $result == *"not installed"* ]]; then
            echo "✗ Not installed"
        else
            echo "✗ Failed ($result)"
        fi
    else
        echo "Skipping: ${app_names[$app]} (kept by user)"
    fi
done

echo "---------------------------------------------"
echo "Debloat process completed!"
echo "You may need to restart your device for all changes to take effect."
echo "---------------------------------------------"
