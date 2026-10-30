# driver/

Kernel-mode audio driver. Model and base sample: see [ADR-0001](../docs/adr/0001-driver-model.md)
and [ADR-0002](../docs/adr/0002-base-sample.md).

Requirements to keep in mind (details in [docs/requirements.md](../docs/requirements.md)):
- Capture-only endpoint named "Virtual Tone Microphone", PCM 16-bit stereo 48 kHz.
- Starts at boot with the defaults from `common/VirtualToneIoctl.h`, no GUI needed.
- Parameters shared between IOCTL handlers (PASSIVE_LEVEL) and the timer DPC (DISPATCH_LEVEL)
  are synchronized ([ADR-0004](../docs/adr/0004-parameter-synchronization.md)); the DPC only touches nonpaged memory.
- Passes Driver Verifier; installs/uninstalls without reboot when the device isn't in use.
