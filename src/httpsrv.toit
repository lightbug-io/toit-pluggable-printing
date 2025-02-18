import monitor
import system.services show ServiceProvider ServiceHandler
import system.api.print show PrintService
import http
import net
import system
import log
import monitor

install-http-server port/int=18018 buffer-size/int=10:
  s := HttpServerProvider --port=port --buffer-size=buffer-size
  s.install

// Hosts a small HTTP server that serves the print buffer
class HttpServerProvider extends ServiceProvider
    implements PrintService ServiceHandler:

  srv-port /int
  // Buffer for storing the recent prints
  buffered-prints /List
  // Index of the oldest print in the buffer
  start-index /int := 0

  constructor --port/int=18018 --buffer-size/int=10:
    buffered-prints = List buffer-size
    srv-port = port

    super "system/print/pluggable/httpsrv" --major=0 --minor=1
    provides PrintService.SELECTOR --handler=this

    task:: serveHttp

  handle index/int arguments/any --gid/int --client/int -> any:
    if index == PrintService.PRINT-INDEX: return print arguments
    unreachable

  print message/string -> none:
    addToBuffer message

  addToBuffer message/string -> none:
    buffered-prints[start-index] = message
    if start-index == buffered-prints.size - 1:
      start-index = 0
    else:
      start-index = start-index + 1

  getBuffer -> List:
    return (buffered-prints[start-index..buffered-prints.size] + buffered-prints[0..start-index])

  getAndClearBuffer -> List:
    l := getBuffer
    start-index = 0
    buffered-prints.fill null
    return l

  // Serve the print buffer on HTTP
  serveHttp:
    log.debug "Starting log HTTP server on port $srv-port"
    network := net.open
    tcp_socket := network.tcp_listen srv-port
    // Only log INFO level server messages (especially as these come back through this log server..)
    server := http.Server --logger=(log.Logger log.INFO-LEVEL log.DefaultTarget) --max-tasks=4
    server.listen tcp_socket:: | request/http.RequestIncoming writer/http.ResponseWriter |
      resource := request.query.resource
      if resource == "/":
        html := """<html><body><h1>Logs</h1><div id="l"></div>
    <script>
    let fetching = false;
    function fl() {
        if (fetching) return;
        fetching = true;
        fetch('http://$(network.address):$(srv-port)/get')
        .then(r => r.text())
        .then(r => {
            const d = document.getElementById('l');
            const l = r.split('\\n');
            l.reverse().forEach(ll => {
            const p = document.createElement('p');
            p.textContent = ll;
            d.prepend(p);
            });
        })
        .catch(e => console.error(e))
        .finally(() => fetching = false);
    }
    setInterval(fl, 1500);
    fl();
    </script>
    </body></html>"""
        writer.headers.set "Content-Type" "text/html"
        writer.headers.set "Content-Length" html.size.stringify
        writer.write-headers 200
        writer.out.write html
      if resource == "/get":
        writer.headers.set "Content-Type" "text/plain"
        writer.headers.set "Access-Control-Allow-Origin" "*"
        writer.write-headers 200
        msg := ""
        getAndClearBuffer.do: | message |
          if message:
            msg = "$message\n" + msg
        writer.out.write msg
      else :
        writer.headers.set "Content-Type" "text/plain"
        writer.write_headers 404
        writer.out.write "Not found\n"
      writer.close