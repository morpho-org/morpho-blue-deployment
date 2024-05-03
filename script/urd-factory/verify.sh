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

if cd lib/universal-rewards-distributor/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 8453 --constructor-args 0x 0x7276454fc1cf9C408deeed722fd6b5E7A4CA25D8 src/UrdFactory.sol:UrdFactory
  cd ../../
fi
