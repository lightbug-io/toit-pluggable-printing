import system.services show ServiceProvider ServiceHandler
import system.api.print show PrintService
import uart
import gpio

install-uart-print-service --port/uart.Port:
  s := UARTPrintServiceProvider --port=port
  s.install

// UARTPrintServiceProvider is a PrintService that prints over UART.
// Allows an existing UART port to be used.
class UARTPrintServiceProvider extends ServiceProvider
    implements PrintService ServiceHandler:

  uartPort/uart.Port
  stringPrefix/string
  stringSuffix/string

  constructor --port/uart.Port --prefix="" --suffix="\n":
    stringPrefix = prefix
    stringSuffix = suffix
    if port == null:
      // TODO maybe provide a different way of selecting defaults? OR just remove the default...
      uartPort= uart.Port
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
      uartPort = port

    super "system/print/pluggable/uart" --major=0 --minor=1
    provides PrintService.SELECTOR --handler=this

  handle index/int arguments/any --gid/int --client/int -> any:
    if index == PrintService.PRINT-INDEX: return print arguments
    unreachable

  print message/string -> none:
    uartPort.out.write (stringPrefix + message + stringSuffix).to-byte-array
