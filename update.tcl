# Find all the .h or .c files in C/ and subdirs and copy over only those files
# that already exist in ../Classes/LZMASDK/

set cfiles [glob -type f -nocomplain C/*.{h,c} C/*/*.{h,c}]

foreach file $cfiles {
  #puts "file = $file"

  set tail [file tail $file]

  set path [file join .. Classes LZMASDK $tail]

  set copied 0

  if {[file exists $path]} {
    #puts "EXISTS $path"
    puts "cp $file $path"
    file copy -force $file $path
    set copied 1
  }

  # Also check ../Classes/LZMASDK/Util/7z
  set path [file join .. Classes LZMASDK Util 7z $tail]

  if {[file exists $path]} {
    #puts "EXISTS $path"
    puts "cp $file $path"
    file copy -force $file $path
    set copied 1
  }


  if {!$copied} {
    puts "IGNORE $file"
  }

}

