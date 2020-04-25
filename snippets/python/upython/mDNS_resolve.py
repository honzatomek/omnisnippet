import network
import slimDNS
network.WLAN(network.AP_IF).active(False) # <-- AP must be deactivated for address resolution to work
sta_if = network.WLAN(network.STA_IF)
local_addr = sta_if.ifconfig()[0]
server = slimDNS.SlimDNSServer(local_addr, "micropython")
ip = server.resolve_mdns_address("raspberrypi4.local")
print("{0}.{1}.{2}.{3}".format(ip[0], ip[1], ip[2], ip[3]))
