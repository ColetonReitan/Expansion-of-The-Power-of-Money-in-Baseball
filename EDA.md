---
title: Title
---


Custom Palettes
---------------

`define_palette()` lets you make your own themes that can be passed to `ggthemr()` just like any of the palettes above. Here's an example of a (probably ugly) palette using random colours:

``` r
# Random colours that aren't white.
set.seed(12345)
random_colours <- sample(colors()[-c(1, 253, 361)], 10L)

ugly <- define_palette(
  swatch = random_colours,
  gradient = c(lower = random_colours[1L], upper = random_colours[2L])
)

ggthemr(ugly)

example_plot + ggtitle(':(')
```
