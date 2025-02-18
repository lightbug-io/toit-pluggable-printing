# Toit Pluggable Printing

A printing package, that produces toit `print`ed output in various different locations but overriding the [PrintService](https://libs.toit.io/system/api/print/class-PrintService).

This package was mostly used during some initial hardware development phases while standard toit `print` would get in the way of other things such as UART communication.

Can target:
 - default: Calls `print_` which is what toit normally does
 - http: Sends the output over HTTP POST request
 - httpsrv: Hosts a web server displaying prints on a page
 - multi: Can be used to combine multiple targets
 - null: A service that does nothing
 - uart: Sends the output over UART
 - udp: Sends the output over UDP
