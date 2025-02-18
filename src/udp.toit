import system.services show ServiceProvider ServiceHandler
import system.api.print show PrintService
import net
import net.udp

DEFAULT_PORT ::= 18018
DEFAULT_MASK ::= "255.255.255.255"

install-udp-print-service --port=DEFAULT_PORT --mask=DEFAULT_MASK:
  s := UDPPrintServiceProvider --port=port --mask=mask
  s.install

// UDPPrintServiceProvider is a PrintService that prints to UDP packets.
class UDPPrintServiceProvider extends ServiceProvider
    implements PrintService ServiceHandler:

  address/net.SocketAddress
  socket/udp.Socket

  constructor --port=DEFAULT_PORT --mask=DEFAULT_MASK:
    address = net.SocketAddress
      net.IpAddress.parse mask
      port
    network := net.open
    socket = network.udp_open --port=port
    socket.broadcast = true

    super "system/print/pluggable/udp" --major=0 --minor=1
    provides PrintService.SELECTOR --handler=this

  handle index/int arguments/any --gid/int --client/int -> any:
    if index == PrintService.PRINT-INDEX: return print arguments
    unreachable

  print message/string -> none:
    socket.send
      udp.Datagram message.to-byte-array address
