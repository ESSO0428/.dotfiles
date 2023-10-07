#!/usr/bin/env bash
mv ~/.vimrc ~/.vimrc.old > /dev/null 2>&1
rm -rf ~/.vim/vim.old/
mv ~/.vim/vim/ ~/.vim/vim.old/ > /dev/null 2>&1
cp ./.vimrc ~/.vimrc
cp ./.vim/vim/ ~/.vim/vim/


