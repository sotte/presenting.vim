# presenting.vim
### maintainer: Stefan Otte


#### a presentation tool
#### for vim

// This is a comment that won't be presented. Comments are
// an entire line starting with //, and no leading spaces.

# Usage

- Each # or ## heading starts a new slide.
- All #, ##, and ### headings are rendered with [figlet][1], if installed.
- All #, ##, ###, and #### headings are centered horizontally.
- **Bold** __text__ and *italicized* _text_ are highlighted according to the built-in markdown syntax rules.

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

Lists can be numbered, bulleted, or To Do list items. As a reminder, here is the markup for each type of list.

```
* bulleted item
- bulleted item

1. numbered item
    1. numbered sub-item

- [ ] unchecked item
- [x] checked item
```
## Ordered

Numbers are recalculated and incremented properly.

1. First
   2. Part a
   3. Part b
4. Second

## Unordered

Bullets are rendered with a Unicode bullet operator.

- milk
* bread
   * wheat
   - sourdough
- eggs

## Checkboxes / To-Do Lists

Checkboxes are rendered with Unicode as either unchecked or checked boxes.

- [ ] Not done yet
- [x] Done

These are part of Github-flavored Markdown, not the offical Markdown specification.

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
