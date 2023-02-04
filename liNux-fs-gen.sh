#!/bin/bash

echo "==================================="
echo "          liNux-fs-gen             "
echo "==================================="
echo ""

NET_OS=$(pwd)/liNux

set +h
umask 022

echo ""
echo "!-- Create main directory..."
mkdir -pv ${NET_OS}

echo ""
echo "!-- Create Basic directory..."
mkdir -pv ${NET_OS}/{bin,boot{,grub},dev,{etc/,}opt,home,lib/{firmware,modules},lib64,mnt}
mkdir -pv ${NET_OS}/var/{lock,log,mail,run,spool}
mkdir -pv ${NET_OS}/var/{opt,cache,lib/{misc,locate},local}

echo ""
echo "!-- Setting Directory..."
install -dv -m 0750 ${NET_OS}/root
install -dv -m 1777 ${NET_OS}{/var,}/tmp
install -dv ${NET_OS}/etc/init.d

echo ""
echo "!-- Create User Directory..."
mkdir -pv ${NET_OS}/usr/{,local/}{bin,include,lib{,64},sbin,src}
mkdir -pv ${NET_OS}/usr/{,local/}share/{doc,info,locale,man}
mkdir -pv ${NET_OS}/usr/{,local/}share/man/man{1,2,3,4,5,6,7,8}

for dir in ${NET_OS}/usr{,/local}; do
    ln -sv share/{man,doc,info} ${dir}
done

echo ""
echo "!-- Link /etc/mtab file..."
ln -svf ../proc/mounts ${NET_OS}/etc/mtab

echo ""
echo "!-- Write Passwd file..."
cat > ${NET_OS}/etc/passwd << "EOF"
root::0:0:root:/root:/bin/ash
EOF

echo ""
echo "!-- Write Group file..."
cat > ${NET_OS}/etc/fstab << "EOF"
# file-system  mount-point  type   options  dump    fsck
#                                                   order

rootfs          /           auto    defaults        1   1
proc            /proc       proc    defaults        0   0
sysfs           /sys        sysfs   defaults        0   0
devpts          /dev/pts    devpts  gid=4,mode=620  0   0
tmpfs           /dev/shm    tmpfs   defaults        0   0
EOF

echo ""
echo "!-- Write Profile..."
cat > ${NET_OS}/etc/profile << "EOF"
export PATH=/bin:/usr/bin

if [ `id -u` -eq 0 ] ; then
    PATH=/bin:/sbin:/usr/bin:/usr/sbin
    unset HISTFILE
fi

export USER=`id -un`
export LOGNAME=$USER
export HOSTNAME=`/bin/hostname`
export HISTSIZE=1000
export PAGER='/bin/more'
export EDITOR='/bin/vi'
EOF

echo ""
echo "!-- Set Hostname..."
echo "net-linux" > ${NET_OS}/etc/HOSTNAME

echo ""
echo "!-- Set Issue..."
cat > ${NET_OS}/etc/issue << "EOF"
liNux v20230204 \r on an \m
EOF

echo ""
echo "!-- Create Inittab..."
cat > ${NET_OS}/etc/inittab << "EOF"
::sysinit:/etc/rc.d/startup

tty1::respawn:/sbin/getty 38400 tty1
tty2::respawn:/sbin/getty 38400 tty2
tty3::respawn:/sbin/getty 38400 tty3
tty4::respawn:/sbin/getty 38400 tty4
tty5::respawn:/sbin/getty 38400 tty5
tty6::respawn:/sbin/getty 38400 tty6

::shutdown:/etc/rc.d/shutdown
::ctrlaltdel:/sbin/reboot
EOF

echo ""
echo "!-- Set mdev.conf file"
cat > ${NET_OS}/etc/mdev.conf << "EOF"
# Devices:
# Syntax: %s %d:%d %s
# devices user:group mode

# null does already exist; therefore ownership has to
# be changed with command
null    root:root 0666  @chmod 666 $MDEV
zero    root:root 0666
grsec   root:root 0660
full    root:root 0666

random  root:root 0666
urandom root:root 0444
hwrandom root:root 0660

# console does already exist; therefore ownership has to
# be changed with command
console root:tty 0600 @mkdir -pm 755 fd && cd fd && for x
 ↪in 0 1 2 3 ; do ln -sf /proc/self/fd/$x $x; done

kmem    root:root 0640
mem     root:root 0640
port    root:root 0640
ptmx    root:tty 0666

# ram.*
ram([0-9]*)     root:disk 0660 >rd/%1
loop([0-9]+)    root:disk 0660 >loop/%1
sd[a-z].*       root:disk 0660 */lib/mdev/usbdisk_link
hd[a-z][0-9]*   root:disk 0660 */lib/mdev/ide_links

tty             root:tty 0666
tty[0-9]        root:root 0600
tty[0-9][0-9]   root:tty 0660
ttyO[0-9]*      root:tty 0660
pty.*           root:tty 0660
vcs[0-9]*       root:tty 0660
vcsa[0-9]*      root:tty 0660

ttyLTM[0-9]     root:dialout 0660 @ln -sf $MDEV modem
ttySHSF[0-9]    root:dialout 0660 @ln -sf $MDEV modem
slamr           root:dialout 0660 @ln -sf $MDEV slamr0
slusb           root:dialout 0660 @ln -sf $MDEV slusb0
fuse            root:root  0666

# misc stuff
agpgart         root:root 0660  >misc/
psaux           root:root 0660  >misc/
rtc             root:root 0664  >misc/

# input stuff
event[0-9]+     root:root 0640 =input/
ts[0-9]         root:root 0600 =input/

# v4l stuff
vbi[0-9]        root:video 0660 >v4l/
video[0-9]      root:video 0660 >v4l/

# load drivers for usb devices
usbdev[0-9].[0-9]       root:root 0660 */lib/mdev/usbdev
usbdev[0-9].[0-9]_.*    root:root 0660
EOF

echo ""
echo "!-- Set grub config"
cat > ${NET_OS}/boot/grub/grub.cfg << "EOF"

set dafault=0
set timeout=5

set root=(hd0,1)

menuentry "liNux v20230204" {
    linux   /boot/vmlinuz-6.1.9 root=/dev/sda1 ro quiet
}
EOF

echo ""
echo "!-- Init Log and Proper Permisssion"
touch ${NET_OS}/var/run/utmp ${NET_OS}/var/log/{btm,lastlog,wtmp}
chmod -v 664 ${NET_OS}/var/run/utmp ${NET_OS}/var/log/lastlog