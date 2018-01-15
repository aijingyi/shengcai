#!/bin/bash
# For mips test outside the company...

. $SHENGCAIROOT/testcases/common.sh
setup



hostname=`hostname`
infodir=hwc-$hostname
cd $SHENGCAIROOT/results/
[ -d $infodir ] && rm -rf $infodir
mkdir $infodir
# CPU
cpu_info()
{
echo 'Getting CPU info'
cp /proc/cpuinfo $infodir
lscpu > $infodir/lscpu
}
# Memory
mem_info()
{
echo 'Getting memory info'
cp /proc/meminfo $infodir
free -m > $infodir/free-m
}
# PCI device
pci_info()
{
echo 'Getting PCI info'
lspci -vvv > $infodir/lspci-vvv
}
# Block devices
block_dev_info()
{
echo 'Getting block device info'
for blc in `lsblk | grep ^[a-z] |grep -v sr | awk '{print $1}'`
    do
    smartctl -a /dev/$blc > $infodir/smartctl-a-$blc
    #hdparm -i /dev/$blc > $infodir/hdparm-i-$blc
    hdparm -Tt /dev/$blc > $infodir/hdparm-Tt-$blc
    #hdparm -I /dev/$blc > $infodir/hdparm-I-$blc
    done

fdisk -l > $infodir/fdisk-l
}
# Network
net_info()
{
echo 'Getting net connection info'
ifconfig -a > $infodir/ifconfig-a
for dev in `ifconfig -a | grep -v ^' ' | grep -v ^$ |grep -v lo | awk '{print $1}'`
    do 
    ethtool $dev > $infodir/ethtool-$dev
    #ethtool -i $dev > $infodir/ethtool-i-$dev
    done
}
# Input
other_dev_info()
{
echo 'Getting other device info'
cp /proc/bus/input/devices $infodir/
}
# Module
mod_info()
{
echo 'Getting module info'
lsmod > $infodir/lsmod
for mod in `lsmod | awk '{print $1}' | tail -n +2`
    do
    modinfo $mod > $infodir/modinfo-$mod
    done
}

log_info()
{
cp /root/install.log $infodir
cp /root/install.log.syslog $infodir
cp /proc/cgroups $infodir
cp /var/log/boot.log $infodir
cp /etc/securetty $infodir
cp /var/log/secure $infodir

}


cpu_info
mem_info
pci_info
block_dev_info
net_info
other_dev_info
#mod_info
log_info
tar zcf $infodir.tar.gz $infodir
