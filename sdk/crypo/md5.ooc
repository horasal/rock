import structs/ArrayList

MD5: class {
    _K := static const [
    0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee ,
    0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501 ,
    0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be ,
    0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821 ,
    0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa ,
    0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8 ,
    0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed ,
    0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a ,
    0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c ,
    0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70 ,
    0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05 ,
    0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665 ,
    0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039 ,
    0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1 ,
    0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1 ,
    0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391 ]

    chunkSize := static const 64

    A, B, C, D: UInt

    rem: UInt8[64]
    remSize: UInt = 0

    dataLength: UInt64 = 0

    init: func{
        (A, B, C, D) = (0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476)
    }

    reset: func{
        (A, B, C, D) = (0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476)
        remSize = 0
        dataLength = 0
    }

    block: func(data: UInt8*, length: UInt64) -> UInt{
        if(length < chunkSize) return length

        pos := 0

        // cache
        (a, b, c, d) := (A, B, C, D)

        while(pos < length){
            (aa, bb, cc, dd) := (a, b, c, d)
            X := data as UInt32*

            //Round 1.

            a += (((c ^ d) & b) ^ d) + X[0] + 3614090360
            a = (a<<7 | a>>(32-7)) + b

            d += (((b ^ c) & a) ^ c) + X[1] + 3905402710
            d = (d<<12 | d>>(32-12)) + a

            c += (((a ^ b) & d) ^ b) + X[2] + 606105819
            c = (c<<17 | c>>(32-17)) + d

            b += (((d ^ a) & c) ^ a) + X[3] + 3250441966
            b = (b<<22 | b>>(32-22)) + c

            a += (((c ^ d) & b) ^ d) + X[4] + 4118548399
            a = (a<<7 | a>>(32-7)) + b

            d += (((b ^ c) & a) ^ c) + X[5] + 1200080426
            d = (d<<12 | d>>(32-12)) + a

            c += (((a ^ b) & d) ^ b) + X[6] + 2821735955
            c = (c<<17 | c>>(32-17)) + d

            b += (((d ^ a) & c) ^ a) + X[7] + 4249261313
            b = (b<<22 | b>>(32-22)) + c

            a += (((c ^ d) & b) ^ d) + X[8] + 1770035416
            a = (a<<7 | a>>(32-7)) + b

            d += (((b ^ c) & a) ^ c) + X[9] + 2336552879
            d = (d<<12 | d>>(32-12)) + a

            c += (((a ^ b) & d) ^ b) + X[10] + 4294925233
            c = (c<<17 | c>>(32-17)) + d

            b += (((d ^ a) & c) ^ a) + X[11] + 2304563134
            b = (b<<22 | b>>(32-22)) + c

            a += (((c ^ d) & b) ^ d) + X[12] + 1804603682
            a = (a<<7 | a>>(32-7)) + b

            d += (((b ^ c) & a) ^ c) + X[13] + 4254626195
            d = (d<<12 | d>>(32-12)) + a

            c += (((a ^ b) & d) ^ b) + X[14] + 2792965006
            c = (c<<17 | c>>(32-17)) + d

            b += (((d ^ a) & c) ^ a) + X[15] + 1236535329
            b = (b<<22 | b>>(32-22)) + c

            // Round 2.

            a += (((b ^ c) & d) ^ c) + X[(1+5*0) & 15] + 4129170786
            a = (a<<5 | a>>(32-5)) + b

            d += (((a ^ b) & c) ^ b) + X[(1+5*1) & 15] + 3225465664
            d = (d<<9 | d>>(32-9)) + a

            c += (((d ^ a) & b) ^ a) + X[(1+5*2) & 15] + 643717713
            c = (c<<14 | c>>(32-14)) + d

            b += (((c ^ d) & a) ^ d) + X[(1+5*3) & 15] + 3921069994
            b = (b<<20 | b>>(32-20)) + c

            a += (((b ^ c) & d) ^ c) + X[(1+5*4) & 15] + 3593408605
            a = (a<<5 | a>>(32-5)) + b

            d += (((a ^ b) & c) ^ b) + X[(1+5*5) & 15] + 38016083
            d = (d<<9 | d>>(32-9)) + a

            c += (((d ^ a) & b) ^ a) + X[(1+5*6) & 15] + 3634488961
            c = (c<<14 | c>>(32-14)) + d

            b += (((c ^ d) & a) ^ d) + X[(1+5*7) & 15] + 3889429448
            b = (b<<20 | b>>(32-20)) + c

            a += (((b ^ c) & d) ^ c) + X[(1+5*8) & 15] + 568446438
            a = (a<<5 | a>>(32-5)) + b

            d += (((a ^ b) & c) ^ b) + X[(1+5*9) & 15] + 3275163606
            d = (d<<9 | d>>(32-9)) + a

            c += (((d ^ a) & b) ^ a) + X[(1+5*10) & 15] + 4107603335
            c = (c<<14 | c>>(32-14)) + d

            b += (((c ^ d) & a) ^ d) + X[(1+5*11) & 15] + 1163531501
            b = (b<<20 | b>>(32-20)) + c

            a += (((b ^ c) & d) ^ c) + X[(1+5*12) & 15] + 2850285829
            a = (a<<5 | a>>(32-5)) + b

            d += (((a ^ b) & c) ^ b) + X[(1+5*13) & 15] + 4243563512
            d = (d<<9 | d>>(32-9)) + a

            c += (((d ^ a) & b) ^ a) + X[(1+5*14) & 15] + 1735328473
            c = (c<<14 | c>>(32-14)) + d

            b += (((c ^ d) & a) ^ d) + X[(1+5*15) & 15] + 2368359562
            b = (b<<20 | b>>(32-20)) + c

            // Round 3.

            a += (b ^ c ^ d) + X[(5+3*0) & 15] + 4294588738
            a = (a<<4 | a>>(32-4)) + b

            d += (a ^ b ^ c) + X[(5+3*1) & 15] + 2272392833
            d = (d<<11 | d>>(32-11)) + a

            c += (d ^ a ^ b) + X[(5+3*2) & 15] + 1839030562
            c = (c<<16 | c>>(32-16)) + d

            b += (c ^ d ^ a) + X[(5+3*3) & 15] + 4259657740
            b = (b<<23 | b>>(32-23)) + c

            a += (b ^ c ^ d) + X[(5+3*4) & 15] + 2763975236
            a = (a<<4 | a>>(32-4)) + b

            d += (a ^ b ^ c) + X[(5+3*5) & 15] + 1272893353
            d = (d<<11 | d>>(32-11)) + a

            c += (d ^ a ^ b) + X[(5+3*6) & 15] + 4139469664
            c = (c<<16 | c>>(32-16)) + d

            b += (c ^ d ^ a) + X[(5+3*7) & 15] + 3200236656
            b = (b<<23 | b>>(32-23)) + c

            a += (b ^ c ^ d) + X[(5+3*8) & 15] + 681279174
            a = (a<<4 | a>>(32-4)) + b

            d += (a ^ b ^ c) + X[(5+3*9) & 15] + 3936430074
            d = (d<<11 | d>>(32-11)) + a

            c += (d ^ a ^ b) + X[(5+3*10) & 15] + 3572445317
            c = (c<<16 | c>>(32-16)) + d

            b += (c ^ d ^ a) + X[(5+3*11) & 15] + 76029189
            b = (b<<23 | b>>(32-23)) + c

            a += (b ^ c ^ d) + X[(5+3*12) & 15] + 3654602809
            a = (a<<4 | a>>(32-4)) + b

            d += (a ^ b ^ c) + X[(5+3*13) & 15] + 3873151461
            d = (d<<11 | d>>(32-11)) + a

            c += (d ^ a ^ b) + X[(5+3*14) & 15] + 530742520
            c = (c<<16 | c>>(32-16)) + d

            b += (c ^ d ^ a) + X[(5+3*15) & 15] + 3299628645
            b = (b<<23 | b>>(32-23)) + c

            // Round 4.

            a += (c ^ (b | ~d)) + X[(7*0) & 15] + 4096336452
            a = (a<<6 | a>>(32-6)) + b

            d += (b ^ (a | ~c)) + X[(7*1) & 15] + 1126891415
            d = (d<<10 | d>>(32-10)) + a

            c += (a ^ (d | ~b)) + X[(7*2) & 15] + 2878612391
            c = (c<<15 | c>>(32-15)) + d

            b += (d ^ (c | ~a)) + X[(7*3) & 15] + 4237533241
            b = (b<<21 | b>>(32-21)) + c

            a += (c ^ (b | ~d)) + X[(7*4) & 15] + 1700485571
            a = (a<<6 | a>>(32-6)) + b

            d += (b ^ (a | ~c)) + X[(7*5) & 15] + 2399980690
            d = (d<<10 | d>>(32-10)) + a

            c += (a ^ (d | ~b)) + X[(7*6) & 15] + 4293915773
            c = (c<<15 | c>>(32-15)) + d

            b += (d ^ (c | ~a)) + X[(7*7) & 15] + 2240044497
            b = (b<<21 | b>>(32-21)) + c

            a += (c ^ (b | ~d)) + X[(7*8) & 15] + 1873313359
            a = (a<<6 | a>>(32-6)) + b

            d += (b ^ (a | ~c)) + X[(7*9) & 15] + 4264355552
            d = (d<<10 | d>>(32-10)) + a

            c += (a ^ (d | ~b)) + X[(7*10) & 15] + 2734768916
            c = (c<<15 | c>>(32-15)) + d

            b += (d ^ (c | ~a)) + X[(7*11) & 15] + 1309151649
            b = (b<<21 | b>>(32-21)) + c

            a += (c ^ (b | ~d)) + X[(7*12) & 15] + 4149444226
            a = (a<<6 | a>>(32-6)) + b

            d += (b ^ (a | ~c)) + X[(7*13) & 15] + 3174756917
            d = (d<<10 | d>>(32-10)) + a

            c += (a ^ (d | ~b)) + X[(7*14) & 15] + 718787259
            c = (c<<15 | c>>(32-15)) + d

            b += (d ^ (c | ~a)) + X[(7*15) & 15] + 3951481745
            b = (b<<21 | b>>(32-21)) + c

            a += aa
            b += bb
            c += cc
            d += dd

            pos += chunkSize
        }

        (A, B, C, D) = (a, b, c, d)

        length - pos
    }

    write: func (b: UInt8*, length: UInt64) {
        dataLength += length

        "datalength: %d" printfln(dataLength)

        startPos := 0
        if(remSize > 0){
            startPos = chunkSize - remSize >  length ? length : chunkSize - remSize
            for(i in 0..startPos){
                rem[i + remSize] = b[i]
            }
            remSize += startPos
            if(remSize == chunkSize) block(rem as UInt8*, chunkSize)
        }
        if(length - startPos > 0){
            remSize = block(b[startPos]&, length - startPos)
            if(remSize > 0){
                for(i in 0..remSize){
                    rem[i] = b[length - ( remSize - i )]
                }
            }
        }
    }

    checksum: func{
        lengthinBit: UInt64 = (8 * dataLength) & 0xFFFFFFFFFFFFFFFF
        tmp := ArrayList<UInt8> new()
        tmp add(0x80)
        for(i in 0..63) tmp add(0)
        if(dataLength % 64 < 56){
            write(tmp data as UInt8*, 56 - dataLength%64)
        } else {
            write(tmp data as UInt8*, 64 + 56 - dataLength%64)
        }
        write(lengthinBit& as UInt8*, 8)
    }
}
