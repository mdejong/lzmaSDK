# Write a really massive 1024 megabyte file (1 gigabyte) that contains all zero bytes.
# This file size was chosen because it is larger than the 700 megabyte
# mapped file size limit in iOS.

set oneK ""
for {set i 0} {$i < 1024} {incr i} {
  append oneK "\0"
}
set oneMeg [string repeat $oneK 1024]
if {[string length $oneMeg] != (1024 * 1024)} {
  puts "len is [string length $oneMeg], not one meg"
  exit 0
}

set filename big.data
set fd [open $filename w]
fconfigure $fd -encoding binary -translation binary
for {set i 0} {$i < 1024} {incr i} {
  puts -nonewline $fd $oneMeg
}
close $fd

set len [file size $filename]
if {$len != (1024 * 1024 * 1024)} {
  puts "len is $len, not one gig"
  exit 0
}

puts "wrote $filename"

