import system.services show ServiceProvider ServiceHandler
import system.api.print show PrintService
import uart
import gpio

install-uart --port/uart.Port:
  s := UartProvider --port=port
  s.install

// UartProvider is a PrintService that prints over UART.
// Allows an existing UART port to be used.
class UartProvider extends ServiceProvider
    implements PrintService ServiceHandler:

  uart-port/uart.Port
  string-prefix/string
  string-suffix/string

  constructor --port/uart.Port --prefix="" --suffix="\n":
    string-prefix = prefix
    string-suffix = suffix
    if port == null:
      // TODO maybe provide a different way of selecting defaults? OR just remove the default...
      uart-port= uart.Port
        // ESP32-C3 https://docs.espressif.com/projects/esp-at/en/latest/esp32c3/Get_Started/Hardware_connection.html#esp32-c3-series
        // UART0 GPIO20 (RX) GPIO21 (TX)
        // --rx=gpio.Pin 20
        // --tx=gpio.Pin 21
        // ESP32-C6 https://docs.espressif.com/projects/esp-at/en/latest/esp32c6/Get_Started/Hardware_connection.html#esp32c6-4mb-series
        // UART0 GPIO17 (RX) GPIO16 (TX) Defaults
        --rx=gpio.Pin 17
        --tx=gpio.Pin 16
        --baud_rate=115200
    else:
      uart-port = port

    super "system/print/pluggable/uart" --major=0 --minor=1
    provides PrintService.SELECTOR --handler=this

  handle index/int arguments/any --gid/int --client/int -> any:
    if index == PrintService.PRINT-INDEX: return print arguments
    unreachable

  print message/string -> none:
    uart-port.out.write (string-prefix + message + string-suffix).to-byte-array
