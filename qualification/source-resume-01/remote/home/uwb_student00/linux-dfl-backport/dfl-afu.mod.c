#include <linux/module.h>
#define INCLUDE_VERMAGIC
#include <linux/build-salt.h>
#include <linux/elfnote-lto.h>
#include <linux/export-internal.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

BUILD_SALT;
BUILD_LTO_INFO;

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__section(".gnu.linkonce.this_module") = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_MITIGATION_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif



static const struct modversion_info ____versions[]
__used __section("__versions") = {
	{ 0xa8253861, "pin_user_pages_fast" },
	{ 0xb008aeef, "dfl_fpga_port_ops_del" },
	{ 0x13c49cc2, "_copy_from_user" },
	{ 0xd7aeb803, "devm_kmalloc" },
	{ 0x72dbe3d0, "platform_driver_unregister" },
	{ 0xca9360b5, "rb_next" },
	{ 0xde758b23, "dma_unmap_page_attrs" },
	{ 0x7c3b1ff8, "unpin_user_pages" },
	{ 0x406c24f1, "remap_pfn_range" },
	{ 0x37a0cba, "kfree" },
	{ 0xf58d5328, "dfl_fpga_dev_ops_unregister" },
	{ 0xd294630d, "pcpu_hot" },
	{ 0xc3055d20, "usleep_range_state" },
	{ 0xa5526619, "rb_insert_color" },
	{ 0x3c5d2d76, "__dynamic_dev_dbg" },
	{ 0xbdfb6dbb, "__fentry__" },
	{ 0xe783e261, "sysfs_emit" },
	{ 0x65487097, "__x86_indirect_thunk_rax" },
	{ 0xb803b79e, "dma_map_page_attrs" },
	{ 0xf0fdf6cb, "__stack_chk_fail" },
	{ 0x28955a2a, "dfl_fpga_dev_feature_init" },
	{ 0x749cbadd, "_dev_info" },
	{ 0x68f31cbd, "__list_add_valid" },
	{ 0xba88bcfa, "devm_kfree" },
	{ 0x2f60ef0a, "_dev_err" },
	{ 0x4dfa8d4b, "mutex_lock" },
	{ 0x4d9b652b, "rb_erase" },
	{ 0xd7d73022, "dfl_feature_ioctl_set_irq" },
	{ 0x124bad4d, "kstrtobool" },
	{ 0xa175a655, "_dev_warn" },
	{ 0xb61cda35, "account_locked_vm" },
	{ 0x5c3c7387, "kstrtoull" },
	{ 0xd4805c44, "dfl_feature_ioctl_get_num_irqs" },
	{ 0x2e8a6dcb, "generic_access_phys" },
	{ 0x5b8239ca, "__x86_return_thunk" },
	{ 0x6b10bee1, "_copy_to_user" },
	{ 0xece784c2, "rb_first" },
	{ 0xf3ecf9ca, "__platform_driver_register" },
	{ 0xb93ae768, "dfl_fpga_port_ops_add" },
	{ 0x3c3ff9fd, "sprintf" },
	{ 0x97651e6c, "vmemmap_base" },
	{ 0x9481d25c, "dfl_fpga_dev_feature_uinit" },
	{ 0x3213f038, "mutex_unlock" },
	{ 0x37d80d6c, "dfl_fpga_dev_ops_register" },
	{ 0xb43f9365, "ktime_get" },
	{ 0xf6ac9fa8, "boot_cpu_data" },
	{ 0x544be8df, "kmalloc_trace" },
	{ 0x46cf10eb, "cachemode2protval" },
	{ 0x7292d63, "dfl_fpga_set_irq_triggers" },
	{ 0xeb233a45, "__kmalloc" },
	{ 0xe2c17b5d, "__SCT__might_resched" },
	{ 0x4344f508, "kmalloc_caches" },
	{ 0x3075a628, "module_layout" },
};

MODULE_INFO(depends, "dfl");


MODULE_INFO(srcversion, "491C0FFAB84A0D03B2ED738");
MODULE_INFO(rhelversion, "9.8");
