autoload -Uz colors && colors
setopt prompt_subst

PROMPT='%F{bold green}%n%f@%F{magenta}%m%f:%F{yellow}%~%f
%F{magenta}>%f '
