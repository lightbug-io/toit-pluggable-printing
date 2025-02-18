import pluggable-printing
import log

main:
  pluggable-printing.install-udp --port=18018

  log.info "Starting" // You will not see this in the console
  while true:
    log.info "Hello" // You will not see this in the console
    sleep (Duration --ms=1000)