import system.services show ServiceProvider ServiceHandler
import system.api.print show PrintService

install-multi --services/List:
  s := MultiProvider --services=services
  s.install

class MultiProvider extends ServiceProvider
    implements PrintService ServiceHandler:

  print-services/List

  constructor --services/List:
    // Make sure we have at least one type
    if services.size == 0:
      throw "No services provided"
    // Make sure all services are print-services
    services.do: | service |
      if not service is PrintService:
        throw "Service is not a PrintService"

    print-services = services

    super "system/print/pluggable/multi" --major=1 --minor=2
    provides PrintService.SELECTOR --handler=this

  handle index/int arguments/any --gid/int --client/int -> any:
    if index == PrintService.PRINT-INDEX: return print arguments
    unreachable

  print message/string -> none:
    // Print to all the services..
    print-services.do: | service |
      service.print message

