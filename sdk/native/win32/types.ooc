
/*
 * Win32 type covers
 */

version(windows) {

    include windows

    LocaleId: cover from LCID

    /*
     * File handle
     */
    Handle: cover from HANDLE
    INVALID_HANDLE_VALUE: extern Handle

    /*
     * Large integers
     */
    LargeInteger: cover from LARGE_INTEGER {
        lowPart : extern(LowPart)  Long
        highPart: extern(HighPart) Long
        quadPart: extern(QuadPart) LLong
    }

    /*
     * Unsigned large integers
     */
    ULargeInteger: cover from ULARGE_INTEGER {
        lowPart : extern(LowPart)  Long
        highPart: extern(HighPart) Long
        quadPart: extern(QuadPart) LLong
    }

    toLLong: func ~twoPartsLargeInteger (lowPart, highPart: Long) -> LLong {
        li: LargeInteger
        li lowPart  = lowPart
        li highPart = highPart
        return li quadPart
    }

    toULLong: func ~twoPartsLargeInteger (lowPart, highPart: Long) -> ULLong {
        li: ULargeInteger
        li lowPart  = lowPart
        li highPart = highPart
        return li quadPart
    }

    /*
     * FILETIME is, in fact, an Int64 that stores the number of
     * 100-nanoseconds intervals from January 1st, 1601 (according to the MSDN)
     */
    FileTime: cover from FILETIME {
        lowDateTime:    extern(dwLowDateTime)  Long // DWORD
        highDateTime:   extern(dwHighDateTime) Long // DWORD
    }

    /*
     * source: http://frenk.wordpress.com/2009/12/14/convert-filetime-to-unix-timestamp/
     * thanks, Francesco De Vittori from Lugano, Switzerland!
     */
    toTimestamp: func ~fromFiletime (fileTime: FileTime) -> Long {
        // takes the last modified date
        date, adjust: LargeInteger
        date lowPart  = fileTime lowDateTime
        date highPart = fileTime highDateTime

        // 100-nanoseconds = milliseconds * 10000
        adjust quadPart = 11644473600000 * 10000;

        // removes the diff between 1970 and 1601
        date quadPart -= adjust quadPart

        // converts back from 100-nanoseconds to seconds
        return date quadPart / 10000000;
    }

    BYTE: extern cover from UInt8
    WORD: extern cover from Int
    DWORD: extern cover from Long
    LPTSTR: extern cover from CString

    MAKEWORD: extern func (low, high: BYTE) -> WORD

    /*
     * Defines the coordinates of a character cell in a console screen buffer. 
     * The origin of the coordinate system (0,0) is at the top, left cell of the buffer.
     */
    Coord: cover from COORD{
        x: extern Short
        y: extern Short
    }
    PCoord: cover from Coord*

    /*
     * Defines the coordinates of the upper left and lower right corners of a rectangle.
     */
    SmallRect: cover from SMALL_RECT{
        left: extern Short
        top: extern Short
        right: extern Short
        bottom: extern Short
    }

    ConsoleScreenBufferInfo: cover from CONSOLE_SCREEN_BUFFER_INFO{
        size: extern Coord
        cursorPosition: extern Coord
        attributes: extern UInt16
        window: extern SmallRect
        maximumWindowSize: extern Coord
    }
    PConsoleScreenBufferInfo: cover from ConsoleScreenBufferInfo*

    FOREGROUND_BLUE            : extern UInt16
    FOREGROUND_GREEN           : extern UInt16
    FOREGROUND_RED             : extern UInt16
    FOREGROUND_INTENSITY       : extern UInt16
    BACKGROUND_BLUE            : extern UInt16
    BACKGROUND_GREEN           : extern UInt16
    BACKGROUND_RED             : extern UInt16
    BACKGROUND_INTENSITY       : extern UInt16
    COMMON_LVB_LEADING_BYTE    : extern UInt16
    COMMON_LVB_TRAILING_BYTE   : extern UInt16
    COMMON_LVB_GRID_HORIZONTAL : extern UInt16
    COMMON_LVB_GRID_LVERTICAL  : extern UInt16
    COMMON_LVB_GRID_RVERTICAL  : extern UInt16
    COMMON_LVB_REVERSE_VIDEO   : extern UInt16
    COMMON_LVB_UNDERSCORE      : extern UInt16
}
