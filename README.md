# presenting.vim

presenting.vim is a simple tool for presenting slides in vim
based on text files.

It is a clone of https://github.com/pct/present.vim
which is a clone of https://github.com/sorah/presen.vim

In contrast to its predecessors presenting.vim
 * has support for a number of markup languages,
 * can be extended, and
 * is documented

Great, hey?


# Installation

Use pathogen_ or vundle_ to install presenting.vim.

 * https://github.com/tpope/vim-pathogen
 * https://github.com/gmarik/vundle


# Usage 1/3

* write you presentation in your favorite markup language
* every slide is separated by a markup language specific marker

```
    ========  ===============
    FILETYPE  SLIDE SEPARATOR
    ========  ===============
    markdown  # heading
    rst       ~~~~
    orgmode   #----
    ========  ===============
```

# Usage 2/3

Remember to inform presenting.vim about *filetype* it deals with! 

Take a look at the presenting.vim examples to do that:
 * PresentingExample.markdown
 * PresentingExample.rst
 * PresentingExample.org


# Usage 3/3
 
When you want to start presenting execute:
```
    :StartPresenting
```

Navigation:
 * n - next slide
 * p - previous slide
 * q - quit

Of course you can configure the slide separators.

# Links

The code is on github. Pull requests are welcome!
 * https://github.com/sotte/presenting.vim

Issue tracker:
 * https://github.com/sotte/presenting.vim/issues
