/*
 * Copyright 2007 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package qrcode;

/**
 * See ISO 18004:2006 Annex D
 *
 * @author Sean Owen
 */
public final class Version {

  private static final Version[] VERSIONS = buildVersions();

  private final int versionNumber;
  private final ECBlocks[] ecBlocks;
  private final int totalCodewords;

  private Version(int versionNumber,
                  ECBlocks... ecBlocks) {
    this.versionNumber = versionNumber;
    this.ecBlocks = ecBlocks;
    int total = 0;
    int ecCodewords = ecBlocks[0].getECCodewordsPerBlock();
    ECB[] ecbArray = ecBlocks[0].getECBlocks();
    for (ECB ecBlock : ecbArray) {
      total += ecBlock.getCount() * (ecBlock.getDataCodewords() + ecCodewords);
    }
    this.totalCodewords = total;
  }

  public int getVersionNumber() {
    return versionNumber;
  }

  public int getTotalCodewords() {
    return totalCodewords;
  }

  public int getDimensionForVersion() {
    return 17 + 4 * versionNumber;
  }

  public ECBlocks getECBlocksForLevel(ErrorCorrectionLevel ecLevel) {
    return ecBlocks[ecLevel.ordinal()];
  }

  public static Version getVersionForNumber(int versionNumber) {
    if (versionNumber < 1 || versionNumber > 40) {
    	System.err.println("error: versionNumber < 1 || versionNumber > 40");
    }
    return VERSIONS[versionNumber - 1];
  }

  /**
   * <p>Encapsulates a set of error-correction blocks in one symbol version. Most versions will
   * use blocks of differing sizes within one version, so, this encapsulates the parameters for
   * each set of blocks. It also holds the number of error-correction codewords per block since it
   * will be the same across all blocks within one version.</p>
   */
  public static final class ECBlocks {
    private final int ecCodewordsPerBlock;
    private final ECB[] ecBlocks;

    ECBlocks(int ecCodewordsPerBlock, ECB... ecBlocks) {
      this.ecCodewordsPerBlock = ecCodewordsPerBlock;
      this.ecBlocks = ecBlocks;
    }

    public int getECCodewordsPerBlock() {
      return ecCodewordsPerBlock;
    }

    public int getNumBlocks() {
      int total = 0;
      for (ECB ecBlock : ecBlocks) {
        total += ecBlock.getCount();
      }
      return total;
    }

    public int getTotalECCodewords() {
      return ecCodewordsPerBlock * getNumBlocks();
    }

    public ECB[] getECBlocks() {
      return ecBlocks;
    }
  }

  /**
   * <p>Encapsulates the parameters for one error-correction block in one symbol version.
   * This includes the number of data codewords, and the number of times a block with these
   * parameters is used consecutively in the QR code version's format.</p>
   */
  public static final class ECB {
    private final int count;
    private final int dataCodewords;

    ECB(int count, int dataCodewords) {
      this.count = count;
      this.dataCodewords = dataCodewords;
    }

    public int getCount() {
      return count;
    }

    public int getDataCodewords() {
      return dataCodewords;
    }
  }

  @Override
  public String toString() {
    return String.valueOf(versionNumber);
  }

  /**
   * See ISO 18004:2006 6.5.1 Table 9
   */
  private static Version[] buildVersions() {
    return new Version[]{
        new Version(1,
            new ECBlocks(7, new ECB(1, 19)),
            new ECBlocks(10, new ECB(1, 16)),
            new ECBlocks(13, new ECB(1, 13)),
            new ECBlocks(17, new ECB(1, 9))),
        new Version(2,
            new ECBlocks(10, new ECB(1, 34)),
            new ECBlocks(16, new ECB(1, 28)),
            new ECBlocks(22, new ECB(1, 22)),
            new ECBlocks(28, new ECB(1, 16))),
        new Version(3,
            new ECBlocks(15, new ECB(1, 55)),
            new ECBlocks(26, new ECB(1, 44)),
            new ECBlocks(18, new ECB(2, 17)),
            new ECBlocks(22, new ECB(2, 13))),
        new Version(4,
            new ECBlocks(20, new ECB(1, 80)),
            new ECBlocks(18, new ECB(2, 32)),
            new ECBlocks(26, new ECB(2, 24)),
            new ECBlocks(16, new ECB(4, 9))),
        new Version(5,
            new ECBlocks(26, new ECB(1, 108)),
            new ECBlocks(24, new ECB(2, 43)),
            new ECBlocks(18, new ECB(2, 15), new ECB(2, 16)),
            new ECBlocks(22, new ECB(2, 11), new ECB(2, 12))),
        new Version(6,
            new ECBlocks(18, new ECB(2, 68)),
            new ECBlocks(16, new ECB(4, 27)),
            new ECBlocks(24, new ECB(4, 19)),
            new ECBlocks(28, new ECB(4, 15))),
        new Version(7,
            new ECBlocks(20, new ECB(2, 78)),
            new ECBlocks(18, new ECB(4, 31)),
            new ECBlocks(18, new ECB(2, 14), new ECB(4, 15)),
            new ECBlocks(26, new ECB(4, 13), new ECB(1, 14))),
        new Version(8,
            new ECBlocks(24, new ECB(2, 97)),
            new ECBlocks(22, new ECB(2, 38), new ECB(2, 39)),
            new ECBlocks(22, new ECB(4, 18), new ECB(2, 19)),
            new ECBlocks(26, new ECB(4, 14), new ECB(2, 15))),
        new Version(9,
            new ECBlocks(30, new ECB(2, 116)),
            new ECBlocks(22, new ECB(3, 36), new ECB(2, 37)),
            new ECBlocks(20, new ECB(4, 16), new ECB(4, 17)),
            new ECBlocks(24, new ECB(4, 12), new ECB(4, 13))),
        new Version(10,
            new ECBlocks(18, new ECB(2, 68), new ECB(2, 69)),
            new ECBlocks(26, new ECB(4, 43), new ECB(1, 44)),
            new ECBlocks(24, new ECB(6, 19), new ECB(2, 20)),
            new ECBlocks(28, new ECB(6, 15), new ECB(2, 16))),
        new Version(11,
            new ECBlocks(20, new ECB(4, 81)),
            new ECBlocks(30, new ECB(1, 50), new ECB(4, 51)),
            new ECBlocks(28, new ECB(4, 22), new ECB(4, 23)),
            new ECBlocks(24, new ECB(3, 12), new ECB(8, 13))),
        new Version(12,
            new ECBlocks(24, new ECB(2, 92), new ECB(2, 93)),
            new ECBlocks(22, new ECB(6, 36), new ECB(2, 37)),
            new ECBlocks(26, new ECB(4, 20), new ECB(6, 21)),
            new ECBlocks(28, new ECB(7, 14), new ECB(4, 15))),
        new Version(13,
            new ECBlocks(26, new ECB(4, 107)),
            new ECBlocks(22, new ECB(8, 37),  new ECB(1, 38)),
            new ECBlocks(24, new ECB(8, 20),  new ECB(4, 21)),
            new ECBlocks(22, new ECB(12, 11), new ECB(4, 12))),
        new Version(14,
            new ECBlocks(30, new ECB(3, 115), new ECB(1, 116)),
            new ECBlocks(24, new ECB(4, 40),  new ECB(5, 41)),
            new ECBlocks(20, new ECB(11, 16), new ECB(5, 17)),
            new ECBlocks(24, new ECB(11, 12), new ECB(5, 13))),
        new Version(15,
            new ECBlocks(22, new ECB(5, 87),  new ECB(1, 88)),
            new ECBlocks(24, new ECB(5, 41),  new ECB(5, 42)),
            new ECBlocks(30, new ECB(5, 24),  new ECB(7, 25)),
            new ECBlocks(24, new ECB(11, 12), new ECB(7, 13))),
        new Version(16,
            new ECBlocks(24, new ECB(5, 98),  new ECB(1, 99)),
            new ECBlocks(28, new ECB(7, 45),  new ECB(3, 46)),
            new ECBlocks(24, new ECB(15, 19), new ECB(2, 20)),
            new ECBlocks(30, new ECB(3, 15),  new ECB(13, 16))),
        new Version(17,
            new ECBlocks(28, new ECB(1, 107), new ECB(5, 108)),
            new ECBlocks(28, new ECB(10, 46), new ECB(1, 47)),
            new ECBlocks(28, new ECB(1, 22),  new ECB(15, 23)),
            new ECBlocks(28, new ECB(2, 14),  new ECB(17, 15))),
        new Version(18,
            new ECBlocks(30, new ECB(5, 120), new ECB(1, 121)),
            new ECBlocks(26, new ECB(9, 43),  new ECB(4, 44)),
            new ECBlocks(28, new ECB(17, 22), new ECB(1, 23)),
            new ECBlocks(28, new ECB(2, 14),  new ECB(19, 15))),
        new Version(19,
            new ECBlocks(28, new ECB(3, 113), new ECB(4, 114)),
            new ECBlocks(26, new ECB(3, 44),  new ECB(11, 45)),
            new ECBlocks(26, new ECB(17, 21), new ECB(4, 22)),
            new ECBlocks(26, new ECB(9, 13),  new ECB(16, 14))),
        new Version(20,
            new ECBlocks(28, new ECB(3, 107), new ECB(5, 108)),
            new ECBlocks(26, new ECB(3, 41),  new ECB(13, 42)),
            new ECBlocks(30, new ECB(15, 24), new ECB(5, 25)),
            new ECBlocks(28, new ECB(15, 15), new ECB(10, 16))),
        new Version(21,
            new ECBlocks(28, new ECB(4, 116), new ECB(4, 117)),
            new ECBlocks(26, new ECB(17, 42)),
            new ECBlocks(28, new ECB(17, 22), new ECB(6, 23)),
            new ECBlocks(30, new ECB(19, 16), new ECB(6, 17))),
        new Version(22,
            new ECBlocks(28, new ECB(2, 111), new ECB(7, 112)),
            new ECBlocks(28, new ECB(17, 46)),
            new ECBlocks(30, new ECB(7, 24),  new ECB(16, 25)),
            new ECBlocks(24, new ECB(34, 13))),
        new Version(23,
            new ECBlocks(30, new ECB(4, 121), new ECB(5, 122)),
            new ECBlocks(28, new ECB(4, 47),  new ECB(14, 48)),
            new ECBlocks(30, new ECB(11, 24), new ECB(14, 25)),
            new ECBlocks(30, new ECB(16, 15), new ECB(14, 16))),
        new Version(24,
            new ECBlocks(30, new ECB(6, 117), new ECB(4, 118)),
            new ECBlocks(28, new ECB(6, 45),  new ECB(14, 46)),
            new ECBlocks(30, new ECB(11, 24), new ECB(16, 25)),
            new ECBlocks(30, new ECB(30, 16), new ECB(2, 17))),
        new Version(25,
            new ECBlocks(26, new ECB(8, 106), new ECB(4, 107)),
            new ECBlocks(28, new ECB(8, 47),  new ECB(13, 48)),
            new ECBlocks(30, new ECB(7, 24),  new ECB(22, 25)),
            new ECBlocks(30, new ECB(22, 15), new ECB(13, 16))),
        new Version(26,
            new ECBlocks(28, new ECB(10, 114), new ECB(2, 115)),
            new ECBlocks(28, new ECB(19, 46),  new ECB(4, 47)),
            new ECBlocks(28, new ECB(28, 22),  new ECB(6, 23)),
            new ECBlocks(30, new ECB(33, 16),  new ECB(4, 17))),
        new Version(27,
            new ECBlocks(30, new ECB(8, 122),  new ECB(4, 123)),
            new ECBlocks(28, new ECB(22, 45),  new ECB(3, 46)),
            new ECBlocks(30, new ECB(8, 23),   new ECB(26, 24)),
            new ECBlocks(30, new ECB(12, 15),  new ECB(28, 16))),
        new Version(28,
            new ECBlocks(30, new ECB(3, 117),  new ECB(10, 118)),
            new ECBlocks(28, new ECB(3, 45),   new ECB(23, 46)),
            new ECBlocks(30, new ECB(4, 24),   new ECB(31, 25)),
            new ECBlocks(30, new ECB(11, 15),  new ECB(31, 16))),
        new Version(29,
            new ECBlocks(30, new ECB(7, 116),  new ECB(7, 117)),
            new ECBlocks(28, new ECB(21, 45),  new ECB(7, 46)),
            new ECBlocks(30, new ECB(1, 23),   new ECB(37, 24)),
            new ECBlocks(30, new ECB(19, 15),  new ECB(26, 16))),
        new Version(30,
            new ECBlocks(30, new ECB(5, 115),  new ECB(10, 116)),
            new ECBlocks(28, new ECB(19, 47),  new ECB(10, 48)),
            new ECBlocks(30, new ECB(15, 24),  new ECB(25, 25)),
            new ECBlocks(30, new ECB(23, 15),  new ECB(25, 16))),
        new Version(31,
            new ECBlocks(30, new ECB(13, 115), new ECB(3, 116)),
            new ECBlocks(28, new ECB(2, 46),   new ECB(29, 47)),
            new ECBlocks(30, new ECB(42, 24),  new ECB(1, 25)),
            new ECBlocks(30, new ECB(23, 15),  new ECB(28, 16))),
        new Version(32,
            new ECBlocks(30, new ECB(17, 115)),
            new ECBlocks(28, new ECB(10, 46), new ECB(23, 47)),
            new ECBlocks(30, new ECB(10, 24), new ECB(35, 25)),
            new ECBlocks(30, new ECB(19, 15), new ECB(35, 16))),
        new Version(33,
            new ECBlocks(30, new ECB(17, 115), new ECB(1, 116)),
            new ECBlocks(28, new ECB(14, 46),  new ECB(21, 47)),
            new ECBlocks(30, new ECB(29, 24),  new ECB(19, 25)),
            new ECBlocks(30, new ECB(11, 15),  new ECB(46, 16))),
        new Version(34,
            new ECBlocks(30, new ECB(13, 115), new ECB(6, 116)),
            new ECBlocks(28, new ECB(14, 46),  new ECB(23, 47)),
            new ECBlocks(30, new ECB(44, 24),  new ECB(7, 25)),
            new ECBlocks(30, new ECB(59, 16),  new ECB(1, 17))),
        new Version(35,
            new ECBlocks(30, new ECB(12, 121), new ECB(7, 122)),
            new ECBlocks(28, new ECB(12, 47),  new ECB(26, 48)),
            new ECBlocks(30, new ECB(39, 24),  new ECB(14, 25)),
            new ECBlocks(30, new ECB(22, 15),  new ECB(41, 16))),
        new Version(36,
            new ECBlocks(30, new ECB(6, 121),  new ECB(14, 122)),
            new ECBlocks(28, new ECB(6, 47),   new ECB(34, 48)),
            new ECBlocks(30, new ECB(46, 24),  new ECB(10, 25)),
            new ECBlocks(30, new ECB(2, 15),   new ECB(64, 16))),
        new Version(37,
            new ECBlocks(30, new ECB(17, 122), new ECB(4, 123)),
            new ECBlocks(28, new ECB(29, 46),  new ECB(14, 47)),
            new ECBlocks(30, new ECB(49, 24),  new ECB(10, 25)),
            new ECBlocks(30, new ECB(24, 15),  new ECB(46, 16))),
        new Version(38,
            new ECBlocks(30, new ECB(4, 122), new ECB(18, 123)),
            new ECBlocks(28, new ECB(13, 46), new ECB(32, 47)),
            new ECBlocks(30, new ECB(48, 24), new ECB(14, 25)),
            new ECBlocks(30, new ECB(42, 15), new ECB(32, 16))),
        new Version(39,
            new ECBlocks(30, new ECB(20, 117), new ECB(4, 118)),
            new ECBlocks(28, new ECB(40, 47),  new ECB(7, 48)),
            new ECBlocks(30, new ECB(43, 24),  new ECB(22, 25)),
            new ECBlocks(30, new ECB(10, 15),  new ECB(67, 16))),
        new Version(40,
            new ECBlocks(30, new ECB(19, 118), new ECB(6, 119)),
            new ECBlocks(28, new ECB(18, 47),  new ECB(31, 48)),
            new ECBlocks(30, new ECB(34, 24),  new ECB(34, 25)),
            new ECBlocks(30, new ECB(20, 15),  new ECB(61, 16)))
    };
  }

}
