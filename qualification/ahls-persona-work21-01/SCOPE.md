# Guarded AHLS persona in the Work21 PR context

Bind the already accepted guarded AHLS/DMA/page-safe-bank RTL to the matching Work21 static QDB using the installed OPAE out-of-tree setup tools and Quartus 25.1. Preserve the static image, release, original setup, and accepted component sources. This is not a repeat of the standalone `ofs_plat_if` diagnostic or an unchanged FIM build.

The first native stage is mapped synthesis of project `ofs_top`, revision `ofs_pr_afu`, board top `top`, device `AGFB027R25A2E2V`, with `green_region` rebound to `afu_main`. No speculative pins, no hardware or driver access, no programming, no reset/reboot. Vendor DDR simulation remains **SKIPPED BY USER**.

Actual fit/STA/assembly, active-path mapping findings, freeze/drain/ordering, physical DDR/OPAE/numerical qualification and durable boot remain separate gates. The standing goal remains incomplete.
