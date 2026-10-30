# Glossary

| Term | Meaning |
|---|---|
| **ACX** | Audio Class Extensions. A newer audio driver framework built on KMDF. |
| **ADR** | Architecture Decision Record. A short document recording a decision and why. |
| **Capture endpoint** | An audio input device as seen by Windows (a microphone). |
| **DPC** | Deferred Procedure Call. Kernel callback that runs at DISPATCH_LEVEL; our timer DPC generates audio. |
| **Driver Verifier** | Windows tool that checks drivers for illegal behaviour and bugchecks when it finds it. |
| **INF** | Text file that tells Windows how to install a driver. |
| **IOCTL** | I/O control code. How user mode sends commands to a driver via `DeviceIoControl`. |
| **IRQL** | Interrupt request level. PASSIVE_LEVEL (normal), DISPATCH_LEVEL (DPCs, spin locks; no paging, no waiting). |
| **KDNET** | Kernel debugging over the network, used with WinDbg. |
| **KMDF** | Kernel-Mode Driver Framework. |
| **KS** | Kernel Streaming, the framework Windows audio drivers are exposed through. |
| **Miniport** | The driver-specific part of a PortCls driver (wave, topology). |
| **Nonpaged memory** | Memory that is never paged out; required for anything touched at DISPATCH_LEVEL. |
| **PCM** | Uncompressed audio samples. Ours: 16-bit signed, 2 channels, 48,000 frames/s. |
| **PortCls** | Port Class driver. Microsoft's WDM-based framework for audio drivers. |
| **Root-enumerated** | A device with no hardware, created by software (e.g. `devcon install`). |
| **Spin lock** | Lock usable at DISPATCH_LEVEL. Raises IRQL while held; keep held sections very short. |
| **Test signing** | Windows mode that accepts drivers signed with a test certificate. |
| **WASAPI** | Windows Audio Session API, used in user mode to capture/play audio (feature A5). |
| **WDK** | Windows Driver Kit. |
| **WDM** | Windows Driver Model, the classic kernel driver model PortCls is built on. |
