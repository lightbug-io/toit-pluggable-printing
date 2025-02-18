import pluggable-printing
import log

main:
  pluggable-printing.install-multi --services=[
    pluggable-printing.UDPProvider --port=18018,
    pluggable-printing.HTTPServerProvider --port=18018 --buffer-size=10,
  ]

  log.info "Starting" // You will not see this in the console
  while true:
    log.info "Hello" // You will not see this in the console
    sleep (Duration --ms=1000)