# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() {
kernel.string=Flash Kernel by @nathanchance
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=bullhead
device.name2=Bullhead
device.name3=
device.name4=
device.name5=
} # end properties

# shell variables
block=/dev/block/platform/soc.0/f9824900.sdhci/by-name/boot;
is_slot_device=0;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel permissions
# set permissions for included ramdisk files
chmod -R 755 $ramdisk

## Alert of unsupported Android version
android_ver=$(mount /system; grep "^ro.build.version.release" /system/build.prop | cut -d= -f2; umount /system);
case "$android_ver" in
  "7.0"|"7.1") compatibility_string="your version is unsupported, expect no support!";;
  "7.1.1") compatibility_string="your version is supported!";;
esac;
ui_print "Running Android $android_ver, $compatibility_string";

## AnyKernel install
dump_boot;

# begin ramdisk changes

# init.flash.rc
insert_line init.bullhead.rc "init.flash.rc" after "import init.bullhead.misc.rc" "import init.flash.rc"

# init.performance_profiles.rc
insert_line init.bullhead.rc "performance_profiles" after "import init.bullhead.ramdump.rc" "import init.performance_profiles.rc";

# Add frandom compatibility
backup_file ueventd.rc;
insert_line ueventd.rc "frandom" after "urandom" "/dev/frandom              0666   root       root\n";
insert_line ueventd.rc "erandom" after "urandom" "/dev/erandom              0666   root       root\n";
backup_file file_contexts;
insert_line file_contexts "frandom" after "urandom" "/dev/frandom		u:object_r:frandom_device:s0\n";
insert_line file_contexts "erandom" after "urandom" "/dev/erandom		u:object_r:erandom_device:s0\n";

# irq tweaks
replace_string init.bullhead.rc "service msm_irqbalance /system/bin/msm_irqbalance -f /msm_irqbalance.conf" "service msm_irqbalance /system/bin/msm_irqbalance -f /vendor/etc/msm_irqbalance.conf" "service 
msm_irqbalance /system/bin/msm_irqbalance -f /msm_irqbalance.conf"

# end ramdisk changes

write_boot;

## end install

