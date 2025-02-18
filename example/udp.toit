import pluggable-printing
import log

main:
  pluggable-printing.install-udp --port=18018
  log.info "Starting" // You will not see this in the console, only as a UDP packet