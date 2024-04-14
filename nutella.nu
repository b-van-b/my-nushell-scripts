export def main [] nothing -> nothing {

}

export def list [] nothing -> table {
    choco list | split row "\r\n" | range 1..-2 | split column ' ' | rename package version
}

export def outdated [] {
    print 'Getting list of outdated packages...'
    let package_list: table = (
        choco outdated | 
        split row "\r\n\r\n" | 
        get 1 | 
        split row "\r\n" | 
        split column '|' | 
        rename package current available pinned
    )
    if ($package_list | is-empty) {
        print 'No outdated packages found!'
        return
    }

    print $'You have (ansi wu)($package_list | length)(ansi reset) outdated packages.'
    print $package_list
    let selection: list = (
        $package_list | 
        get package | 
        input list -m 'Select packages to upgrade (a to select all)'
    )
    if ($selection | is-empty) {
        print 'No packages selected!'
        return
    }
    
    gsudo choco upgrade ...$selection
}
