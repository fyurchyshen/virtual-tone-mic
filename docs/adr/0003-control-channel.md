# ADR-0003: How the communication library reaches the driver

- **Status:** Proposed
- **Discussion:** "RFC: How the GUI reaches the driver"
- **Agreed by:** —

## Context
Spec item 6 requires an IOCTL interface wrapped by a user-mode library. In a PortCls driver, PortCls
installs its own dispatch routines, so our IOCTLs need a deliberate path to our code.

## Options
### A. Device interface on the audio device + own IRP_MJ_DEVICE_CONTROL handling
Register a custom device interface (GUID in `common/`), handle our IOCTLs in our own dispatch routine,
and pass everything else on to PortCls.
- Pros: one device; library finds it by interface GUID.
- Cons: must be careful to forward every other IRP to PortCls correctly.

### B. Separate control device object
Create an extra (non-audio) device object only for control.
- Pros: clean separation from the audio stack.
- Cons: extra device lifetime to manage; must not block uninstall without reboot (R1).

### C. Custom KS property
Expose parameters as a kernel-streaming property set on the filter or pin.
- Pros: the "audio-native" way.
- Cons: more complex from user mode; the spec explicitly asks for an IOCTL interface.

## Decision
TBD. Depends on ADR-0001.

## Consequences
TBD.
