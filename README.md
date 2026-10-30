# Virtual Tone Microphone

A Windows kernel-mode audio driver that adds a virtual microphone, **"Virtual Tone Microphone"**,
which produces a generated signal (sine, square or noise). A GUI application controls the signal
through a user-mode communication library.

**Target:** Windows 10 and Windows 11, x64 only · **Toolchain:** Visual Studio 2019/2022 + matching WDK

| | |
|---|---|
| 📋 **Work** | [Issues](https://github.com/robert-md-or/virtual-tone-mic/issues) · [Milestones](https://github.com/robert-md-or/virtual-tone-mic/milestones) · [Project board](https://github.com/robert-md-or/virtual-tone-mic/projects) |
| 💬 **Talk** | [Discussions](https://github.com/robert-md-or/virtual-tone-mic/discussions) — decisions, questions, meeting notes, status updates |
| 📚 **Docs** | [Documentation index](docs/README.md) · [Setup guide](docs/setup.md) · [Architecture](docs/architecture.md) · [Decisions (ADRs)](docs/adr/README.md) |

## What it does

- Adds a capture-only audio device that any application can select as its input. No hardware needed.
- Generates audio inside the driver: PCM 16-bit, stereo, 48 kHz.
- Starts right after boot with a 440 Hz sine at 50% amplitude, even without the GUI.
- The GUI enables/disables the signal and sets the waveform, frequency (20 Hz – 20 kHz) and amplitude (0–100%).
  Changes apply immediately, without restarting the stream or the device.

Full requirement list and how each one is verified: [docs/requirements.md](docs/requirements.md).

## How it fits together

```mermaid
flowchart LR
    GUI["GUI app"] --> LIB["Communication library"]
    LIB -- "IOCTLs" --> DRV["Kernel driver"]
    DRV --> AE["Windows audio engine"]
    AE --> APPS["Any recording app"]
```

More detail in [docs/architecture.md](docs/architecture.md).

## Repository layout

| Folder | Contents |
|---|---|
| [`common/`](common/) | Headers shared by the driver and the library (IOCTL codes, parameter structs). **Single source of truth for the interface.** |
| [`driver/`](driver/) | Kernel-mode audio driver and its INF. |
| [`lib/`](lib/) | User-mode communication library. The GUI only talks to this. |
| [`gui/`](gui/) | GUI application. |
| [`tests/`](tests/) | gtest (user mode), kmtest (kernel mode), CI checks. |
| [`docs/`](docs/) | Setup, architecture, requirements, testing, decisions, meeting notes. |
| [`scripts/`](scripts/) | GitHub setup script and driver install/uninstall helpers. |

## Milestones

| Milestone | Goal |
|---|---|
| **M0 – Environment & decisions** | Everyone can build and install a sample in a test VM; core design decisions made. |
| **M1 – Minimal microphone** | Capture-only device, 48 kHz / 16-bit / stereo, default 440 Hz sine at 50%, verified by recording. |
| **M2 – Control path** | Shared interface, communication library, GUI, live parameter changes. |
| **M3 – Hardening** | Install/uninstall without reboot, Driver Verifier clean, Windows 10 and 11 tested. |
| **M4 – Additional features** | Tests, extra options, presets, monitoring, real-mic mixing (in the spec's order). |

## Getting started

1. Set up your machine and test VM: [docs/setup.md](docs/setup.md).
2. Read how we work: [CONTRIBUTING.md](CONTRIBUTING.md).
3. Pick an issue from the board, assign yourself, and go.

## Team

See [docs/team.md](docs/team.md).
