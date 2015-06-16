rmmod kvm-intel
rmmod kvm
rmmod microcode
rmmod lp
rmmod parport
rmmod 8021q
rmmod mrp
rmmod garp
rmmod bridge
rmmod stp
rmmod llc
rmmod psmouse

modprobe msr
modprobe xt_state
modprobe xt_LOG
modprobe xt_limit
modprobe xt_tcpudp
modprobe nf_conntrack_ipv4
modprobe nf_defrag_ipv4
modprobe xt_comment
modprobe nf_conntrack
modprobe ip6table_filter
modprobe ip6_tables
modprobe iptable_filter
modprobe ip_tables
modprobe x_tables

iptables-restore < /etc/iptables/rules.v4
ip6tables-restore < /etc/iptables/rules.v6

cpuseq=$((`ls -lh /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq | wc -l`-1))
for i in `seq 0 "$cpuseq"`; do cpufreq-set -g performance -c $i; echo -n `cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq` > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq; done;

/usr/libexec/tuned/pmqos-static.py cpu_dma_latency=0

sysctl -w kernel.kexec_load_disabled=1
sysctl -w net.netfilter.nf_conntrack_tcp_be_liberal=0
sysctl -w net.netfilter.nf_conntrack_tcp_loose=0

rmmod ixgbe
sleep 1
modprobe ixgbe_zc MQ=0 DCA=1 RSS=1 InterruptThrottleRate=956 LRO=0
for D in $(ls /proc/irq)
do
    if [[ -x "/proc/irq/$D" && $D != "0" ]]
    then
        echo $D
        echo 1 > /proc/irq/$D/smp_affinity
    fi
done
for i in `dmesg | grep -E ixgbe | grep -E irq | cut -d ' ' -f 8`; do echo 2 > /proc/irq/$i/smp_affinity; done;
for i in `pgrep rcu` ; do taskset -pc 0 $i ; done
echo 1 > /sys/bus/workqueue/devices/writeback/cpumask
echo 0 > /sys/bus/workqueue/devices/writeback/numa
echo 8 > /sys/class/net/eth2/queues/rx-0/rps_cpus
ethtool -G eth2 rx 32768

/etc/init.d/mozdefmq start

exit 0
