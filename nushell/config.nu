
$env.config.buffer_editor = 'nvim'
$env.XDG_CONFIG_HOME = "C:/Users/yajan_fomjbwp/dotfiles"

$env.STARSHIP_SHELL = "nu"


def create_left_prompt [] {
    starship prompt --cmd-duration $env.CMD_DURATION_MS $'--status=($env.LAST_EXIT_CODE)'
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = { || create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = ""

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = ""
$env.PROMPT_INDICATOR_VI_INSERT = ": "
$env.PROMPT_INDICATOR_VI_NORMAL = "〉"
$env.PROMPT_MULTILINE_INDICATOR = "::: "

$env.config = {
    shell_integration: {
        osc133: false
    }
}

def fo [] {
  let fzfoutput = fzf --height 60% --layout reverse --border | str trim
  if (not ($fzfoutput | is-empty)) {
    nvim $fzfoutput
  }
}

def gbs [] {
  let branch = (
    git branch |
    split row "\n" |
    str trim |
    where ($it !~ '\*') |
    where ($it != '') |
    str join (char nl) |
    fzf --no-multi
  )
  if $branch != '' {
    git switch $branch
  }
}

def hs [] {
    let selected = (history | get command | to text | fzf )
    if $selected != '' {
        nu -c $selected
    }
}

source ~/.zoxide.nu
