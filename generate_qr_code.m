function generate_qr_code(str)
## Load zxing library
javaaddpath ("zxing_qrcode.jar");

encoder = javaObject ("qrcode.QREncoder");
java_get ("qrcode.QREncoder", "encode")
javaMethod ("encode", "qrcode.QREncoder", "Hallo");
endfunction
