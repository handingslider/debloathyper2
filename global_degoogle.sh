#!/data/data/com.termux/files/usr/bin/bash

# Force interactive mode when piped
if [ ! -t 0 ]; then
    exec bash -c "curl -sSL https://raw.githubusercontent.com/handingslider/debloathyper2/refs/heads/main/global_degoogle.sh | bash -i"
    exit
fi

# Main script starts here
clear
echo "============================================="
echo "         Android Debloater Tool"
echo "============================================="

# Device info
BUILD_VERSION=$(su -c "getprop ro.build.version.incremental" 2>/dev/null || echo "Unknown")
ANDROID_VERSION=$(su -c "getprop ro.build.version.release" 2>/dev/null || echo "Unknown")
echo "• Build Version: $BUILD_VERSION"
echo "• Android Version: $ANDROID_VERSION"
echo "---------------------------------------------"

# App database
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

# Menu function
show_menu() {
    clear
    echo "============================================="
    echo "   Select Apps to KEEP (All others will be removed)"
    echo "============================================="
    echo
    echo "Enter space-separated numbers of apps to keep"
    echo "Example: 1 3 5 (keeps YouTube Music, Google Photos, Facebook System)"
    echo
    echo " 0. Remove ALL apps (default)"
    echo "---------------------------------------------"
    
    for i in "${!apps[@]}"; do
        printf "%2d. %s\n" "$((i+1))" "${app_names[${apps[$i]}]}"
    done
    
    echo "---------------------------------------------"
}

# Main logic
declare -A keep_apps

while true; do
    show_menu
    echo -n "Your selection: "
    read -r input
    
    # Split input into array
    IFS=' ' read -r -a selections <<< "$input"
    
    # If no input or 0, proceed with full removal
    if [[ ${#selections[@]} -eq 0 ]] || [[ "${selections[0]}" == "0" ]]; then
        echo "Will remove ALL listed apps."
        break
    fi
    
    # Validate input
    invalid=0
    for num in "${selections[@]}"; do
        if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#apps[@]}" ]; then
            echo "! Invalid option: $num"
            invalid=1
        fi
    done
    
    if [ $invalid -eq 0 ]; then
        for num in "${selections[@]}"; do
            index=$((num-1))
            keep_apps[${apps[$index]}]=1
            echo "+ Keeping: ${app_names[${apps[$index]}]}"
        done
        break
    else
        echo "Please enter valid numbers (1-${#apps[@]}) or 0 for all"
        sleep 2
    fi
done

# Uninstallation process
echo
echo "Starting removal process..."
echo "---------------------------------------------"

for app in "${apps[@]}"; do
    if [[ -z "${keep_apps[$app]}" ]]; then
        echo -n "- Removing ${app_names[$app]}... "
        result=$(su -c "pm uninstall --user 0 $app" 2>&1)
        
        if [[ $result == *"Success"* ]]; then
            echo "✓ Success"
        elif [[ $result == *"not installed"* ]]; then
            echo "✗ Not installed"
        else
            echo "✗ Failed ($result)"
        fi
    else
        echo "✓ Keeping: ${app_names[$app]}"
    fi
done

echo "---------------------------------------------"
echo "Operation completed!"
echo "Note: Some changes may require a reboot"
echo "---------------------------------------------"
