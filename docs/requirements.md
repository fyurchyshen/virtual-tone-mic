# Requirements traceability

Every requirement from the specification, the milestone it belongs to, and how we verify it.
Tick **Verified** only after the test in [testing.md](testing.md) passed on both Windows 10 and 11.

## Functional

| ID | Requirement | Milestone | How it's verified | Verified |
|---|---|---|---|---|
| R1 | No reboot needed to install/uninstall when no app uses the device | M3 | Install/uninstall scripts; `pnputil` does not request a reboot | ☐ |
| R2 | Windows 10 and 11, x64 only | M3 | Full manual test on both VMs | ☐ |
| R3 | Capture-only device "Virtual Tone Microphone", visible in Sound settings, selectable by any app, no hardware | M1 | Sound settings; record in Audacity and one other app | ☐ |
| R4 | Audio generated in the driver, PCM 16-bit stereo 48 kHz | M1 | Audacity project info; device properties → Advanced | ☐ |
| R5 | GUI: enable/disable, waveform (sine/square/noise), frequency 20 Hz–20 kHz, amplitude 0–100% | M2 | Manual GUI test; boundary values | ☐ |
| R6 | GUI uses a communication library; never calls IOCTLs directly | M2 | Code review: no `DeviceIoControl` in `gui/` | ☐ |
| R7 | Parameter changes apply immediately, no stream/device restart, no reboot | M2 | Change parameters during a recording; stress test | ☐ |
| R8 | Starts after boot with 440 Hz sine at 50%, without the GUI | M1 | Reboot VM, record without starting the GUI | ☐ |
| R9 | C/C++, WDM (PortCls) or KMDF (ACX); params synchronized between PASSIVE and DISPATCH; DPC uses only nonpaged memory | M1–M2 | Code review against architecture.md; Driver Verifier | ☐ |
| R10 | Passes all Driver Verifier tests | M3 | Verifier procedure in testing.md | ☐ |

## Technology

| ID | Requirement | Milestone | Verified |
|---|---|---|---|
| T1 | Visual Studio 2019/2022 with matching WDK | M0 | ☐ |

## Additional features (in the spec's order)

| ID | Feature | Milestone |
|---|---|---|
| A1 | Tests: gtest (user mode), kmtest (kernel), optional stress tests | M4 |
| A2 | Extra options: 44.1 kHz and 24-bit, triangle/sawtooth/mixed waveforms, channel selection or per-channel amplitude | M4 |
| A3 | Presets: save and load parameters | M4 |
| A4 | Monitoring: driver statistics with user-set refresh, level meter, driver presence/removal handling | M4 |
| A5 | Mixing the real microphone (WASAPI capture → ring buffer → driver mix), robust to underruns/overruns | M4 |
