#!/data/data/com.termux/files/usr/bin/bash

# Ensure script is run with root privileges
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root. Use 'su' first."
    exit 1
fi

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

# Function to display menu and get user selection
display_menu() {
    echo "Select apps to KEEP (not delete). Enter numbers separated by spaces (e.g., '1 3 5')."
    echo "Enter '0' to proceed with uninstalling all unselected apps."
    echo "---------------------------------------------"
    for i in "${!apps[@]}"; do
        echo "$((i+1)). ${app_names[${apps[$i]}]}"
    done
    echo "---------------------------------------------"
    echo -n "Your selection: "
}

# Initialize array to track apps to keep
declare -A keep_apps

# Get user input for apps to keep
while true; do
    display_menu
    read -r input
    if [[ "$input" == "0" ]]; then
        break
    fi

    # Validate input
    valid=true
    for num in $input; do
        if ! [[ "$num" =~ ^[0-9]+$ ]] || [ "$num" -lt 1 ] || [ "$num" -gt "${#apps[@]}" ]; then
            echo "Invalid input: $num. Please enter valid numbers or 0 to proceed."
            valid=false
            break
        fi
    done

    if $valid; then
        for num in $input; do
            index=$((num-1))
            keep_apps[${apps[$index]}]=1
            echo "${app_names[${apps[$index]}]} marked to keep."
        done
        echo "Proceed with uninstallation? (y/n)"
        read -r confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            break
        fi
    fi
done

# Uninstall apps not marked to keep
for app in "${apps[@]}"; do
    if [[ -z "${keep_apps[$app]}" ]]; then
        echo "Uninstalling ${app_names[$app]} ($app)..."
        pm uninstall --user 0 "$app" 2>/dev/null
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
