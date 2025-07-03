" My .vimrc borrowed from Darth Ostrich https://github.com/DarthOstrich/dotfiles/blob/master/vimrc

set nocompatible              " be iMproved, required
filetype off                  " required
set exrc										" Allows project specific .vimrc
set autoread                  " reload files


"Auto install Plug https://github.com/junegunn/vim-plug/wiki/tips#automatic-installation
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

" Themes
Plug 'mhartington/oceanic-next'
Plug 'jnurmine/zenburn' "Theme plugin
Plug 'ryanoasis/vim-devicons' "Icons for filetypes
Plug 'vim-airline/vim-airline' "Status bar
Plug 'vim-airline/vim-airline-themes' "Applicable themes
Plug 'ap/vim-css-color' "  color name highlighter

" Language Syntax Support
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }

" Tools
Plug 'mitermayer/vim-prettier'
Plug 'jiangmiao/auto-pairs' "Autocomplete brackets.
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'tomtom/tcomment_vim'
"Plug 'tpope/vim-fugitive' "Git tools
Plug 'metakirby5/codi.vim'
Plug 'scrooloose/nerdtree', {'on': 'NERDTreeToggle'} "Nerdtree

" All of your Plugins must be added before the following line
call plug#end()            " required

" Theme settings
colors OceanicNext
if (has("termguicolors"))
  set termguicolors
endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Core Functionality (general settings, keyboard shortcuts)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" deal with swps and backups here
" create backups
set backup
" tell vim where to put its backup files
set backupdir=/tmp
" tell vim where to put swap files
set dir=/tmp
set timeoutlen=1000        " speed vim up
set ttimeoutlen=0          " https://stackoverflow.com/questions/37644682/why-is-vim-so-slow/37645334
set ttyfast                " Rendering
set tw=500
" Disable Autocommenting
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
" map jk to esc
:imap jk <Esc>

" save with zz
nnoremap zz :update<cr>

set backspace=indent,eol,start
" set clipboard to easily copy from vim and paste into OSx
set clipboard=unnamed

" remap Ctrl-p for finding files run Fzf :Files command
nnoremap <C-p> :Files<Cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => NERDTree
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Changes NerdTree Toggle to Ctrl + n
"map <C-n> :NERDTreeToggle<CR>
"autocmd VimEnter * NERDTree "Toggles Nerdtree on vim open
"let NERDTreeQuitOnOpen = 1 "closes NerdTree when opening a file
"autocmd VimEnter * wincmd p
" Close nerd tree if it is the only buffer open
"autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Text, tab and indent related
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2     " tab spacing
set expandtab     " tabs are now spaces
set ai            " Auto indent
" set si            " Smart indent
set wrap          " Wrap lines
set nowrap        " Don't wrap text

" Show line numbers
" turn relative line numbers on
:set number
:set nu rnu

" Code fold bliss
" https://www.linux.com/learn/vim-tips-folding-fun
" set foldmethod=indent

" Blink cursor on error instead of beeping (grr)
set visualbell
set t_vb=


" adds blue highlight to vim in visual mode selections
highlight Visual cterm=bold ctermbg=Blue ctermfg=NONE

" Shows the title within the window
set title titlestring=

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Prettier
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Autosave
" disables autosave feature
let g:prettier#autoformat = 0

" print spaces between brackets
" Prettier default: true
let g:prettier#config#bracket_spacing = 'true'

" runs prettier on file formats
autocmd BufWritePre *.js,*.jsx,*.mjs,*.ts,*.tsx,*.css,*.less,*.scss,*.json,*.graphql,*.md,*.vue PrettierAsync

" Syntax stuff
" This lets vim know that .prisma files should be graphql.
" Stolen from vim-graphql/ftdetect/graphql.vim
au BufRead,BufNewFile *.prisma setfiletype graphql

set secure "disables unsafe commands in project specific .vimrc
