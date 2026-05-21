# dreamzsh/plugins/node/plugin.zsh

(( $+commands[node] )) || return 0

alias n='npm'
alias ni='npm install'
alias nid='npm install --save-dev'
alias nig='npm install -g'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrs='npm run start'
alias nrt='npm run test'
alias nrc='npm run check'
alias nrl='npm run lint'
alias nrm='npm remove'
alias nu='npm update'
alias nup='npm update --save'
alias nout='npm outdated'
alias nls='npm list --depth=0'
alias ninit='npm init -y'
alias npub='npm publish'
alias nwho='npm whoami'
alias nlg='npm ls -g --depth=0'
alias nci='npm ci'

(( $+commands[yarn] )) && {
  alias y='yarn'
  alias ya='yarn add'
  alias yad='yarn add --dev'
  alias yr='yarn remove'
  alias yi='yarn install'
  alias yrb='yarn run build'
  alias yrd='yarn run dev'
  alias yrs='yarn run start'
  alias yrt='yarn run test'
  alias yrl='yarn run lint'
  alias yup='yarn upgrade'
  alias ywhy='yarn why'
  alias ydlx='yarn dlx'
}

(( $+commands[pnpm] )) && {
  alias pn='pnpm'
  alias pni='pnpm install'
  alias pna='pnpm add'
  alias pnad='pnpm add --save-dev'
  alias pnrm='pnpm remove'
  alias pnr='pnpm run'
  alias pnrd='pnpm run dev'
  alias pnrb='pnpm run build'
  alias pnup='pnpm update'
  alias pndlx='pnpm dlx'
}

(( $+commands[nvm] )) && {
  alias nvm-ls='nvm ls'
  alias nvm-use='nvm use'
  alias nvm-default='nvm alias default'
}

(( $+commands[bun] )) && {
  alias b='bun'
  alias bi='bun install'
  alias ba='bun add'
  alias bad='bun add --dev'
  alias br='bun run'
  alias brm='bun remove'
  alias bup='bun update'
}

node-version() {
  node -v
}

npm-global-list() {
  npm ls -g --depth=0
}

npm-clean() {
  rm -rf node_modules package-lock.json yarn.lock pnpm-lock.yaml bun.lockb 2>/dev/null
  print -r -- "node_modules and lockfiles removed"
}
