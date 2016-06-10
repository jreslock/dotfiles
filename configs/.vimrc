set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" My Bundles
Plugin 'flazz/vim-colorschemes'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-sensible'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-python'
Plugin 'tpope/vim-markdown'
Plugin 'klen/python-mode'
Plugin 'scrooloose/syntastic'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}


call vundle#end()            " required
filetype plugin indent on    " required

" Put your non-Plugin stuff after this line

let mapleader=","

color jellybeans

set backspace=indent,eol,start
set cursorline
set expandtab
set modelines=0
set shiftwidth=2
set clipboard=unnamed
set encoding=utf-8
set nowrap
set number
set nowritebackup
set noswapfile
set ignorecase
set smartcase
set tabstop=2
set synmaxcol=128
set ttyscroll=10
set nobackup
set hlsearch
