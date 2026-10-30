# ADR-0004: Synchronizing parameters between IOCTL handlers and the DPC

- **Status:** Proposed
- **Discussion:** "RFC: Shared interface (VirtualToneIoctl.h)"
- **Agreed by:** —

## Context
Spec item 9: parameters written at PASSIVE_LEVEL (IOCTL handlers) and read at DISPATCH_LEVEL
(timer DPC) must be correctly synchronized, and the DPC may only use nonpaged memory.
Spec item 7: changes apply immediately without restarting the stream.

## Options
### A. Spin lock + snapshot (proposed)
Params live in a nonpaged struct with a `KSPIN_LOCK`. The IOCTL handler validates input, then writes
the whole struct under the lock. The DPC takes the lock, copies the struct to a local variable,
releases it, and generates samples from the copy.
- Pros: simple, obviously correct, lock held only for a small copy.
- Cons: none significant at this data size.

### B. Interlocked operations per field
- Pros: lock-free.
- Cons: fields can be read in an inconsistent combination (e.g. new waveform with old frequency).

### C. Double buffer with an interlocked index swap
- Pros: lock-free and consistent.
- Cons: more complex than needed for 20 bytes.

## Decision
TBD (proposal: A).

## Consequences
Generator state that changes every DPC run (phase accumulator, PRNG state) stays private to the DPC
and is not part of the shared struct.
