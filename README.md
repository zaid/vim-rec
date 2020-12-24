# GNU Recutils syntax support for Vim

This plugin provides syntax highlighting and runtime support for [GNU Recutils](https://www.gnu.org/software/recutils/)' .rec files.

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
  * Folding for records. (can be disabled by setting the `g:recutils_no_folding` variable to `1`).
  * Command wrappers for `recsel`, `recfix`, `recinf` and `rec2csv`.
  * Auto-completion of record set properties.

  See `help :recutils` for more information.

## Examples

### Recfix
   To find any syntax errors in the file, you can run `:Recfix` in any `.rec` buffer
   and the syntax errors will be loaded in a local `location-list` where you'll be
   able to navigate the list and jump straight to the line with the error.

   *Note* The `location-list` will not open if there are no errors in the file.

### Recsel
  To query the `Title` of any book with a rating over `4`, you can execute the following:
  `:Recsel -t Book -p Title -e Rating>4`

### Recinf
  To query the descriptors of records stored in a specifc `.rec` buffer, you can execute the following:
  `:Recinf -d`

### Rec2csv
  To convert Rec data into CSV format and populate it in a split buffer, you can execute the following:
  `:Rec2csv -tBook`

## Notes

  Whitespace might need to be escaped in certain scenarios. For example, the following line:
  `:Recsel -t Book -p Title -e Rating>4`
  can be rewritten as:
  `:Recsel -t Book -p Title -e Rating\ >\ 4` 

## Command maps

  There are 4 command maps defined (which can be disabled by setting the `g:recutils_no_maps` variable to `1`):
  * `<localleader>rf` Invokes `:Recfix --check` on the current buffer.
  * `<localleader>rn` populates the Vim command line with `:Recinf`.
  * `<localleader>rs` populates the Vim command line with `:Recsel`.
  * `<localleader>rv` populates the Vim command line with `:Rec2csv`.

## Auto-completion

  Basic support for auto-completing record set properties is available (by using `C-x C-o` when in insert mode).
  It can be disabled by setting the `g:recutils_no_autocompletion` variable to `1`.

## TODO

  * Keymaps for formatting text.

## License

Copyright Zaid Al-Jarrah. Distributed under the same terms as Vim itself. See `:help license`.
