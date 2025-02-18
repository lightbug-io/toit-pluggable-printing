# Toit Pluggable Printing

A printing package, that produces toit `print`ed output in various different locations but overriding the [PrintService](https://libs.toit.io/system/api/print/class-PrintService).

This package was mostly used during some initial hardware development phases while standard toit `print` would get in the way of other things such as UART communication.

Can target:
 - default: Calls `print_` which is what toit normally does
 - http: Sends the output over HTTP POST request
 - httpsrv: Hosts a web server displaying prints on a page
 - multi: Can be used to combine multiple targets
 - nulled: A service that does nothing
 - uart: Sends the output over UART
 - udp: Sends the output over UDP

## Example usage

Checkout the `example` directory for runnable examples.

And example running only the `udp` service.

```toit
import pluggable-printing
import log

main:
  pluggable-printing.install-udp --port=18018
  log.info "Starting"
```

An example running the `udp` and `httpsrv` services on ports `18018` port with a buffer size of 10 for the web server would look like this:

```toit
import pluggable-printing
import log

main:
  pluggable-printing.install-multi --services=[
    UDPProvider --port=18018,
    HTTPServerProvider --port=18018 --buffer-size=10,
  ]
  log.info "Starting"
```