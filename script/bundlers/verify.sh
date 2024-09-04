#!/bin/sh

if [ -f .env ]
then
  export $(grep -v '#.*' .env | xargs)
fi

if cd lib/morpho-blue-bundlers/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 8453 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb0000000000000000000000004200000000000000000000000000000000000006 0xb5D342521EB5b983aE6a6324A4D9eac87C9D1987 src/chain-agnostic/ChainAgnosticBundlerV2.sol:ChainAgnosticBundlerV2
  cd ../../
fi
