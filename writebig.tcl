# Write a really massive 1024 megabyte file (1 gigabyte) that contains all zero bytes.
# This file size was chosen because it is larger than the 700 megabyte
# mapped file size limit in iOS.

#set outfilename "onegig.data"
#set numMegs 1024

#set outfilename "halfgig.data"
#set numMegs 512

set outfilename "sixfiftymeg.data"
set numMegs 650

set oneK ""
for {set i 0} {$i < 1024} {incr i} {
  append oneK "\0"
}
set oneMeg [string repeat $oneK 1024]
if {[string length $oneMeg] != (1024 * 1024)} {
  puts "len is [string length $oneMeg], not one meg"
  exit 0
}

set fd [open $outfilename w]
fconfigure $fd -encoding binary -translation binary
for {set i 0} {$i < $numMegs} {incr i} {
  puts -nonewline $fd $oneMeg
}
close $fd

set len [file size $outfilename]
set expected_len [expr {1024 * 1024 * $numMegs}]
if {$len != $expected_len} {
  puts "expected len = $expected_len, len was $len"
  exit 0
}

puts "wrote $outfilename"
puts "$numMegs megs"

