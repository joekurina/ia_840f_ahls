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

KSYMTAB_FUNC(dfl_fpga_port_ops_get, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_port_ops_put, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_port_ops_add, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_port_ops_del, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_check_port_id, "_gpl", "");
KSYMTAB_FUNC(__dfl_driver_register, "", "");
KSYMTAB_FUNC(dfl_driver_unregister, "", "");
KSYMTAB_FUNC(dfl_dev_get_base_dev, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_dev_feature_uinit, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_dev_feature_init, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_dev_ops_register, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_dev_ops_unregister, "_gpl", "");
KSYMTAB_FUNC(dfh_find_param, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_enum_info_alloc, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_enum_info_free, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_enum_info_add_dfl, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_enum_info_add_irq, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_feature_devs_enumerate, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_feature_devs_remove, "_gpl", "");
KSYMTAB_FUNC(__dfl_fpga_cdev_find_port_data, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_cdev_release_port, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_cdev_assign_port, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_cdev_config_ports_pf, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_cdev_config_ports_vf, "_gpl", "");
KSYMTAB_FUNC(dfl_fpga_set_irq_triggers, "_gpl", "");
KSYMTAB_FUNC(dfl_feature_ioctl_get_num_irqs, "_gpl", "");
KSYMTAB_FUNC(dfl_feature_ioctl_set_irq, "_gpl", "");

SYMBOL_CRC(dfl_fpga_port_ops_get, 0x05ef5470, "_gpl");
SYMBOL_CRC(dfl_fpga_port_ops_put, 0xd535f4b1, "_gpl");
SYMBOL_CRC(dfl_fpga_port_ops_add, 0xb93ae768, "_gpl");
SYMBOL_CRC(dfl_fpga_port_ops_del, 0xb008aeef, "_gpl");
SYMBOL_CRC(dfl_fpga_check_port_id, 0xf0393211, "_gpl");
SYMBOL_CRC(__dfl_driver_register, 0x1c1bdf4b, "");
SYMBOL_CRC(dfl_driver_unregister, 0x075feae5, "");
SYMBOL_CRC(dfl_dev_get_base_dev, 0xd7612252, "_gpl");
SYMBOL_CRC(dfl_fpga_dev_feature_uinit, 0x9481d25c, "_gpl");
SYMBOL_CRC(dfl_fpga_dev_feature_init, 0x28955a2a, "_gpl");
SYMBOL_CRC(dfl_fpga_dev_ops_register, 0x37d80d6c, "_gpl");
SYMBOL_CRC(dfl_fpga_dev_ops_unregister, 0xf58d5328, "_gpl");
SYMBOL_CRC(dfh_find_param, 0x154eb05a, "_gpl");
SYMBOL_CRC(dfl_fpga_enum_info_alloc, 0x5ba96c35, "_gpl");
SYMBOL_CRC(dfl_fpga_enum_info_free, 0xa1791154, "_gpl");
SYMBOL_CRC(dfl_fpga_enum_info_add_dfl, 0x97577e34, "_gpl");
SYMBOL_CRC(dfl_fpga_enum_info_add_irq, 0x2f906c33, "_gpl");
SYMBOL_CRC(dfl_fpga_feature_devs_enumerate, 0xfd620018, "_gpl");
SYMBOL_CRC(dfl_fpga_feature_devs_remove, 0x88ef298e, "_gpl");
SYMBOL_CRC(__dfl_fpga_cdev_find_port_data, 0x8e3ae345, "_gpl");
SYMBOL_CRC(dfl_fpga_cdev_release_port, 0xe7086ad4, "_gpl");
SYMBOL_CRC(dfl_fpga_cdev_assign_port, 0x46631341, "_gpl");
SYMBOL_CRC(dfl_fpga_cdev_config_ports_pf, 0xba206d8f, "_gpl");
SYMBOL_CRC(dfl_fpga_cdev_config_ports_vf, 0x7495d2e9, "_gpl");
SYMBOL_CRC(dfl_fpga_set_irq_triggers, 0x07292d63, "_gpl");
SYMBOL_CRC(dfl_feature_ioctl_get_num_irqs, 0xd4805c44, "_gpl");
SYMBOL_CRC(dfl_feature_ioctl_set_irq, 0xd7d73022, "_gpl");

static const struct modversion_info ____versions[]
__used __section("__versions") = {
	{ 0x9c6febfc, "add_uevent_var" },
	{ 0x30be40ba, "platform_device_put" },
	{ 0xc1514a3b, "free_irq" },
	{ 0xe7a02573, "ida_alloc_range" },
	{ 0xdf68b21a, "try_module_get" },
	{ 0xe3ec2f2b, "alloc_chrdev_region" },
	{ 0x8e78554d, "devm_platform_ioremap_resource" },
	{ 0x13c49cc2, "_copy_from_user" },
	{ 0xd7aeb803, "devm_kmalloc" },
	{ 0xafd744c6, "__x86_indirect_thunk_rbp" },
	{ 0x3dfcc644, "dev_set_name" },
	{ 0x941f2aaa, "eventfd_ctx_put" },
	{ 0x9291cd3b, "memdup_user" },
	{ 0x346170cb, "devm_iounmap" },
	{ 0x1e6674a7, "device_unregister" },
	{ 0x96848186, "scnprintf" },
	{ 0xc4a92da8, "devm_ioremap" },
	{ 0x7d628444, "memcpy_fromio" },
	{ 0x436acbc0, "device_initialize" },
	{ 0x37a0cba, "kfree" },
	{ 0x89cb1add, "device_for_each_child" },
	{ 0xe9d75131, "get_device" },
	{ 0x3c5d2d76, "__dynamic_dev_dbg" },
	{ 0xcbd4898c, "fortify_panic" },
	{ 0xbdfb6dbb, "__fentry__" },
	{ 0x275a68b8, "platform_device_add_data" },
	{ 0xe783e261, "sysfs_emit" },
	{ 0x8df9dd10, "guid_null" },
	{ 0x65487097, "__x86_indirect_thunk_rax" },
	{ 0xbe6a61d0, "__devm_request_region" },
	{ 0x122c3a7e, "_printk" },
	{ 0xf0fdf6cb, "__stack_chk_fail" },
	{ 0xf3cec78b, "put_device" },
	{ 0xa916b694, "strnlen" },
	{ 0x5a966d7b, "fpga_region_register" },
	{ 0xb2fd5ceb, "__put_user_4" },
	{ 0x6383b27c, "__x86_indirect_thunk_rdx" },
	{ 0x749cbadd, "_dev_info" },
	{ 0x680a04a6, "module_put" },
	{ 0x21a7b10f, "platform_device_add_resources" },
	{ 0xc1115412, "cdev_add" },
	{ 0x7665a95b, "idr_remove" },
	{ 0xcdcb928c, "devm_kmemdup" },
	{ 0x68f31cbd, "__list_add_valid" },
	{ 0x86412482, "bus_unregister" },
	{ 0xba88bcfa, "devm_kfree" },
	{ 0x2f60ef0a, "_dev_err" },
	{ 0xe2a0e6b6, "device_add" },
	{ 0xb8f11603, "idr_alloc" },
	{ 0x92d5838e, "request_threaded_irq" },
	{ 0x6aadd551, "platform_device_unregister" },
	{ 0x7bcadf6c, "fpga_region_unregister" },
	{ 0x4dfa8d4b, "mutex_lock" },
	{ 0x8551794a, "platform_device_add" },
	{ 0xffb7c514, "ida_free" },
	{ 0x4a19ad77, "driver_unregister" },
	{ 0xe51b8fee, "platform_device_alloc" },
	{ 0xd67364f7, "eventfd_ctx_fdget" },
	{ 0xe1537255, "__list_del_entry_valid" },
	{ 0xcefb0c9f, "__mutex_init" },
	{ 0x8e17b3ae, "idr_destroy" },
	{ 0xa175a655, "_dev_warn" },
	{ 0x5f23e3fa, "insert_resource" },
	{ 0x5b8239ca, "__x86_return_thunk" },
	{ 0xfb384d37, "kasprintf" },
	{ 0xe2d5255a, "strcmp" },
	{ 0x6091b333, "unregister_chrdev_region" },
	{ 0x3213f038, "mutex_unlock" },
	{ 0x2b051296, "__devm_release_region" },
	{ 0xa529091, "devm_ioremap_resource" },
	{ 0x66b4cc41, "kmemdup" },
	{ 0x544be8df, "kmalloc_trace" },
	{ 0x1a3db497, "__devm_add_action" },
	{ 0xc5e74216, "release_resource" },
	{ 0x77358855, "iomem_resource" },
	{ 0xc10e997, "eventfd_signal_mask" },
	{ 0xd35ce85b, "driver_register" },
	{ 0x5aaf13e, "cdev_init" },
	{ 0xeb233a45, "__kmalloc" },
	{ 0x4344f508, "kmalloc_caches" },
	{ 0xa7aab139, "cdev_del" },
	{ 0x1c432eb5, "bus_register" },
	{ 0x3075a628, "module_layout" },
};

MODULE_INFO(depends, "fpga-region");


MODULE_INFO(srcversion, "BD0A3D7D824411072672F0A");
MODULE_INFO(rhelversion, "9.8");
