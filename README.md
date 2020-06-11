# GNU Recutils syntax support for Vim

This plugin provides syntax highlighting and indentation for [GNU Recutils](https://www.gnu.org/software/recutils/)' .rec files.

## Installation

  * If you're on Vim 8.x then you can use the built-in package support by running:
    ```
    mkdir -p ~/.vim/pack/default/start/vim-rec
    git clone git@github.com:zaid/vim-rec.git ~/.vim/pack/default/start/vim-rec
    ```
  * If you're using vim-plug then you can install it by adding the following to your `.vimrc`:

    `Plug 'zaid/vim-rec'`

  * If you're using minpac then you can install it by adding the following to your `.vimrc`:

    `call minpac#add('zaid/vim-rec')`

## Features

  * Syntax highlighting.
  * Folding for records.
  * Command wrappers for `recsel` and `recinf`.

  See `help :recutils` for more information.

## Examples

### Recsel
  To query the `Title` of any book with a rating over `4`, you can execute the following:
  `:Recsel -t Book -p Title -e Rating>4`

### Recinf
  To query the descriptors of records stored in a specifc `.rec` buffer, you can execute the following:
  `:Recinf -d`

## TODO

  * Keymaps for formatting text.
