import system.services show ServiceProvider ServiceHandler
import system.api.print show PrintService

// installDefaultPrintService installs the DefaultPrintServiceProvider.
installDefaultPrintService:
  s := DefaultPrintServiceProvider
  s.install

class DefaultPrintServiceProvider extends ServiceProvider
    implements PrintService ServiceHandler:

  constructor:
    super "system/print/pluggable/default" --major=1 --minor=2
    provides PrintService.SELECTOR --handler=this

  handle index/int arguments/any --gid/int --client/int -> any:
    if index == PrintService.PRINT-INDEX: return print arguments
    unreachable

  print message/string -> none:
    // This is essentially what toit does out of the box
    print_ message