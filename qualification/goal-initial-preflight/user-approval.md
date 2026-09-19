# User approval — bounded generation work

User statement after reviewing experimental-gate-proposal.md:

> I approve. Work towards complete RTL generation and validation. If the FIM loses PCIe access, you may reboot the workstation.

This approves implementing/reviewing the proposed scoped execution gates and proceeding toward setup, complete RTL generation and validation. It does not change readiness or establish hardware qualification. The plan's later acceptance gates remain operative. Original donor repositories remain read-only; no commits or pushes.

Conditional reboot permission applies if the FIM loses PCIe access. It is not permission for unrelated reboots, persistent driver/boot changes, power cycling, factory-image overwrite or speculative flash programming. Reboot permission alone does not prove recovery from an invalid persistent image. The required vendor image-layout, activation, quiescence and no-JTAG recovery checks still precede programming.
