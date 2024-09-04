#!/bin/sh

if [ -f .env ]
then
  export $(grep -v '#.*' .env | xargs)
fi

if cd lib/morpho-blue-irm/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 8453 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb 0x46415998764C29aB2a25CbeA6254146D50D22687 src/AdaptiveCurveIrm.sol:AdaptiveCurveIrm --show-standard-json-input > etherscan.json
  cd ../../
fi
