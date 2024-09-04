#!/bin/sh

if [ -f .env ]
then
  export $(grep -v '#.*' .env | xargs)
fi

if cd lib/public-allocator/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 8453 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb 0xA090dD1a701408Df1d4d0B85b716c87565f90467 src/PublicAllocator.sol:PublicAllocator   --show-standard-json-input > etherscan.json
  cd ../../
fi
