# ADR-0005: GUI framework

- **Status:** Proposed
- **Discussion:** "RFC: GUI framework"
- **Agreed by:** —

## Context
The spec allows any framework (e.g. Qt or C#). The GUI calls the communication library, which is
native code, so the choice affects how the two are connected.

## Options
### Qt (C++)
- Pros: calls the C/C++ library directly; same language as the driver side.
- Cons: Qt installation and licensing setup; bigger toolchain.

### C# (WPF or WinForms)
- Pros: fast to build a clean UI; good tooling in Visual Studio.
- Cons: needs P/Invoke or a small C wrapper to call the native library.

## Decision
TBD. Main factor: what the person working on the GUI is most comfortable with.

## Consequences
TBD.
