# use nutella.nu

export def main [] {
    help nutella
}

# return true if this is an admin session or if gsudo is installed
def can-admin [] nothing -> bool {
    (which gsudo | is-not-empty) or ((do {net session} | complete | get exit_code) == 0)
}

# Returns the list of packages installed with Chocolatey as a table.
export def list [] nothing -> table {
    choco list | split row "\r\n" | range 1..-2 | split column ' ' | rename package version
}

# Gets a list of outdated Chocolatey packages and lets the user select which ones to update.
export def outdated [] {
    # check for admin privileges
    if not (can-admin) {
        error make {
            msg: 'This action requires admin privileges.'
            help: 'Please run as admin or install gsudo (https://gerardog.github.io/gsudo/).'
        }
    }
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
