import system.services show ServiceProvider ServiceHandler
import system.api.print show PrintService
import http
import net
import system
import certificate-roots

install-http --uri/string:
  s := HTTPProvider --uri=uri
  s.install

// HTTPProvider is a PrintService that prints to HTTP requests.
class HTTPProvider extends ServiceProvider
    implements PrintService ServiceHandler:

  client/http.Client
  clientURI/string

  constructor --uri/string:
    certificate-roots.install-common-trusted-roots
    network := net.open
    client = http.Client.tls network
    clientURI = uri

    super "system/print/pluggable/http" --major=0 --minor=1
    provides PrintService.SELECTOR --handler=this

  handle index/int arguments/any --gid/int --client/int -> any:
    if index == PrintService.PRINT-INDEX: return print arguments
    unreachable

  print message/string -> none:
    // Instead send over HTTP
    client.post-json --uri=clientURI message