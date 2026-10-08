#!/usr/bin/env python3
"""IA840F AHLS board builds through CMake-native vendor stages.

No installation, FPGA discovery, PR programming or hardware test is performed.
A prepared, source-derived board package is copied into an exclusive build root.
"""
import argparse, hashlib, json, os, re, resource, shutil, subprocess, sys
from decimal import Decimal
from pathlib import Path

STATIC_SHA = "dbc1684ab873b3d317d20019430c99177653daf221e7471b227b1966d7ef30b4"
VARIANTS = {"ofs_ia840f", "ofs_ia840f_usm"}
FLOWS = {"afu_flat", "afu_flat_kclk"}


def sha(path):
    h = hashlib.sha256()
    with Path(path).open("rb") as f:
        for b in iter(lambda: f.read(1048576), b""):
            h.update(b)
    return h.hexdigest()


def tool_env(cfg):
    sdk = Path(cfg["sdk"])
    q = Path(cfg["quartus"])
    z = subprocess.run(["/usr/bin/bash", "--noprofile", "--norc", "-c",
        'source "$1/fpgavars.sh" >/dev/null && /usr/bin/python3 -c "import os,json;print(json.dumps(dict(os.environ)))"',
        "ia840f", str(sdk)], capture_output=True, text=True, check=True)
    env = json.loads(z.stdout)
    env.update(INTELFPGAOCLSDKROOT=str(sdk), ALTERA_HLS_ROOT=str(sdk),
        QUARTUS_ROOTDIR=str(q), QUARTUS_ROOTDIR_OVERRIDE=str(q),
        OPAE_PLATFORM_ROOT=cfg["platform"], OPAE_PLATFORM_FPGA_FAMILY="AGILEX",
        QUARTUS_VERSION="26.1", QUARTUS_VERSION_MAJOR="26", PR_COMPILE="1",
        BUILD_ROOT_REL="../../../..", IA840F_BUILD_CONFIG=cfg["config"])
    env["PATH"] = ":".join([str(q/"bin"),str(q/"sopc_builder/bin"),
        str(sdk/"bin"), str(sdk/"llvm/bin-llvm"), "/usr/bin", "/bin"])
    for key in ("LD_PRELOAD","OPAE_PLATFORM_GEN","BBS_LIB_PATH",
                "OPAE_PLATFORM_DB_PATH","OPAE_AFU_TOP_IFC_DB_PATH"):
        env.pop(key, None)
    return env


def native(work, label, argv, cwd, env, timeout=14400):
    """Run each vendor command via its own CMake target and durable status."""
    d = work/label
    d.mkdir(exist_ok=False)
    args = " ".join("[=["+str(a)+"]=]" for a in argv)
    cm = d/"native.cmake"
    cm.write_text('execute_process(COMMAND '+args+' WORKING_DIRECTORY [=['+str(cwd)+
        ']=] RESULT_VARIABLE rc)\nfile(WRITE [=['+str(d/"native-exit.txt")+
        ']=] "${rc}\\n")\nif(NOT rc EQUAL 0)\nmessage(FATAL_ERROR "Native failure ${rc}")\nendif()\n')
    (d/"CMakeLists.txt").write_text('cmake_minimum_required(VERSION 3.20)\nproject(IA840FStage NONE)\n'+
        'add_custom_target(run COMMAND /usr/bin/cmake -P [=['+str(cm)+']=] VERBATIM)\n')
    subprocess.run(["/usr/bin/cmake","-S",str(d),"-B",str(d/"build")],env=env,check=True)
    with (d/"native.log").open("xb",buffering=0) as log:
        p = subprocess.Popen(["/usr/bin/cmake","--build",str(d/"build"),"--target","run"],
            env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
        (d/"launch.json").write_text(json.dumps({"pid":p.pid,"argv":argv,"cwd":str(cwd)},indent=2))
        try:
            rc = p.wait(timeout=timeout)
        except subprocess.TimeoutExpired:
            # Do not abandon or retry an unresolved vendor process.
            (d/"unknown.json").write_text(json.dumps({"pid":p.pid,"state":"UNKNOWN_RUNNING"}))
            raise RuntimeError("Vendor deadline expired; reconcile original process before any retry")
    r = {"argv":argv,"cmake_rc":rc,"native_rc":(d/"native-exit.txt").read_text().strip(),
         "log_sha256":sha(d/"native.log")}
    (d/"result.json").write_text(json.dumps(r,indent=2))
    if rc != 0 or r["native_rc"] != "0":
        raise RuntimeError("Native stage failed: "+str(d))
    print(label+": native0/CMake0",flush=True)
    return r


def materialize(path):
    if path.is_symlink():
        target = path.resolve(strict=True)
        path.unlink()
        if target.is_dir(): shutil.copytree(target,path,symlinks=False)
        else: shutil.copy2(target,path)


def merge_inputs(source, project):
    skip = {"fim_platform","build","ofs_top.qpf","ofs_pr_afu.qsf","fpga.bin",
            "acl_quartus_report.txt","output_files","qdb"}
    for p in source.iterdir():
        if p.name in skip: continue
        dst = project/p.name
        materialize(dst)
        if p.is_dir():
            for leaf in p.rglob("*"):
                if not leaf.is_file(): continue
                out = dst/leaf.relative_to(p)
                if out.exists() and sha(out)!=sha(leaf):
                    raise RuntimeError("Generated input collision: "+str(out))
                out.parent.mkdir(parents=True,exist_ok=True)
                if not out.exists(): shutil.copy2(leaf,out)
        elif p.is_file():
            if dst.exists() and sha(dst)!=sha(p):
                raise RuntimeError("Generated input collision: "+str(dst))
            if not dst.exists(): shutil.copy2(p,dst)


def timing_accept(project):
    summaries = [project/"output_files/afu_flat.sta.summary",
        project/"output_files/timing_report/clocks.sta.pass.summary",
        project/"output_files/timing_report/clocks.sta.fail.summary"]
    totals = []
    for path in summaries:
        text = path.read_text()
        vals = [Decimal(x) for x in re.findall(r"(?m)^Slack\s*:\s*([^\r\n]+)",text)]
        if any(v<0 for v in vals): raise RuntimeError("Timing failure retained: "+str(path))
        totals.append(len(vals))
    if totals[0]==0 or totals[1]==0 or totals[2]!=0:
        raise RuntimeError("Incomplete final timing summaries")
    return totals


def backend(args):
    cfg = json.loads(Path(args.config).read_text())
    if args.flow and args.flow != cfg["flow"]: raise RuntimeError("Flow binding mismatch")
    k = Path(args.kernel_dir).resolve()
    work = Path(cfg["work"]).resolve()
    if not k.is_relative_to(work): raise RuntimeError("Kernel cwd outside owned work")
    p = k/"fim_platform/build/syn/board/ia840f/syn_top"
    if sha(p/"ofs_top.qdb") != STATIC_SHA: raise RuntimeError("Static import mismatch")
    stage = k/"ia840f-native26"
    stage.mkdir(exist_ok=False)
    env = tool_env(cfg)
    board = Path(cfg["board"])
    overlays = board/"board_local" if (board/"board_local").is_dir() else board
    q = Path(cfg["quartus"])
    materialize(p/"rtl")
    materialize(p/"asp_design_files.tcl")
    for f in (overlays/"hardware/common/build/rtl").iterdir():
        if f.is_file(): shutil.copy2(f,p/"rtl"/f.name)
    # Nested board-local overrides supplement the preserved common RTL.
    for f in (overlays/"hardware/common/build/rtl").rglob("*"):
        rel = f.relative_to(overlays/"hardware/common/build/rtl")
        if not f.is_file() or rel.parent == Path("."): continue
        if rel == Path("dma/dma_data_transfer.sv") and cfg["flow"] == "afu_flat_kclk":
            continue  # Fixed-system-clock timing repair is plain-flow-only.
        target = p/"rtl"/rel
        for parent in reversed(target.parents):
            if parent.is_relative_to(p/"rtl"): materialize(parent)
        materialize(target)
        target.parent.mkdir(parents=True,exist_ok=True)
        if not target.resolve().is_relative_to(p):
            raise RuntimeError("RTL override escapes the owned project")
        shutil.copy2(f,target)
    shutil.copy2(overlays/"hardware/common/build/asp_design_files.tcl",p/"asp_design_files.tcl")
    hdr = p/"rtl/ofs_asp.vh"
    materialize(hdr)
    text = hdr.read_text()
    text,n = re.subn(r"(?m)^\s*(?://\s*)?`define USE_KERNEL_CLK_EVERYWHERE_IN_PR_REGION\s+1\s*$",
        '  `define USE_KERNEL_CLK_EVERYWHERE_IN_PR_REGION 1' if cfg["flow"].endswith("_kclk") else
        '  // `define USE_KERNEL_CLK_EVERYWHERE_IN_PR_REGION 1',text)
    if n!=1: raise RuntimeError("Clock-flow macro population changed")
    hdr.write_text(text)
    merge_inputs(k,p)
    source_qsf = (k/"ofs_pr_afu.qsf").read_text()
    lines = [l for l in source_qsf.splitlines() if not (
        ("work_asp26_ia840f_01" in l and any(t in l for t in
        ("SOURCE_TCL_SCRIPT_FILE","PRE_FLOW_SCRIPT_FILE","POST_MODULE_SCRIPT_FILE","TIMING_ANALYZER_REPORT_SCRIPT")))
        or ("SOURCE_TCL_SCRIPT_FILE" in l and "../setup/build_gate_release01.tcl" in l))]
    lines += ['source afu_ip.qsf','set_global_assignment -name SEED '+str(cfg["seed"])]
    (p/"afu_flat.qsf").write_text("\n".join(lines)+"\n")
    # Full board compiles emit the initializer at kernel root; early reports use sim/.
    rom = k/"sys_description.hex"
    if not rom.is_file(): rom = k/"sim/sys_description.hex"
    if not rom.is_file(): raise RuntimeError("Current kernel ROM initializer missing")
    shutil.copy2(rom,p/"sys_description.hex")
    with (p/"afu_flat.qsf").open("a") as f:
        f.write('set_global_assignment -name SOURCE_FILE sys_description.hex\n')
    hw = k/"fim_platform/hw/afu.qsf"
    materialize(hw)
    text = hw.read_text()
    text,n = re.subn(r'(?m)^set_global_assignment -name MISC_FILE .*oneapi_afu\.json.*$',
        'set_global_assignment -name MISC_FILE "${THIS_DIR}/../build/syn/board/ia840f/syn_top/oneapi_afu.json"',text)
    if n!=1: raise RuntimeError("AFU JSON role missing/ambiguous")
    hw.write_text(text)
    catalog = str(p)+","+str(board/"hardware"/cfg["variant"]/"build")+",$"
    native(stage,"board-deploy",[str(q/"sopc_builder/bin/ip-deploy"),"--component-name=board",
        "--output-name=board.ip","--search-path="+catalog],p,env,300)
    native(stage,"board-generate",[str(q/"sopc_builder/bin/qsys-generate"),str(p/"board.ip"),
        "--synthesis=VERILOG","--quartus-project="+str(p/"ofs_top"),"--rev=afu_flat",
        "--search-path="+catalog],p,env,600)
    fifo = p/"rtl/udp_offload_engine/ip/asp_dcfifo.ip"
    native(stage,"FIFO-upgrade",[str(q/"sopc_builder/bin/qsys-generate"),"--upgrade-ip-cores",
        "--quartus-project="+str(p/"ofs_top"),"--rev=afu_flat",str(fifo)],p,env,300)
    native(stage,"FIFO-generate",[str(q/"sopc_builder/bin/qsys-generate"),str(fifo),"--synthesis=VERILOG",
        "--quartus-project="+str(p/"ofs_top"),"--rev=afu_flat"],p,env,300)
    # IP generation copies common RTL over prepared project files. Apply the
    # plain-flow timing repair only after the final generator has completed.
    dma_override = overlays/"hardware/common/build/rtl/dma/dma_data_transfer.sv"
    dma_target = p/"rtl/dma/dma_data_transfer.sv"
    if cfg["flow"] == "afu_flat" and dma_override.is_file():
        materialize(dma_target)
        if not dma_target.resolve().is_relative_to(p):
            raise RuntimeError("Generated DMA path escapes owned project")
        shutil.copy2(dma_override,dma_target)
        if sha(dma_target) != sha(dma_override):
            raise RuntimeError("Post-generation DMA override did not land")
    for n in ("qdb","dni","db","output_files"):
        d = p/n
        if d.exists(): shutil.move(str(d),str(stage/("inherited-"+n)))
    (p/"output_files").mkdir()
    base_mask = stage/"inherited-output_files/ofs_top.green_region.pmsf"
    if not base_mask.is_file() or sha(base_mask) != "7af20ac5606c423469343b78f694018775fea5ffbfdec63149e1c104c763ccc1":
        raise RuntimeError("Matching imported-static PR mask is missing")
    shutil.copy2(base_mask,p/"output_files/ofs_top.green_region.pmsf")
    static_mask = stage/"inherited-output_files/ofs_top.static.msf"
    if not static_mask.is_file() or sha(static_mask) != "b6bf7bd66b1b3dffd65c650dc8bf53faad42c09add1c9fdabf7ed1e241e395ec":
        raise RuntimeError("Matching imported-static verification mask is missing")
    shutil.copy2(static_mask,p/"output_files/ofs_top.static.msf")
    base_sof = stage/"inherited-output_files/ofs_top.sof"
    if not base_sof.is_file() or sha(base_sof) != "16812c62675e31bb7d3bdbdce80e9342c32bb7263c6a862611da427249c85195":
        raise RuntimeError("Matching imported-static SOF is missing")
    shutil.copy2(base_sof,p/"output_files/ofs_top.sof")
    native(stage,"synthesis",[str(q/"bin/quartus_syn"),"--read_settings_files=on",
        "--write_settings_files=off","ofs_top","-c","afu_flat"],p,env)
    if "Critical Warning (23418)" in (p/"output_files/afu_flat.syn.rpt").read_text():
        raise RuntimeError("Kernel ROM initialization failed")
    if cfg["flow"] == "afu_flat" and dma_override.is_file():
        expected_md5 = hashlib.md5(dma_override.read_bytes()).hexdigest()
        selected = [line for line in (p/"output_files/afu_flat.syn.rpt").read_text().splitlines()
            if "rtl/dma/dma_data_transfer.sv" in line and "User-Specified SystemVerilog HDL File" in line]
        if len(selected) != 1 or expected_md5 not in selected[0] or sha(dma_target) != sha(dma_override):
            raise RuntimeError("Synthesis did not select the bound DMA correction; do not fit")
        (stage/"DMA-source-binding.json").write_text(json.dumps({"path":str(dma_target),
            "sha256":sha(dma_target),"native_source_md5":expected_md5,"selected_row":selected[0]},indent=2))
    policy = board/"cmake/policies"/cfg["variant"]
    for n in ("user_clock_vendor800.sdc","reset_vendor.sdc","ofs_asp.sdc"):
        shutil.copy2(policy/n,p/n)
    sl = p/"asp_design_files.tcl"
    text = sl.read_text()
    text = text.replace('set_global_assignment -name SDC_FILE "ofs_asp.sdc"',
        'set_global_assignment -name SDC_FILE "user_clock_vendor800.sdc"\n'+
        'set_global_assignment -name SDC_FILE "reset_vendor.sdc"\n'+
        'set_global_assignment -name SDC_FILE "ofs_asp.sdc"')
    sl.write_text(text)
    native(stage,"fit",[str(q/"bin/quartus_fit"),"--read_settings_files=on",
        "--write_settings_files=off","ofs_top","-c","afu_flat"],p,env)
    native(stage,"optimization-STA",[str(q/"bin/quartus_sta"),"ofs_top","-c","afu_flat","--mode=finalize"],p,env,1200)
    helper = (p/"ofs_partial_reconfig/user_clock_freqs_compute.tcl").read_text()
    pre = helper.split("\nif { [info script] eq $::argv0 } {",1)[0]
    a = pre.index("proc get_fmax_from_report { clkname required jitter_compensation} {")
    b = pre.index("\n# Returns [fmax1",a)
    fn = pre[a:b].replace("proc get_fmax_from_report {","proc asp78_vendor_fmax {",1)
    fn = fn.replace('if {$metric == "Recovery"} {','if {0 && $metric == "Recovery"} {',1)
    (p/"ofs_partial_reconfig/vendor_clock_helpers.tcl").write_text(pre+"\n"+fn)
    native(stage,"select-clock",[str(q/"bin/quartus_sta"),"-t",str(board/"cmake/select26.tcl")],p,env,300)
    selected = dict(l.split("=",1) for l in (p/"vendor_operating_point.txt").read_text().splitlines())
    lo,hi = int(selected["low"]),int(selected["high"])
    clock = (p/"user_clock_vendor800.sdc").read_text()
    needle = "create_clock -name $asp73_clock_name -period 1.25 $asp73_targets"
    if clock.count(needle)!=1: raise RuntimeError("Vendor clock setter changed")
    replacement = 'if {[string match *iopll_0_outclk0 $asp73_clock_name]} {set ia26_period '+str(Decimal(1000)/Decimal(hi))+\
        '} else {set ia26_period '+str(Decimal(1000)/Decimal(lo))+'}\ncreate_clock -name $asp73_clock_name -period $ia26_period $asp73_targets'
    (p/"user_clock_operating.sdc").write_text(clock.replace(needle,replacement))
    sl.write_text(sl.read_text().replace('"user_clock_vendor800.sdc"','"user_clock_operating.sdc"'))
    (p/"output_files/user_clock_freq.txt").write_text('afu-image/clock-frequency-low:'+str(lo)+
        '\nafu-image/clock-frequency-high:'+str(hi)+'\n')
    native(stage,"final-STA",[str(q/"bin/quartus_sta"),"ofs_top","-c","afu_flat","--mode=finalize"],p,env,1200)
    counts = timing_accept(p)
    native(stage,"assembly",[str(q/"bin/quartus_asm"),"--read_settings_files=on",
        "--write_settings_files=off","ofs_top","-c","afu_flat"],p,env,1200)
    gbs = p/"output_files/afu_flat.green_region.gbs"
    native(stage,"GBS",["/usr/bin/packager","create-gbs","--rbf",str(p/"output_files/afu_flat.green_region.rbf"),
        "--gbs",str(gbs),"--afu-json",str(p/"oneapi_afu.json"),"--set-value",
        "interface-uuid:fc603c44-5c8f-5e94-bcbe-a5780030947c","clock-frequency-low:"+str(lo),
        "clock-frequency-high:"+str(hi)],p,env,120)
    import gzip
    zipped = stage/"image.gbs.gz"
    zipped.write_bytes(gzip.compress(gbs.read_bytes(),compresslevel=9,mtime=0))
    edit = str(Path(cfg["sdk"])/"host/linux64/bin/aocl-binedit")
    native(stage,"container-create",[edit,str(k/"fpga.bin"),"create"],p,env,60)
    native(stage,"container-image",[edit,str(k/"fpga.bin"),"add",".acl.gbs.gz",str(zipped)],p,env,60)
    native(stage,"resource-report",[str(q/"bin/quartus_sh"),"-t","scripts/gen-asp-quartus-report.tcl",
        "ofs_top","afu_flat"],p,env,180)
    shutil.copy2(p/"acl_quartus_report.txt",k/"acl_quartus_report.txt")
    if sha(p/"ofs_top.qdb")!=STATIC_SHA: raise RuntimeError("Static import changed")
    (stage/"result.json").write_text(json.dumps({"variant":cfg["variant"],"flow":cfg["flow"],
        "low_mhz":lo,"high_mhz":hi,"STA_records":counts,"GBS_sha256":sha(gbs),
        "hardware_access":False,"release_accepted":False},indent=2))


def frontend(args):
    if args.variant not in VARIANTS or args.flow not in FLOWS: raise RuntimeError("Invalid board/flow")
    source = Path(args.source).resolve(strict=True)
    package = Path(args.package).resolve(strict=True)
    if not (package/"board_env.xml").is_file(): raise RuntimeError("A prepared board package is required")
    work = Path(args.work).resolve()
    work.mkdir(parents=True,exist_ok=False)
    board = work/"ia840f"
    shutil.copytree(package,board,symlinks=True)
    own = Path(__file__).resolve().parent.parent
    if own.resolve()!=package:
        shutil.copytree(own/"cmake",board/"cmake",dirs_exist_ok=True)
        shutil.copytree(own/"hardware/common/build/rtl",board/"board_local/hardware/common/build/rtl",dirs_exist_ok=True)
        shutil.copy2(own/"hardware/common/build/asp_design_files.tcl",board/"board_local/hardware/common/build/asp_design_files.tcl")
    for variant in VARIANTS:
        scripts = board/"hardware"/variant/"build/scripts"
        scripts.mkdir(parents=True,exist_ok=True)
        shutil.copy2(board/"cmake/entry26.tcl",scripts/"entry26.tcl")
        shutil.copy2(board/"cmake/build26.py",scripts/"build26.py")
        spec = board/"hardware"/variant/"board_spec.xml"
        text = spec.read_text().replace("build/scripts/entry.tcl","build/scripts/entry26.tcl")
        spec.write_text(text)
    cfg = {k:str(getattr(args,k)) for k in ("sdk","quartus","platform","opae","bbb","variant","flow","seed")}
    cfg.update(board=str(board),work=str(work),config=str(work/"build-config.json"))
    for key in ("sdk","quartus","platform"):
        cfg[key]=str(Path(cfg[key]).resolve(strict=True))
    (work/"build-config.json").write_text(json.dumps(cfg,indent=2))
    env = tool_env(cfg)
    out = work/(args.variant+"__"+args.flow+".fpga"+('.a' if args.stage=="report" else ''))
    argv = [str(Path(cfg["sdk"])/"bin/ahls"),"-DFPGA_HARDWARE","-Xshardware",str(source),
        "-Xstarget="+str(board)+":"+args.variant,"-Xsbsp-flow="+args.flow,"-o",str(out)]
    if args.stage=="report": argv.append("-fsycl-link=early")
    if args.stage=="rtl":
        retained = Path(args.aocr).resolve(strict=True)
        owned = work/"retained.aocr"
        shutil.copy2(retained,owned)
        out = work/(args.variant+"__"+args.flow+".aocx")
        if args.rtl_project:
            # Full compiles leave an external project instead of embedding .acl.workdir_package.
            generated = Path(args.rtl_project).resolve(strict=True)
            shutil.copytree(generated,work/out.stem,symlinks=True,
                ignore=shutil.ignore_patterns("ia840f-native26"))
        # Installed aoc documents aocr -> aocx: reuse HLS RTL, compile changed BSP integration.
        argv = [str(Path(cfg["sdk"])/"bin/aoc"),"-o",str(out),str(owned),
            "-sycl","-hardware","-target="+str(board)+":"+args.variant,
            "-bsp-flow="+args.flow,"-output-report-folder="+str(work/"compiler.prj")]
        cfg["retained_aocr_sha256"] = sha(owned)
        (work/"build-config.json").write_text(json.dumps(cfg,indent=2))
    env["TMPDIR"]=str(work/"tmp")
    (work/"tmp").mkdir()
    native(work,"AHLS",argv,work,env)
    (work/"result.json").write_text(json.dumps({"output":str(out),"sha256":sha(out),
        "variant":args.variant,"flow":args.flow,"report_only":args.stage=="report",
        "hardware_access":False,"release_accepted":False},indent=2))


def software(args):
    """Rebuild current-source MMD/MPF and utilities into an owned prefix."""
    package = Path(args.package).resolve(strict=True)
    original = package/"source"
    if not (original/"CMakeLists.txt").is_file():
        raise RuntimeError("Prepared package lacks current MMD source")
    work = Path(args.work).resolve()
    work.mkdir(parents=True,exist_ok=False)
    source = work/"source"
    shutil.copytree(original,source,symlinks=True)
    overrides = Path(__file__).resolve().parent.parent/"software/mmd26"
    for item in overrides.rglob("*"):
        if item.is_file():
            target = source/item.relative_to(overrides)
            materialize(target)
            target.parent.mkdir(parents=True,exist_ok=True)
            if not target.resolve().is_relative_to(source):
                raise RuntimeError("MMD overlay escapes owned source")
            shutil.copy2(item,target)
    cfg = {key:str(getattr(args,key)) for key in ("sdk","quartus","platform","opae","bbb")}
    cfg["config"] = str(work/"software-config.json")
    env = tool_env(cfg)
    for key in ("LD_LIBRARY_PATH","LIBRARY_PATH","CPATH","CPLUS_INCLUDE_PATH","C_INCLUDE_PATH","CMAKE_PREFIX_PATH"):
        env.pop(key,None)
    prefix = work/"install"
    build = work/"build"
    sdk = Path(cfg["sdk"])
    opae = Path(cfg["opae"])
    argv = ["/usr/bin/cmake","-S",str(source),"-B",str(build),
        "-DASP_AFU_ID=IA840F","-DOPENCL_ASE_SIM=OFF","-DCMAKE_BUILD_TYPE=Release",
        "-DCMAKE_INSTALL_PREFIX="+str(prefix),"-DLIBOPAE-C_ROOT:PATH="+str(opae),
        "-Dlibopae-c_LIBRARIES:FILEPATH="+str(opae/"lib64/libopae-c.so"),
        "-Dlibopae-c_INCLUDE_DIRS:PATH="+str(opae/"include"),
        "-Dlibintelfpga_INCLUDE_DIRS:PATH="+str(sdk/"host/include"),
        "-Dlibintelfpga_LIBRARIES:FILEPATH="+str(sdk/"host/linux64/lib/libalteracl.so"),
        "-DCMAKE_C_COMPILER=/usr/bin/gcc","-DCMAKE_CXX_COMPILER=/usr/bin/g++",
        "-DCMAKE_INSTALL_RPATH=$ORIGIN","-DCMAKE_INSTALL_RPATH_USE_LINK_PATH=OFF"]
    native(work,"configure",argv,work,env,300)
    cpus = str(len(os.sched_getaffinity(0)))
    native(work,"MPF",["/usr/bin/cmake","--build",str(build),"--target","mpf_project","--parallel",cpus],work,env,900)
    native(work,"MMD-utilities",["/usr/bin/cmake","--build",str(build),"--parallel",cpus],work,env,900)
    native(work,"software-install",["/usr/bin/cmake","--install",str(build)],work,env,300)
    inventory = {str(p.relative_to(prefix)):sha(p) for p in prefix.rglob("*") if p.is_file()}
    (work/"result.json").write_text(json.dumps({"prefix":str(prefix),"artifacts":inventory,
        "hardware_access":False,"global_registration_changed":False},indent=2))


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument("stage",choices=("report","hardware","rtl","software","backend"))
    for name in ("package","sdk","quartus","source","variant","flow","platform","opae","bbb","work","config","kernel-dir","aocr","rtl-project"):
        p.add_argument("--"+name,default="")
    p.add_argument("--seed",type=int,default=2)
    args=p.parse_args()
    resource.setrlimit(resource.RLIMIT_AS,(55*1024**3,55*1024**3))
    if args.stage=="backend":
        cfg=json.loads(Path(args.config).read_text())
        if cfg.get("completed_kind"):
            if args.flow != cfg["flow"]:
                raise RuntimeError("Compiler flow binding mismatch")
            kernel=Path(args.kernel_dir).resolve(strict=True)
            if not kernel.is_relative_to(Path(cfg["work"]).resolve(strict=True)):
                raise RuntimeError("Compiler kernel cwd outside owned work")
            import resume26
            resume26.finish(cfg,kernel,sys.modules[__name__])
        else: backend(args)
    elif args.stage=="software": software(args)
    else: frontend(args)


if __name__=="__main__":
    main()
