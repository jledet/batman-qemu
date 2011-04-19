#!/bin/sh
QEMU=$(which qemu-kvm)
VDESWITCH=$(which vde_switch)
WF=$(which wirefilter)
IMAGE=../backfire/bin/x86/openwrt-x86-generic-combined-squashfs.img

# you can set this if you are running as root and don't need sudo:
# SUDO=
SUDO=sudo

./stop.sh

echo "Creating switches"
for i in $(seq 1 3); 
do
	${VDESWITCH} \
		-d --hub --sock num${i}.ctl -f hub${i}.rc

done

echo "Startin machines"
for i in $(seq 1 5); 
do
	cp ${IMAGE} num${i}.image
done

screen ${SUDO} ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=num1.ctl,port=1,vlan=0 -net nic,macaddr=fe:fe:00:0a:01:01,model=e1000,vlan=0 \
    -nographic num1.image
sleep 5

screen ${SUDO} ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=num1.ctl,port=2,vlan=0 -net nic,macaddr=fe:fe:00:0a:02:01,model=e1000,vlan=0 \
    -nographic num2.image
sleep 5

screen ${SUDO} ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=num2.ctl,port=1,vlan=0 -net nic,macaddr=fe:fe:00:0a:03:01,model=e1000,vlan=0 \
    -nographic num3.image
sleep 5

screen ${SUDO} ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=num2.ctl,port=2,vlan=0 -net nic,macaddr=fe:fe:00:0a:04:01,model=e1000,vlan=0 \
    -nographic num4.image
sleep 5

screen ${SUDO} ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=num3.ctl,port=1,vlan=0 -net nic,macaddr=fe:fe:00:0a:05:01,model=e1000,vlan=0 \
    -nographic num5.image
sleep 5

for i in $(seq 1 5); 
do
    ${SUDO} /sbin/ifconfig tapwrt${i} inet 192.168.1${i}.1 up
done

${WF} --daemon -v num1.ctl:num3.ctl -l 20 -D 5 -b 5K -d 5
${WF} --daemon -v num2.ctl:num3.ctl -l 20 -D 5 -b 5K -d 5

exit 0

${WF} --daemon -v num3.ctl:num5.ctl
${WF} --daemon -v num4.ctl:num5.ctl

${WF} --daemon -v num1.ctl:num3.ctl
${WF} --daemon -v num2.ctl:num4.ctl
