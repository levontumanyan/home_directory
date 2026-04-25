autoload -Uz colors && colors

# Parts of the prompt
HOST_PART="%{$fg_bold[blue]%}%m"
USER_PART="%{$fg_bold[green]%}%n"
ARROW_PART="%{$fg_bold[red]%}➜"
DIR_PART="%{$fg_bold[yellow]%}%~"
END_PART="%{$reset_color%}"

NEWLINE=$'\n$'

# Combine for final prompt
PROMPT="${USER_PART}@${HOST_PART} ${ARROW_PART} ${DIR_PART} ${NEWLINE} ${END_PART}"
