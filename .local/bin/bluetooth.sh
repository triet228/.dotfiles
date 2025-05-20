
#!/bin/bash

# Get the current Bluetooth status (powered or not)
status=$(bluetoothctl show | grep "Powered" | awk '{print $2}')

if [[ "$status" == "yes" ]]; then
    echo "🔌 Turning Bluetooth OFF..."
    bluetoothctl power off
else
    echo "🔋 Turning Bluetooth ON..."
    bluetoothctl power on
fi

