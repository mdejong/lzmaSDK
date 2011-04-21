This directory contains the LZMA SDK customized for an embedded system (iPhone/iOS)
Only the file extraction logic was included, all code related to creating
compressed streams was removed. Also, CRC validation was removed to
improve performance. This is based on lzma release 9.21 beta.

Embedded version does not need exe branch predictors.

Bra.c
Bcj2.c
Bra86.c

File List:

7zBuf.c		7zCrc.c		7zFile.c	7zStream.c	Archive		LzHash.h	LzmaDec.h
7zBuf.h		7zCrc.h		7zFile.h	7zVersion.h	CpuArch.h	LzmaDec.c	Types.h

Removed:

(XZ file format support)
Xz.*

MtCoder.c

Ppmd7Enc.c

Sha256.*

lzma Serch (encode) functions

rm LzFind*

rm Threads.*

rm Bra*

rm Bcj2.*

rm lzmaEnc* lzma2Enc.*

To update to a new version of the LZMA SDK, use the update.tcl to copy over those
files that were used in this version.

