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
    -d --sock trumpet1.ctl -f trumpet1.rc
${VDESWITCH} \
    -d --sock trumpet2.ctl -f trumpet2.rc
${VDESWITCH} \
    -d --sock trumpet3.ctl -f trumpet3.rc
${VDESWITCH} \
    -d --sock trumpet4.ctl -f trumpet4.rc

dpipe vde_plug trumpet1.ctl -p 3 = vde_plug trumpet2.ctl -p 1 &
dpipe vde_plug trumpet2.ctl -p 3 = vde_plug trumpet3.ctl -p 1 &
dpipe vde_plug trumpet3.ctl -p 3 = vde_plug trumpet4.ctl -p 1 &

for i in $(seq 1 6); 
do
	cp ${IMAGE} num${i}.image
done

screen ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=trumpet1.ctl,port=1,vlan=0 \
    -net nic,macaddr=fe:fe:00:0a:01:01,model=e1000,vlan=0 \
    -nographic num1.image
sleep 15

screen ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=trumpet1.ctl,port=2,vlan=0 \
    -net nic,macaddr=fe:fe:00:0a:02:01,model=e1000,vlan=0 \
    -nographic num2.image
sleep 15

screen ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=trumpet2.ctl,port=2,vlan=0 \
    -net nic,macaddr=fe:fe:00:0a:03:01,model=e1000,vlan=0 \
    -nographic num3.image
sleep 15

screen ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=trumpet3.ctl,port=2,vlan=0 \
    -net nic,macaddr=fe:fe:00:0a:04:01,model=e1000,vlan=0 \
    -nographic num4.image
sleep 15

screen ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=trumpet4.ctl,port=2,vlan=0 \
    -net nic,macaddr=fe:fe:00:0a:05:01,model=e1000,vlan=0 \
    -nographic num5.image
sleep 15

screen ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=trumpet4.ctl,port=3,vlan=0 \
    -net nic,macaddr=fe:fe:00:0a:06:01,model=e1000,vlan=0 \
    -nographic num6.image
