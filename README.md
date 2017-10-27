# About repo

This is the bug demonstration repo. The `master` branch contains
changes not affected the bug reproducibility and branches with `fix-`
prefix contain changes causing the bug not reproduce.

There is also `ghc-???.yaml` files for other versions of
GHC. `stack.yaml` is for GHC-8.2.1 in which bug is reproducable.

# How to check if bug reproduces

run `./check.sh`. First two test should succeed but last one fail. See
the simple code of `check.sh`

If you checkout to branch

`fix-move-mkelement` `fix-no-catchall-instance`
`fix-replace-mkelement` or then last test should succeed also.

# Reproducability
## Affects a bug
### Optimization level

`stack clean && stack test` fails, `stack clean && stack test --fast`
does not. For same code in master branch

### Catch all instance for ToText

removing the instance

```haskell
instance {-# OVERLAPPABLE #-} ToText a where
  toText _ = "Catchall attribute value"
```

solves the problem, see branch `fix-no-catchall-instance`

### Location of toTextProxy

* In other module - FAILS
* In same module - SUCCEEDS

Moving function `toTextProxy` out from `ExternalStuff` to `Main`
solves the problem. See branch `fix-move-mkelement`

Problem is also solved if the call of `toTextProxy` replaced with body
of `toTextProxy`. Branch `fix-replace-mkelement`

## Not affects a bug

### INLINE pragma for toTextProxy

No mater if INLINE pragma is set for `toTextProxy` function
