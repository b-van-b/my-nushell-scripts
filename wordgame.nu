# Cheat at Wordle-like word games! Enter the clues you have so far and get a list of possible words.
#
# Examples:
#
# > wordgame --green .oa.. --first 5
# Count: 31
# ╭───┬───────╮
# │ 0 │ roams │
# │ 1 │ poach │
# │ 2 │ loans │
# │ 3 │ foams │
# │ 4 │ toads │
# ╰───┴───────╯
# 
# > wordgame --black blinaegutsyh --yellow [. cw . cr r] --green ....d
# Count: 1
# ╭───┬───────╮
# │ 0 │ crowd │
# ╰───┴───────╯
export def main [
    --green(-g): string    # Green (right letter, right place) letters in position. Use '.' for an unknown letter.
    --yellow(-y): list     # Yellow (right letter, wrong place) letters in their incorrect positions. Multiple letters can be input for each position.
    --black(-b): string    # Black (absent) letters. List all letters that aren't in the word.
    --number(-n): int = 10 # The maximum number of possible words to list.
] {
    let data_path: string = ('~/.config/wordgame_words.txt' | path expand)
    mut words: list<string> = (open $data_path | lines)
    # green
    if ($green | is-not-empty) {
        $words = ($words | where {|w| $w =~ $'^($green)$'})
    }
    # black
    if ($black | is-not-empty) {
        $words = ($words | where {|w| $w !~ $'[($black)]'})
    }
    # yellow
    if ($yellow | is-not-empty) {
        let y_in: list = ($yellow | where {|w| $w != '.'} | str join | split chars)
        let y_out: string = ($yellow | each {|e| if $e == '.' {'.'} else {$'[^($e)]'}} | str join)
        $words = ($words | where {|w| $w =~ $'^($y_out)$'})
        $words = ($words | where {|w| $y_in | all {|c| $c in $w}})
    }

    print $'Count: ($words | length)'
    print ($words | shuffle | first $number)
}
