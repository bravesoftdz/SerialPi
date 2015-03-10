#SerialPi#
Internal project, to be used in Symphony POS software

##Delphi_Test##
contains small test program showing network capture of serial data into an Edit box

##SerialPi##
Lazarus Daemon to run on Raspberry Pi as a service.
This captures incoming data on a serial port (USB0 or whatever) and holds it ready for a connection to come and claim it.
Presently just spitting to a local file

##Arduino_Test##
Means of simluating serial data into the Pi, so we don't need to keep expensive serial balances handy while testing/rollout etc :-)
