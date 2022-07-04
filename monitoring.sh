#!bin/bash

os_info=$(uname -a)

n_physical_processors=$(grep "physical id" /proc/cpuinfo | uniq | wc -l)
n_logic_processors=$(nproc --all)

total_ram=$(free -m | awk 'NR == 2 {printf("%dMB"),$2}')
used_ram=$(free -m | awk 'NR == 2 {print ($3)}')
ram_usage_percent=$(free | awk 'NR == 2 {printf("%.2f"), ($3*100)/$2}')
processor_util_rate=$(top -bn1 | grep Cpu | sed "s/.*, *\([0-9.]*\)%* id.*/\1/"| \
awk '{print 100 - $1 "%"}')

formated_total_disk=$(lsblk | awk 'NR == 2 {printf ("%dGb"),$4}')
total_disk=$(lsblk | awk 'NR == 2 {printf ("%d"),$4}')
used_disk=$(df -BM | grep /dev/ | grep -v /boot | awk '{used_mb += $3} END {printf ("%d"),used_mb}')
disk_usage_percent=$(((used_disk / 10) / total_disk))

last_boot=$(uptime -s | head -c-4)
lvm_use=$(if [ $(lsblk | grep lvm | wc -l) -eq 0 ]; then echo no; else echo yes; fi)
net_active_connections=$(netstat -t | grep ESTABLISHED | wc -l)
users_n=$(who | wc -l)

host_ip=$(hostname --all-ip-address | awk '{print ($1)}')
host_mac=$(ip a | grep ether | awk '{print ($2)}')

sudo_cmd=$(journalctl _COMM=sudo| grep ': TTY' | wc -l)

echo ""
echo "        ****Here comes crontab deamon. Every 10 mins with interesting info****"
echo ""

echo "Architecture: $os_info"
echo "CPU physical: $n_physical_processors"
echo "CPU logic: $n_logic_processors"
echo "Memory Usage: $used_ram/$total_ram ($ram_usage_percent%)"
echo "Disk Usage: $used_disk/$formated_total_disk ($disk_usage_percent%)"
echo "CPU load: $processor_util_rate"
echo "Last boot: $last_boot"
echo "LVM use: $lvm_use"
echo "Connection TCP: $net_active_connections ESTABLISHED"
echo "User log: $users_n"
echo "Network: IP $host_ip ($host_mac)"
echo "Sudo: $sudo_cmd cmd"


