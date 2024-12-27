# Derek C. Oppen's pritning algorithm

Derek C. Oppen's algorithm provides an efficient solution for formatting and printing code with clean indentation that respects a specified screen width.

When working with large blocks of code, ensuring proper indentation and alignment is crucial for readability and maintainability. However, achieving this while adhering to a specific line width can be a challenging task.

This algorithm is great if you are working with code, documentation, logging, or any situation that requires pretty-printing.

Reading Oppen's paper is indispensable to get all the details of his work, so what we're doing in this document is to explain his pretty-printing in simpler terms, relying on illustrative examples, acting as a companion to the paper.

## Table Of Contents
1. [The Printing Tokens](#the-printing-tokens)
2. [The Algorithm](#the-algorithm)
    1. [Token Queue](#tokens-queue)
    2. [Scan Stack](#scan-stack)
    3. [Size Buffer](#size-buffer)
    4. [Print Stack](#print-stack)
3. [How it Works](#how-it-works)
4. [Our Extensions](#our-extensions)
    1. [Eager Printing](#eager-printing)
    2. [Indent Anchors](#indent-anchors)
    3. [Trim Trailing Whitespaces](#trim-trailing-whitespaces)
    4. [Upsized Stacks](#upsized-stack)

## The Printing Tokens

Oppen's algorithm expects a list of tokens describing the structure of the expected output.

The main tokens are:

|   Name    | Description
|-----------|------------
| STRING    | String literal.
| BEGIN     | Opens a group.
| END       | Closes a group.
| EOF       | Flushes the output.
| BREAK     | Potential line break. Usually a single space that can become a new line.
| LINEBREAK | Guaranteed line break. Always a literal new line.

A group can contain any number of groups, `STRING`, `BREAK`, and a `LINEBREAK`. Groups exist to containerize different _groups_ of tokens with respect to line breaking.

Let's take an example to explain what we mean by containerizing groups with respect to line breaking.

Let's say we define our screen width to 3, and we want to print a simple group, with the following tokens:
```
[BEGIN, STRING(a), BREAK, STRING(b), BREAK, STRING(c), END]
```
We just defined a group to print a line of width 5: 3 characters for the `STRING` tokens, and 2 for the `BREAK` which are literal spaces by default.
Since our desired line width is 3, we need to break the group. `BREAK`s are transformed into new lines, and we get:
```
a
b
c
```
If we introduce a new group as follows:
```
[BEGIN, STRING(a),
    BEGIN, BREAK, STRING(b), END,
 BREAK, STRING(c), END]
```
We get:
```
a b
c
```
Instead of replacing all the spaces introduced by `BREAK` by an actual new line to fit a line of width 3, this configuration allowed us to break the outermost group only while keeping the inner `BREAK` (preceding `STRING('b')`) intact.

Oppen defines two types of groups:
- *consistent* groups that _consistently_ produce a new line for all `BREAK` tokens.
- *inconsistent* groups that produce new lines for _some_ `BREAK` tokens, i.e. only if needed.

Let's take another example to showcase the difference between these two types. Given the group:
```
[BEGIN, STRING(a), LINEBREAK, STRING(b), BREAK, STRING(c), END]
```
For the argument's sake, let's say that the screen width is 80. The `LINEBREAK` token is added to guarantee group breaking so we could observe the difference in behavior.
If this group is _consistent_, it should produce:
```
a
b
c
```
forcing the introduction of a new line at the position of `BREAK`.
If it's an _inconsistent_ group, it should produce:
```
a
b c
```
producing a space in the place of the `BREAK` because we don't need a new line to fit the remainder of the group on the second line.

## The Algorithm

The algorithm can be divided into two parts: `scanning` and `printing`.

`Scanning` tracks new tokens and their width using a `scan stack`, a `token buffer`, and a `size buffer` (both are ring buffers). It scans the input tokens until the current length hits the maximum desired line width.

This is where the `printing` step kicks in. It steals tokens from the the `scan stack` and the `token queue`, and starts printing to the output buffer with the help of its `print stack`.

### Token Queue

The token queue saves the tokens that we have already read from the input.

When scanning, every token read from the input will be automatically pushed to the token queue.
When printing, tokens are popped from the token queue and pushed into the print stack.

### Scan Stack

The scan stack saves the indexes of all the `BEGIN`, `END`, and `BREAK` tokens in the token queue, giving quick access to `BREAK` tokens and the groups they belong to.

### Size Buffer

The size buffer and the token queue grow simultaneously: every time a new token is read from the input it is first pushed to the token queue, and then we store in the size buffer an integer that depends on the type of the token:
- If it's a `STRING`, we store its width.
- Otherwise, we store the total width of the current line (without the current token), as a negative value.

It is the means of communication between the printing and the scanning phases: when the top value of the size buffer is greater than 0, the scanning step will be suspended and the printing step will begin.

The reaason we store some values as negatives is to make sure the printing process doesn't start until we have all the necessary information about a token. For example, we need to scan the values after a `BREAK` token to able to determine if it will display a line break or its space value.

### Print Stack
The print stack handles the display of the tokens, taking into account the current indentation and the available space left on the line.

It saves only the `BEGIN` tokens, the other tokens are only printed to the output.

When the print stack reads tokens from the token queue it will react according to the token type:
- `BEGIN`: we store the token in the stack in order to save the current printing context.
- `BREAK`: if its group fits on the line, we display the `BREAK` token's value (normally a space); otherwise, a line break is printed.
- `END`: we pop the `BEGIN` token at the top of stack.
- `STRING`: we print its value. If it's the first `STRING` on the current line, we add the appropriate amount of indentation spaces before printing it.


### How It Works

Here is a step by step execution of the algorithm using the example below for a maximum width of 3.
```
[
  BEGIN#1,
  STRING#1 = 'a',
  BEGIN#2,
    BREAK#1,
    STRING#2 = 'b',
  END#1,
  BREAK#2,
  STRING#3 = 'c',
  END#2,
  EOF,
]
```

The scanning phase starts, and we begin reading the tokens from the list one by one.

```
╔════════════════╗
║ CURRENT TOKEN: ║
║ BEGIN#1        ║
╚════════════════╝
```

Let's compute the value of size_buffer for the token.
```
current_line = ''
current_line_width = 0
size_buffer[BEGIN#2] = -(1 + current_line_width)
                     = -(1 + 0)
                     = -1
```
The reason we add `1` is that in Oppen's algorithm a line has at least a width of `1`.

```
+--------------+---------+
| token_queue  | BEGIN#1 |
+--------------+---------+
| size_buffer  |   -1    |
+--------------+---------+

+-------------+-------+
| scan_stack  |   0   |
+-------------+-------+
```

```
╔════════════════╗
║ CURRENT TOKEN: ║
║ STRING#1       ║
╚════════════════╝

+--------------+---------+----------+
| token_queue  | BEGIN#1 | STRING#1 |
+--------------+---------+----------+
| size_buffer  |   -1    |    1     |
+--------------+---------+----------+

+-------------+-------+
| scan_stack  |   0   |
+-------------+-------+
```

```
╔════════════════╗
║ CURRENT TOKEN: ║
║ BEGIN#2        ║
╚════════════════╝
```

Let's compute the value of size_buffer for the token.
```
current_line = 'a'
current_line_width = 1
size_buffer[BEGIN#2] = -(1 + current_line_width)
                     = -(1 + 1)
                     = -2
```

```
+--------------+---------+----------+---------+
| token_queue  | BEGIN#1 | STRING#1 | BEGIN#2 |
+--------------+---------+----------+---------+
| size_buffer  |   -1    |    1     |   -2    |
+--------------+---------+----------+---------+

+-------------+-------+-------+
| scan_stack  |   0   |   2   |
+-------------+-------+-------+
```

```
╔════════════════╗
║ CURRENT TOKEN: ║
║ BREAK#1        ║
╚════════════════╝

+--------------+---------+----------+---------+---------+
| token_queue  | BEGIN#1 | STRING#1 | BEGIN#2 | BREAK#1 |
+--------------+---------+----------+---------+---------+
| size_buffer  |   -1    |    1     |   -2    |   -2    |
+--------------+---------+----------+---------+---------+

+-------------+-------+-------+-------+
| scan_stack  |   0   |   2   |   3   |
+-------------+-------+-------+-------+
```

```
╔════════════════╗
║ CURRENT TOKEN: ║
║ STRING#2       ║
╚════════════════╝

+--------------+---------+----------+---------+---------+----------+
| token_queue  | BEGIN#1 | STRING#1 | BEGIN#2 | BREAK#1 | STRING#2 |
+--------------+---------+----------+---------+---------+----------+
| size_buffer  |   -1    |    1     |   -2    |   -2    |    1     |
+--------------+---------+----------+---------+---------+----------+

+-------------+-------+-------+-------+
| scan_stack  |   0   |   2   |   3   |
+-------------+-------+-------+-------+
```

```
╔════════════════╗
║ CURRENT TOKEN: ║
║ END#1          ║
╚════════════════╝

+--------------+---------+----------+---------+---------+----------+-------+
| token_queue  | BEGIN#1 | STRING#1 | BEGIN#2 | BREAK#1 | STRING#2 | END#1 |
+--------------+---------+----------+---------+---------+----------+-------+
| size_buffer  |   -1    |    1     |   -2    |   -2    |    1     |  -1   |
+--------------+---------+----------+---------+---------+----------+-------+

+-------------+-------+-------+-------+-------+
| scan_stack  |   0   |   2   |   3   |   5   |
+-------------+-------+-------+-------+-------+
```

```
╔════════════════╗
║ CURRENT TOKEN: ║
║ BREAK#2        ║
╚════════════════╝
```

Since the current token is of type `BREAK`, the scanner will check the value at the top of the scan_stack. The purpose is to determine if the previous group ended so we can be sure that the previous group will be printed on that line. Notice that the values in the size_buffer corresponding to the tokens of the previous group are now positive, implying that we have all the information we need to display them.

Currently, it is an `END` token that is at the top of the scan_stack, meaning that the previous group was closed and we now have all needed information about the group's size.

Let's update the size_buffer to take into account the newly acquired information.
We will update all the values corresponding to the tokens belonging to the previous group in the scan_stack using the following logic:
- If it is an `END` token, set the value to `1`.
- If it is a `BEGIN` or a `BREAK` token, add `current_line_width + 1` to the current value.

Let's compute the updated value of `BEGIN#2`.
```
current_line = 'a b'
current_line_width = 3
size_buffer[BEGIN#2] = size_buffer[BEGIN#2] + current_line_width + 1
                     = -2 + 3 + 1
                     = 2
```

We also pop the group from the scan_stack, since, like mentioned previously, this group will be printed on the current line without needing a line break.

```
+--------------+---------+----------+---------+---------+----------+-------+---------+
| token_queue  | BEGIN#1 | STRING#1 | BEGIN#2 | BREAK#1 | STRING#2 | END#1 | BREAK#2 |
+--------------+---------+----------+---------+---------+----------+-------+---------+
| size_buffer  |   -1    |    1     |    2    |    2    |    1     |   1   |   -4    |
+--------------+---------+----------+---------+---------+----------+-------+---------+

+-------------+-------+-------+
| scan_stack  |   0   |   6   |
+-------------+-------+-------+
```

```
╔════════════════╗
║ CURRENT TOKEN: ║
║ STRING#3       ║
╚════════════════╝

+--------------+---------+----------+---------+---------+----------+-------+---------+----------+
| token_queue  | BEGIN#1 | STRING#1 | BEGIN#2 | BREAK#1 | STRING#2 | END#1 | BREAK#2 | STRING#3 |
+--------------+---------+----------+---------+---------+----------+-------+---------+----------+
| size_buffer  |   -1    |    1     |    2    |    2    |    1     |   1   |   -4    |    1     |
+--------------+---------+----------+---------+---------+----------+-------+---------+----------+

+-------------+-------+-------+
| scan_stack  |   0   |   6   |
+-------------+-------+-------+
```

After adding `STRING#3` to the token_queue, the printer will notice that it cannot display `STRING#3` on the current line because it would exceed the maximum width.
The algorithm will start flushing the previous line by setting the value in size_buffer at `idx = value at the bottom of the scan_stack` to `∞`. Since `∞` is greater than 0, it will force the printing phase to start without doing unnecessary size computations.
While the first element of size_buffer is greater than 0, the token at the start of the token_queue will be popped and passed to the print_stack to be displayed.
```
Update the size_buffer to flush the line.

+--------------+---------+----------+---------+---------+----------+-------+---------+----------+
| token_queue  | BEGIN#1 | STRING#1 | BEGIN#2 | BREAK#1 | STRING#2 | END#1 | BREAK#2 | STRING#3 |
+--------------+---------+----------+---------+---------+----------+-------+---------+----------+
| size_buffer  |    ∞    |    1     |    2    |    2    |    1     |   1   |   -4    |    1     |
+--------------+---------+----------+---------+---------+----------+-------+---------+----------+

+-------------+-------+-------+
| scan_stack  |   0   |   6   |
+-------------+-------+-------+

Push BEGIN#1 to the print_stack.

+--------------+----------+---------+---------+----------+-------+---------+----------+
| token_queue  | STRING#1 | BEGIN#2 | BREAK#1 | STRING#2 | END#1 | BREAK#2 | STRING#3 |
+--------------+----------+---------+---------+----------+-------+---------+----------+
| size_buffer  |    1     |    2    |    2    |    1     |   1   |   -4    |    1     |
+--------------+----------+---------+---------+----------+-------+---------+----------+

+-------------+-------+
| scan_stack  |   5   |
+-------------+-------+

+-------------+---------+
| print_stack | BEGIN#1 |
+-------------+---------+
Output: ∅
```

Notice that the index present in the scan_stack was decreased by one: it is due to the fact that we popped the token_queue, changing the index of `BREAK#2` in the queue. This is handled differently in the algorithm, and the adjustment you see here was made only for the sake of the example.

```
Push STRING#1 to the print_stack.

+--------------+---------+---------+----------+-------+---------+----------+
| token_queue  | BEGIN#2 | BREAK#1 | STRING#2 | END#1 | BREAK#2 | STRING#3 |
+--------------+---------+---------+----------+-------+---------+----------+
| size_buffer  |    2    |    2    |    1     |   1   |   -4    |    1     |
+--------------+---------+---------+----------+-------+---------+----------+

+-------------+-------+
| scan_stack  |   4   |
+-------------+-------+

+-------------+---------+
| print_stack | BEGIN#1 |
+-------------+---------+
Output:
------
a$
------

Push BEGIN#2 to the print_stack.

+--------------+---------+----------+-------+---------+----------+
| token_queue  | BREAK#1 | STRING#2 | END#1 | BREAK#2 | STRING#3 |
+--------------+---------+----------+-------+---------+----------+
| size_buffer  |    2    |    1     |   1   |   -4    |    1     |
+--------------+---------+----------+-------+---------+----------+

+-------------+-------+
| scan_stack  |   3   |
+-------------+-------+

+-------------+---------+---------+
| print_stack | BEGIN#1 | BEGIN#2 |
+-------------+---------+---------+
Output:
------
a$
------

Push BREAK#1 to the print_stack.

+--------------+----------+-------+---------+----------+
| token_queue  | STRING#2 | END#1 | BREAK#2 | STRING#3 |
+--------------+----------+-------+---------+----------+
| size_buffer  |    1     |   1   |   -4    |    1     |
+--------------+----------+-------+---------+----------+

+-------------+-------+
| scan_stack  |   2   |
+-------------+-------+

+-------------+---------+---------+
| print_stack | BEGIN#1 | BEGIN#2 |
+-------------+---------+---------+
Output:
------
a $
------

Push STRING#2 to the print_stack.

+--------------+-------+---------+----------+
| token_queue  | END#1 | BREAK#2 | STRING#3 |
+--------------+-------+---------+----------+
| size_buffer  |   1   |   -4    |    1     |
+--------------+-------+---------+----------+

+-------------+-------+
| scan_stack  |   1   |
+-------------+-------+

+-------------+---------+---------+
| print_stack | BEGIN#1 | BEGIN#2 |
+-------------+---------+---------+
Output:
------
a b$
------

Push END#1 to the print_stack.

+--------------+---------+----------+
| token_queue  | BREAK#2 | STRING#3 |
+--------------+---------+----------+
| size_buffer  |   -4    |    1     |
+--------------+---------+----------+

+-------------+-------+
| scan_stack  |   0   |
+-------------+-------+

+-------------+---------+
| print_stack | BEGIN#1 |
+-------------+---------+
Output:
------
a b$
------

Update the size_buffer to flush the line.

+--------------+---------+----------+
| token_queue  | BREAK#2 | STRING#3 |
+--------------+---------+----------+
| size_buffer  |    ∞    |    1     |
+--------------+---------+----------+

+-------------+-------+
| scan_stack  |   0   |
+-------------+-------+

Push BREAK#2 to the print_stack.

+--------------+----------+
| token_queue  | STRING#3 |
+--------------+----------+
| size_buffer  |    1     |
+--------------+----------+

+-------------+
| scan_stack  |
+-------------+

+-------------+---------+
| print_stack | BEGIN#1 |
+-------------+---------+
Output:
------
a b$
$
------

Push STRING#3 to the print_stack.

+--------------+
| token_queue  |
+--------------+
| size_buffer  |
+--------------+

+-------------+
| scan_stack  |
+-------------+

+-------------+---------+
| print_stack | BEGIN#1 |
+-------------+---------+
Output:
------
a b$
  c$
------
```

Notice the indentation that was added before the `STRING` token. Like mentioned previously, if the first token on the line is a `STRING`, we add the necessary indentation before displaying it.

Since scan_stack is empty, all the remaining tokens will directly be forwarded to the print_stack without having to pass by the other data structures.

```
╔════════════════╗
║ CURRENT TOKEN: ║
║ END#2          ║
╚════════════════╝

Push END#2    to the print_stack.

+-------------+
| print_stack |
+-------------+
Output:
------
a b$
  c$
------
```

```
╔════════════════╗
║ CURRENT TOKEN: ║
║ EOF            ║
╚════════════════╝

Push EOF      to the print_stack.

+-------------+
| print_stack |
+-------------+
Output:
------
a b$
  c$
------
```

## Our Extensions

### Eager Printing

Oppen's original work and `ruby/pretty_print`'s produced different outcomes when chaining groups.
We added an optional extension to allow groups to be printed eagerly, where we try to flush the current line every time an `END` token is encountered.

Example for a maximum width of 13:
```
[
  BEGIN,
    BEGIN, STRING(abc), BREAK, STRING(def), END,
    BEGIN, STRING(ghi), BREAK, STRING(jkl), END,
  END,
]
```
without eager printing:
```
abc
defghi jkl
```
with eager printing:
```
abc defghi
       jkl
```

### Indent Anchors

Oppen described a single way to anchor the beginning of a new line: on the end of the previously displayed line.

```
[
  BEGIN, STRING(And she saids),
    BEGIN: offset = 4,
      BEGIN: offset = 4, LINEBREAK, STRING(Hello, World!), END,
    END,
  END,
]
=>
And she said:
                 Hello, World!
```

We added another optional extension to express anchoring to the current offset.

```
And she said:
        Hello, World!
```

### Trim Trailing Whitespaces

It may have not been a concern to Oppen, but in a modern context, this is a nice feature to have, especially when running outputs through diff.

### Upsized Stacks

Oppen fixed the size of the print and scan stacks to `3 * maximum desired width` since we will always flush them when their content's width is greater or equal to the `maximum desired width`.

Here's a quick and dirty example that illustrates a bigger issue with this assumption:
```
[
  BEGIN,
    BEGIN,
      BEGIN,
        BEGIN,
          BEGIN,
            STRING(Hello),
          END,
        END,
      END,
    END,
  END,
]
```
which breaks for `maximum desired width = 1`.

We decided to leave this option to user's discretion, giving them full control over the behavior of stack growth.
