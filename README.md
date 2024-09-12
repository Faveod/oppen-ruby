# Oppen's pretty printer

Here can be found the implementation of the pretty printing algorithm present in then appendix of Oppen's paper
https://dl.acm.org/doi/pdf/10.1145/357114.357115

## Difference with the orignal algorithm
We decided to diverge from Oppen's original algorithm to provide a more idiomatic Ruby experience, notably:

1. We do not raise exceptions when we overflow the margin. Actually, the only exceptions that we raise indicate a bug in the implementation. Please report them.
