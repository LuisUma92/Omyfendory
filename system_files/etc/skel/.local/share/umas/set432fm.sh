sudo ip address flush enp5s0f3u1
sudo ip address add 10.168.218.28 dev enp5s0f3u1
sudo ip route add 10.168.218.1 dev enp5s0f3u1
sudo ip route add default via 10.168.218.1
ping -c 5 8.8.8.8
