# presenting.vim
### created by Stefan Otte


#### a presentation tool
#### for vim

# Usage

- Each # or ## header starts a new slide.
- All #, ##, and ### headers are rendered with [figlet][1], if installed.
- All #, ##, ###, and #### headers are centered horizontally.

  [1]: http://www.figlet.org/

Start presenting:

```vim
:PresentingStart
```

Navigation:

 * n - next slide
 * p - previous slide
 * q - quit

# Lists / Nested Outline

Ordered, bulleted, and To Do lists are nicely rendered.
## Ordered

Numbers are recalculated and incremented properly.

1. First
   1. Part a
   1. Part b
1. Second

## Unordered

Bullets are rendered with a Unicode bullet operator.

- milk
* bread
   * wheat
   - sourdough
- eggs

## Checkboxes

Checkboxes are rendered with Unicode as either unchecked or checked boxes.

- [ ] Not done yet
- [x] Done

# Word Wrapping / Quotes

Paragraphs and quote blocks are word wrapped on word boundaries. Quote blocks are indicated with a vertical bar on its left side.

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.

> Vitae proin sagittis nisl rhoncus mattis rhoncus. Mauris rhoncus aenean vel elit scelerisque. Eu volutpat odio facilisis mauris sit. Commodo quis imperdiet massa tincidunt nunc pulvinar sapien et.

# The End


### Thanks!

# After the End


### You're still here? It's over.
### Go home!
### Go.
