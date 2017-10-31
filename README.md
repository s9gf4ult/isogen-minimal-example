# Bug demonstration repo

The `master` branch demonstrates a bug with GHC 8.2.1 and branches with `fix-`
prefix contain versions where a bug won't reproduce.

There are `ghc-???.yaml` files for versions of GHC other than 8.2.1.

# How to check if bug reproduces

Running the `./check.sh` script triggers three builds:
* GHC 8.0.2, -O, succeeds
* GHC 8.2.1, -O0, succeeds
* GHC 8.2.1, -O, fails

If you'll check out to either of fix- branches:

* `fix-move-mkelement`
* `fix-no-catchall-instance`
* `fix-replace-mkelement`
* `fix-add-irrelevant-instance`

then the last test should succeed also.
Those branches contain changes over `master` which fixes the bug in different
ways.

# Reproducibility

### Optimization level

`stack clean && stack test` fails, `stack clean && stack test --fast`
does not. For same code in master branch

### Catch all instance for ToText

removing the instance

```haskell
instance {-# OVERLAPPABLE #-} ToText a where
  toText _ = "Catchall attribute value"
```

solves the problem, see the branch `fix-no-catchall-instance`

### Location of toTextProxy

* In the other module - FAILS
* In the same module - SUCCEEDS

Moving function `toTextProxy` from `ExternalStuff` to `Main`
solves the problem. See branch `fix-move-mkelement`

Problem is also solved if the call of `toTextProxy` replaced with the body
of `toTextProxy`. Branch `fix-replace-mkelement`

### Instances count in module ExternalStuff

If a module `ExternalStuff` contains a single catchall instance then the bug
reproduces. But when an additional irrelevant instance is added - it does not.

``` haskell
-- | This instance should not affect 'toTextProxy' behaviour, but
-- it does.
instance {-# OVERLAPPING #-} ToText Int where
  toText = T.pack . show
```

# Thoughts about the bug nature

GHC optimizer optimizes the body of `toTextProxy` to the call of
method `toText` of catchall instance, not a method from the dictionary
as it should. But optimizer does it only if it sees only one instance
in the scope of the module.
