# use nutella.nu

export def main [] {
    help nutella
}

# determine if this is an admin session or if gsudo is installed
# ADMIN = this is an admin session
# GSUDO = can get admin with gsudo
# NONE = unable to get admin
def get-admin [] nothing -> string {
    if ((do {net session} | complete | get exit_code) == 0) {
        'ADMIN'
    } else if (which gsudo | is-not-empty) {
        'GSUDO'
    } else {
        'NONE'
    }
}

# Returns the list of packages installed with Chocolatey as a table.
export def list [] nothing -> table {
    choco list | lines | range 1..-2 | split column ' ' | rename package version
}

# Gets a list of outdated Chocolatey packages and lets the user select which ones to update.
export def outdated [] {
    # check for admin privileges
    let admin: string = (get-admin)
    if admin == 'NONE' {
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
    # stop if no outdated packages found
    if ($package_list | is-empty) or ('Chocolatey has determined 0 package(s) are outdated. ' in $package_list.package) {
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
    
    match $admin {
        'ADMIN' => (choco upgrade ...$selection)
        'GSUDO' => (gsudo choco upgrade ...$selection)
        _ => (error make {
            msg: $'Attempted to run choco with invalid admin state: "($admin)"'
            })
    }
}
