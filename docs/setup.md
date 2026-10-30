# Development environment setup

Everyone completes this in milestone M0. If you hit a problem, ask in **Discussions → Q&A**, and once
it's solved add it to [Gotchas](#gotchas) so the others don't hit it too.

## 1. Development machine
1. Install **Visual Studio 2022** (or 2019) with the workload *Desktop development with C++*.
   Under *Individual components*, also add the **MSVC Spectre-mitigated libraries** for x64
   (driver projects fail to build without them).
2. Install the **Windows SDK** and the **WDK** with matching version numbers, plus the WDK
   Visual Studio extension. Follow Microsoft's "Download the WDK" page for the current pairing.
3. Clone the Microsoft samples next to this repo:
   `git clone https://github.com/microsoft/Windows-driver-samples`

## 2. Test VMs (never test drivers on your main machine)
1. Create a **Windows 11 x64** VM (Hyper-V, VMware or VirtualBox). Later also a **Windows 10 x64** VM.
2. Disable **Secure Boot** in the VM settings (needed for test-signed drivers).
3. In the VM, from an elevated prompt: `bcdedit /set testsigning on`, then reboot.
   The desktop should show "Test Mode" in the corner.
4. Install **Audacity** in the VM for recording tests.
5. **Take a snapshot.** Restore it whenever a driver leaves the VM in a bad state.
6. Recommended: set up kernel debugging over the network (KDNET) with WinDbg, so a crash
   gives you a stack trace instead of just a reboot.

## 3. Build and install a sample (M0 goal)
1. Open the SimpleAudioSample solution from `Windows-driver-samples/audio/simpleaudiosample`.
2. Build **Debug | x64**. Visual Studio test-signs the package automatically.
3. Copy the package folder (`.sys`, `.inf`, `.cat`) and `devcon.exe` (from the WDK `Tools\x64` folder) to the VM.
4. Install a root-enumerated device, using the hardware ID from the INF's `[Models]` section
   (or use `scripts/driver/install-driver.ps1`):
   `devcon install <name>.inf <HardwareId>`
5. Check that the device appears in **Settings → System → Sound**.

## 4. Verify the audio, not just the device
1. In Audacity, set the project rate to 48000 Hz and select the device as input.
2. Record a few seconds. Check the waveform shape and use *Analyze → Plot Spectrum* to confirm the frequency.

## 5. Uninstall (no reboot expected)
Use `scripts/driver/uninstall-driver.ps1`, or manually:
1. `devcon remove <HardwareId>`
2. `pnputil /enum-drivers` and find the `oemNN.inf` that belongs to the driver.
3. `pnputil /delete-driver oemNN.inf /uninstall`

## 6. Driver Verifier
See [testing.md](testing.md#driver-verifier).

## Gotchas
<!-- Format: **Symptom** – cause – fix. Newest at the top. -->
- (add yours here)
