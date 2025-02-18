import system.services show ServiceProvider ServiceHandler
import system.api.print show PrintService

// installNullPrintService installs the NullPrintServiceProvider.
installNullPrintService:
  s := NullPrintServiceProvider
  s.install

// NullPrintServiceProvider is a PrintService that does nothing.
// This remove many messages from being printed to UART, however not everything.
//
// See https://discord.com/channels/918498540232253480/918498540232253483/1292782359648796684
// The best way to remove all UART output is to "change the default console UART/pins using a custom envelope."
// This is the "safest choice anyway as print_ bypasses the print-service. And error messages from the esp-idf aren't intercepted either"
class NullPrintServiceProvider extends ServiceProvider
    implements PrintService ServiceHandler:

  constructor:
    super "system/print/pluggable/null" --major=1 --minor=2
    provides PrintService.SELECTOR --handler=this

  handle index/int arguments/any --gid/int --client/int -> any:
    if index == PrintService.PRINT-INDEX: return print arguments
    unreachable

  print message/string -> none:
    // Do nothing