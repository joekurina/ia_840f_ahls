# Current continuation authority

Joe explicitly states: **“YOU HAVE FULL PERMISSION TO CONTINUE. I HAVE PHYSICAL ACCESS TO THE WORKSTATION”**, while retaining **“DO NOT DO ANYTHING THAT COULD CAUSE THE WORKSTATION TO HANG.”**

Treat physical/on-site access as the newly supplied independent recovery capability, not a no-hang guarantee. Prior reports saying recovery is unavailable are historical. Resume one bounded, source-reviewed operation at a time; no speculative BAR probing, automatic retries or recovery chains. Reuse the already programmed Work21/CAPS01 image, existing VF setup and existing Target01 build.

First operation: ordinary-file/cached-kernel metadata preflight with process/device-holder inspection. No AFU FD, reset, MMIO, PCI config, rebind, flash or reboot. A mismatch stops progression. The subsequent OPAE inspection must explicitly account for VFIO FLR/open/close and bank0-domain requirements.
