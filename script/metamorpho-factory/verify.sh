#!/bin/sh

if [ -f .env ]
then
  export $(grep -v '#.*' .env | xargs)
fi

if cd lib/metamorpho/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 8453 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb 0xA9c3D3a366466Fa809d1Ae982Fb2c46E5fC41101 src/MetaMorphoFactory.sol:MetaMorphoFactory
  cd ../../
fi
