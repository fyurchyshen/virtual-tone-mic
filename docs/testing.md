# Testing

## Manual test checklist

Run on **both** the Windows 10 and Windows 11 VM before closing a milestone.

### Device and audio (M1)
- [ ] After install, "Virtual Tone Microphone" appears in Settings → Sound → Input.
- [ ] Device properties show 2 channels, 16 bit, 48000 Hz.
- [ ] Recording in Audacity shows a 440 Hz sine (Plot Spectrum peak at 440 Hz) at about 50% amplitude.
- [ ] After a reboot, recording works the same **without** starting the GUI.
- [ ] A second app (e.g. Voice Recorder or a browser mic test) can use the device.

### Control path (M2)
- [ ] Enable/disable switches between signal and silence while recording.
- [ ] Each waveform looks right in the recording (sine, square, noise).
- [ ] Frequency boundaries: 20 Hz and 20,000 Hz work; values outside are rejected by the GUI and the driver.
- [ ] Amplitude 0% gives silence, 100% gives full scale without clipping artifacts.
- [ ] Changing any parameter during a recording applies immediately, the recording does not stop.
- [ ] GUI shows a clear message when the driver is not installed.

### Hardening (M3)
- [ ] Install without reboot.
- [ ] Uninstall without reboot when no app uses the device.
- [ ] Uninstall while recording: behaves sensibly (reboot request or refusal, no crash).
- [ ] Full Driver Verifier run passes (below).

## Driver Verifier

1. In the VM (elevated): `verifier /standard /driver <driver>.sys`, then reboot.
2. Run the full manual checklist, including parameter changes during recording and install/uninstall.
3. `verifier /query` shows the driver is being verified and lists counters.
4. Any bugcheck → open a **Bug** issue with the `!analyze -v` output.
5. Turn it off with `verifier /reset` and reboot.

Before the final M3 sign-off, also try additional checks such as low resources simulation, and
record which settings were used in the PR.

## Automated tests (M4)

| Level | Tool | What |
|---|---|---|
| User mode | gtest | Library API: parameter validation, IOCTL packing, error handling, driver-absent behaviour (with a mock device). |
| Kernel | kmtest | IOCTL handlers: buffer size checks, invalid values rejected, params stored correctly. |
| CI | GitHub Actions | Shared header compiles as C and C++; struct layout unchanged. |

## Stress test (optional, A1)

While recording continuously for 10+ minutes, a script changes waveform, frequency and amplitude
every few milliseconds through the library. Pass criteria: no crash, no Verifier violation,
no stream interruption, final parameters match the last values set.
