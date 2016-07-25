This directory contains the LZMA SDK customized for an embedded system (iPhone/iOS)
Only the file extraction logic was included, all code related to creating
compressed streams was removed. CRC validation was removed to
improve performance. In addition, large file support was added so that iOS
is able to decompress files as large as 650 megs using memory mapped IO.
This code is based on lzma release 9.22 beta.

Note that when incorporating the code into a new project, copy only the
LZMASDK directory in the Classes subdir into your iOS project. All of the
other files in this example iOS app exist just to illustrate how to use
the SDK code in the LZMASDK directory.

The code was modified as follows:

Embedded version does not need exe branch predictors.

Bra.c
Bcj2.c
Bra86.c

File List:

7zBuf.c
7zCrc.c
7zFile.c
7zStream.c
LzHash.h
LzmaDec.h
7zBuf.h
7zCrc.h
7zFile.h
7zVersion.h
CpuArch.h
LzmaDec.c
Types.h

Removed:

(XZ file format support)
Xz.*

MtCoder.c

Ppmd7Enc.c

Sha256.*

lzma Search (encode) functions

rm LzFind*

rm Threads.*

rm Bra*

rm Bcj2.*

rm lzmaEnc* lzma2Enc.*

The 7z.h and 7zIn.c files were modified to support memory mapping the dictionary
cache file so that large files can be decompressed without having to break archives
up into blocks. While splitting into blocks makes it possible to create an archive
with lots of little files in different blocks, it makes compression much worse.
Large file support makes it possible to get maximum compression by putting all
the files into 1 block, but the downside is that the decode process is slower
due to the use of memory mapped IO writes. See the k7zUnpackMapDictionaryInMemoryMaxNumBytes
define in 7z.h if you want to change the size at which memory mapped IO kicks in,
currently archives larger than 1 meg will use memory mapped IO.

To update to a new version of the LZMA SDK, use the update.tcl to copy over those
files that were used in this version. Note that updating is not trivial since files
that have been modified would need to be merged.

The example iOS application shows how to decode a small file and how some very large
files can be decoded without using up all the memory in an iOS application. Previously,
an archive with a dictionary around 30 to 40 megs would crash an iOS device, with
the mmap logic files as large as 650 megs can be decoded without going over the
virtual memory limits on iOS. Note that this large file support depends on how large
a memory space a single process can map under iOS, so keeping a very large single
archive under 400 megs is likely to be a good idea.

See LICENSE.txt for license details.

