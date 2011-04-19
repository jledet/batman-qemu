#!/bin/sh
QEMU=$(which qemu-kvm)
VDESWITCH=$(which vde_switch)
WF=$(which wirefilter)
IMAGE=../backfire/bin/x86/openwrt-x86-generic-combined-squashfs.img

# you can set this if you are running as root and don't need sudo:
# SUDO=
SUDO=sudo

./stop.sh

${VDESWITCH} \
    -d --sock ab.ctl -f ab.rc

for i in $(seq 1 3); 
do
	cp ${IMAGE} num${i}.image
done

screen ${SUDO} ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=ab.ctl,port=1,vlan=0 -net nic,macaddr=fe:fe:00:0a:01:01,model=e1000,vlan=0 \
    -net nic,model=e1000,vlan=2 -net tap,ifname=tapwrt1,vlan=2 \
    -gdb tcp::8001 \
    -nographic num1.image
sleep 5

screen ${SUDO} ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=ab.ctl,port=2,vlan=0 -net nic,macaddr=fe:fe:00:0a:02:01,model=e1000,vlan=0 \
    -net nic,model=e1000,vlan=2 -net tap,ifname=tapwrt2,vlan=2 \
    -gdb tcp::8004 \
    -nographic num2.image
sleep 5

screen ${SUDO} ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=ab.ctl,port=3,vlan=0 -net nic,macaddr=fe:fe:00:0a:03:01,model=e1000,vlan=0 \
    -net nic,model=e1000,vlan=2 -net tap,ifname=tapwrt3,vlan=2 \
    -gdb tcp::8005 \
    -nographic num3.image
sleep 5

for i in $(seq 1 3); 
do
    ${SUDO} /sbin/ifconfig tapwrt${i} inet 192.168.1${i}.1 up
done

exit 0

${WF} --daemon -v num3.ctl:num5.ctl -l 60
${WF} --daemon -v num4.ctl:num5.ctl -l 60

${WF} --daemon -v num1.ctl:num3.ctl -l 60
${WF} --daemon -v num2.ctl:num4.ctl -l 60
