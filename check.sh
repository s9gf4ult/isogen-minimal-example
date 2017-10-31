set -e
set -o xtrace

export STACK_YAML=ghc-802.yaml

stack setup

stack clean && stack test

export STACK_YAML=stack.yaml

stack setup

stack clean && stack test --fast

stack clean && stack test
