# scripts/driver/

Helpers for the **test VM**. Run from an elevated PowerShell.

| Script | What it does |
|---|---|
| `install-driver.ps1` | Installs the driver as a root-enumerated device with `devcon`. |
| `uninstall-driver.ps1` | Removes the device, deletes the package from the driver store, and reports whether Windows asked for a reboot. |

`devcon.exe` comes with the WDK (`Tools\x64`). Copy it to the VM together with the driver package.
The hardware ID is in the `[Models]` section of the INF.
