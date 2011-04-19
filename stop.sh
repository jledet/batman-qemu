#!/bin/bash

QEMU=$(which qemu-kvm)
VDE=$(which vde_switch)
WF=$(which wirefilter)

sudo killall -q ${QEMU}
killall -q ${VDE}
killall -q ${WF}

sudo killall -q -9 ${QEMU}
