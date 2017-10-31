# Bug demonstration repo

The `master` branch demonstrate a bug with GHC 8.2.1 and branches with `fix-`
prefix contain versions where a bug won't reproduce.

There are `ghc-???.yaml` files for versions of GHC other than 8.2.1.

# How to check if bug reproduces

Running the `./check.sh` script triggers three builds:
* GHC 8.0.2, -O, succeeds
* GHC 8.2.1, -O0, succeeds
* GHC 8.2.1, -O, fails

If you checkout to branch

`fix-move-mkelement` `fix-no-catchall-instance`
`fix-replace-mkelement` or `fix-add-irrelevant-instance` then last
test should succeed also. Those branches contain changes over `master`
which breaks the bug reproducibility.

# Reproducibility
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

### Instances count in module ExternalStuff

If module `ExternalStuff` contain single catchall intance then bug
reproducing, when additional irrelevant instance is added

``` haskell
-- | This instance should not affect to 'toTextProxy' behaviour, but
-- it does.
instance {-# OVERLAPPING #-} ToText Int where
  toText = T.pack . show
```

then bug reproducibility breaks.

## Not affects a bug

### INLINE pragma for toTextProxy

No mater if INLINE pragma is set for `toTextProxy` function

# Thoughts about the bug nature

GHC-s optimizer optimizes the body of `toTextProxy` to the call of
method `toText` of catchall instance, not a method from the dictionary
as it should. But optimizer does it only if it sees only one instance
in the scope of the module. If there is more than one instance then
optimizer not simplifies `toTextProxy` such hard way.
