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
    -d --sock chain1.ctl -f chain.rc
${VDESWITCH} \
    -d --sock chain2.ctl -f chain.rc
dpipe vde_plug chain1.ctl -p 3 = vde_plug chain2.ctl -p 3 &

for i in $(seq 1 4); 
do
	cp ${IMAGE} num${i}.image
done

screen ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=chain1.ctl,port=1,vlan=0 \
    -net nic,macaddr=fe:fe:00:0a:01:01,model=e1000,vlan=0 \
    -nographic num1.image
    #-net nic,model=e1000,vlan=2 -net tap,ifname=tapwrt1,vlan=2 \
    #-gdb tcp::8001 \
sleep 5

screen ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=chain1.ctl,port=2,vlan=0 \
    -net nic,macaddr=fe:fe:00:0a:02:01,model=e1000,vlan=0 \
    -nographic num2.image
    #-net nic,model=e1000,vlan=2 -net tap,ifname=tapwrt2,vlan=2 \
    #-gdb tcp::8004 \
sleep 5

screen ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=chain2.ctl,port=2,vlan=0 \
    -net nic,macaddr=fe:fe:00:0a:03:01,model=e1000,vlan=0 \
    -nographic num3.image
    #-net nic,model=e1000,vlan=2 -net tap,ifname=tapwrt3,vlan=2 \
    #-gdb tcp::8005 \
sleep 5

screen ${QEMU} \
    -enable-kvm \
    -no-acpi -m 32M \
    -net vde,sock=chain2.ctl,port=1,vlan=0 \
    -net nic,macaddr=fe:fe:00:0a:04:01,model=e1000,vlan=0 \
    -nographic num4.image
    #-net nic,model=e1000,vlan=2 -net tap,ifname=tapwrt3,vlan=2 \
    #-gdb tcp::8005 \
sleep 5

#for i in $(seq 1 3); 
#do
#    ${SUDO} /sbin/ifconfig tapwrt${i} inet 192.168.1${i}.1 up
#done

exit 0

${WF} --daemon -v num3.ctl:num5.ctl -l 60
${WF} --daemon -v num4.ctl:num5.ctl -l 60

${WF} --daemon -v num1.ctl:num3.ctl -l 60
${WF} --daemon -v num2.ctl:num4.ctl -l 60
