# use linetools.nu *

export def main [] {
    help linetools
}

# Returns a regular expression for detecting a number of newlines
# independent of operating system. Supports newlines in the style
# of Windows (\r\n), Linux (\n), and old Macintosh (\r). For 
# consecutive newlines, assumes that they are all of the same type.
#
# Examples:
#
# eol   -> (\r\n|\r|\n)
# eol 2 -> ((\r\n){2}|\r{2}|\n{2})
export def eol [
        n: int = 1 # number of newlines to check for
    ]: nothing -> string {
    if $n < 1 {
        error make {
            msg: '$n should be no less than 1',
            label: {
                text: '$n < 1',
                span: (metadata $n).span
            }
        }
    }
    if $n == 1 {
        '(\r\n|\r|\n)'
    } else {
        $"\(\(\r\n\){($n)}|\r{($n)}|\n{($n)}\)"
    }
}

# Split a string into rows separated by an arbitrary number of 
# newlines. Supports the following newline types: 
# Windows (\r\n), Linux (\n), old Macintosh (\r)
# When splitting text separated by multiple newlines, newlines
# are assumed to be of the same type.
#
# Examples:
# 
# "line 1\r\nline 2\n\nline 4" | split lines
# ╭───┬────────╮
# │ 0 │ line 1 │
# │ 1 │ line 2 │
# │ 2 │        │
# │ 3 │ line 4 │
# ╰───┴────────╯
# 
# "line 1\r\nline 2\n\nline 4" | split lines 2
# ╭───┬────────╮
# │ 0 │ line 1 │
# │   │ line 2 │
# │ 1 │ line 4 │
# ╰───┴────────╯
export def "split lines" [
        eols: int = 1 # number of newlines to split on
        --number(-n): int # split into maximum number of items
    ]: [list -> list, string -> list] {
    let lines = $in
    if ($number | is-empty) {
        $lines | split row -r (eol $eols)
    } else {
        $lines | split row -r (eol $eols) -n $number
    }
}
