# ADR-0001: Driver model — PortCls (WDM) vs ACX (KMDF)

- **Status:** Proposed
- **Discussion:** "RFC: Driver model — PortCls vs ACX"
- **Agreed by:** —

## Context
Spec item 9 allows either WDM with PortCls or KMDF with ACX. Spec item 2 requires Windows 10 **and**
Windows 11 (x64). The choice affects the base sample, how IOCTLs reach the driver (ADR-0003) and how
much code we write ourselves.

## Options
### PortCls (WDM)
- Pros: mature, both reference samples (SimpleAudioSample, SysVAD) use it, lots of documentation and examples.
- Cons: more boilerplate, COM-style miniport interfaces, PortCls owns the dispatch table.

### ACX (KMDF)
- Pros: newer, built on KMDF so object lifetime and PnP are simpler, designed to make audio drivers easier.
- Cons: fewer samples; **Windows 10 support must be confirmed** — if ACX is not available on
  Windows 10, it can't meet spec item 2.

## Decision
TBD. To verify first: ACX availability on Windows 10.

## Consequences
TBD.
