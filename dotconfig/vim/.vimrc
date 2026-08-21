" Enable syntax highlighting
syntax on

" Enable file type detection
filetype plugin indent on

" Auto-detect Splunk files
au BufRead,BufNewFile *.spl set filetype=splunk

" Basic editor settings
set number          " Show line numbers
set autoindent      " Auto-indent new lines
set expandtab       " Use spaces instead of tabs
set tabstop=4       " Tab width
set shiftwidth=4    " Indent width
set clipboard=unnamedplus
