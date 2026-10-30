# ADR-0002: Base sample — SimpleAudioSample vs SysVAD

- **Status:** Proposed
- **Discussion:** "RFC: Base sample"
- **Agreed by:** —

## Context
The spec hints at both samples from microsoft/Windows-driver-samples. Starting from a working sample
is much faster than starting from scratch.

## Options
### SimpleAudioSample
- Pros: small and easy to read; quick to strip down to one capture endpoint.
- Cons: we may need to write more of the capture/generation logic ourselves.

### SysVAD
- Pros: already demonstrates a virtual device with simulated capture from a generated tone; full reference.
- Cons: very large (many endpoint types, offload, etc.), so stripping it down takes time and risks leftovers.

### Hybrid
Start from SimpleAudioSample and borrow the relevant parts (tone generation, capture timing) from SysVAD.

## Decision
TBD.

## Consequences
TBD.
