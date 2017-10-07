## Problem

Exercise 5.52. As a counterpoint to exercise 5.51, modify the compiler so that it compiles Scheme procedures into
sequences of C instructions. Compile the metacircular evaluator of section 4.1 to produce a Scheme interpreter
written in C.

## Approach

The compiler doesn't really need to be ported, because it should produce assembly instructions for the virtual machine.

If we write a translation layer for the output of the compiler, we can use that to transform the compiler output into the C-data-structure-based assembly.

We also have to link it up into the existing explicit-control evaluator in some way (`compile-and-go`).

Actually in the end, we should compile the meta-circular evaluator, so we won't need to use the explicit-control evaluator; only the underlying virtual machine.

## Testing

What should be the first acceptance test?

+ fork the es5.51 code
- write a `compile` that only works for self-evaluating (even if it's fake)
- try to write `compile-and-go`, which should (re)use `assemble`
-- `assemble` may need to be extracted from the previous code
- use it to compile `(list 42)` which should only evaluate 42 and stop
-- start from a `main()` that compiles a fixed input `(list 42)` to a sequence of assembly instructions, and just prints it
-- then you can put it into the `Machine` instead and try to execute it

## References

- `es5.51/` provides the virtual machine (this will be forked)
- `chapter5.5.scm` (and dependencies) has the compiler