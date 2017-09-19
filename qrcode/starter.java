package qrcode;

public class starter {
  public static void main(String[] args) {
  QRCode code = null;
  try {
    code = QREncoder.encode("Hi, this is a pretty long string to be encoded");
  } catch (WriterException e) {
    e.printStackTrace();
  }

  System.out.println(code.toString());
  }
}
