# presenting.vim
### maintainer: Stefan Otte


#### a presentation tool
#### for vim

<!--
  Comments are removed. They must be
  in the form of an HTML comment tag.
-->

# Usage

- Each # or ## heading starts a new slide.
- All #, ##, and ### headings are rendered with [figlet][1], if installed.
- All #, ##, ###, and #### headings are centered horizontally.
- **Bold** __text__, *italicized* _text_, `inline code`, and [links](https://github.com/sotte/presenting.vim) are highlighted according to the built-in markdown syntax rules and colorscheme.

  [1]: http://www.figlet.org/

Start presenting:
```vim
:PresentingStart
```

Navigation:
 * n - next slide
 * p - previous slide
 * q - quit

# Tables

To format tables, they must be manually spaced, and include vertical bars, not only between the columns, but also as the left and right edges.

| Last Name      | First Name | Born | Bacon Number |
|----------------|------------|------|--------------|
| Bacon          | Kevin      | 1958 | 0            |
| Chan           | Jackie     | 1954 | 2            |
| Reagan         | Ronald     | 1911 | 2            |
| Ryan           | Meg        | 1961 | 1            |
| Saldaña        | Zoë        | 1978 | 2            |
| Schwarzenegger | Arnold     | 1947 | 2            |
| Temple         | Shirley    | 1928 | 3            |

[Bacon Number](https://oracleofbacon.org/)

# Lists

Lists can be ordered, unordered, or To Do list items. As a reminder, here is the markup for each type of list.

```
1. numbered item
    1. numbered sub-item

* bulleted item
- bulleted item

- [ ] unchecked item
- [x] checked item
```
## Ordered

Numbers are recalculated and incremented as you'd expect.

1. First
   2. Part a
   3. Part b
4. Second

## Unordered

Bullets are rendered with a Unicode bullet.

- milk
* bread
   * wheat
   - sourdough
- eggs

## Checkboxes / To-Do Lists

Checkboxes are rendered with Unicode as either empty or filled squares.

- [ ] Not done yet
- [x] Done

These are part of Github-flavored Markdown, not the official Markdown specification.

# Paragraphs / Quotes

Paragraphs and quotes are word wrapped on word boundaries. Quotes are indented and have a left vertical border.

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ullamcorper dignissim cras tincidunt lobortis. Nam aliquam sem et tortor consequat id porta nibh. Venenatis a condimentum vitae sapien pellentesque habitant morbi tristique. Mi ipsum faucibus vitae aliquet nec ullamcorper. Viverra mauris in aliquam sem fringilla. Pharetra sit amet aliquam id diam maecenas ultricies mi.

> Vitae proin sagittis nisl rhoncus mattis rhoncus. Mauris rhoncus aenean vel elit scelerisque. Eu volutpat odio facilisis mauris sit. Commodo quis imperdiet massa tincidunt nunc pulvinar sapien et.  Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

# Code Blocks

Code blocks can be syntax highlighted, but not `in-line code`.

```
" Hello World (without syntax highlighting)
function HelloWorld()
    echomsg "Hello World!"
endfunction
```

```vim
" Calculate n! (with syntax highlighting)
function Factorial(n)
   return a:n<=0 ? 1 : a:n * Factorial(a:n-1)
endfunction
```

# The End


### Thanks!

# After the End


### You're still here? It's over.
### Go home!
### Go.
