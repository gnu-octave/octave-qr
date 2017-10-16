# Octave QR

Some GNU Octave code to create QR Codes, based upon
https://github.com/zxing/zxing.

## News 2017-10-17

- Still not completely independent of Java
  (this projects still uses `qrcode.ReedSolomonEncoder`).
  But most of the code is **pure** m-code.
- There are lots of `for`-loops to vectorize.
- You can now run arbitrary examples:

      plot_qr_code ( ...
        qr_code (["https://www.octave.org", ...
          " - Scientific Programming Language", ...
          " - Soon having some QR-Code feature!!!"]));

  ![GNU Octave generated QR Code](doc/qrcode.png)
