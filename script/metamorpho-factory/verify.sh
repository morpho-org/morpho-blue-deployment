#!/bin/sh

if [ -f .env ]
then
  export $(grep -v '#.*' .env | xargs)
fi

if cd lib/metamorpho/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x00000000000000000000000046415998764c29ab2a25cbea6254146d50d22687 0xb93C5D5837b6c8D4F361c695ec03395eA7Da7c8e src/MetaMorphoFactory.sol:MetaMorphoFactory
  cd ../../
fi

if cd lib/metamorpho/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb 0x255896Ec517b5E9DDba19027aecac58289565C4F src/MetaMorphoFactory.sol:MetaMorphoFactory
  cd ../../
fi

if cd lib/metamorpho/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb 0x255896Ec517b5E9DDba19027aecac58289565C4F src/MetaMorphoFactory.sol:MetaMorphoFactory
  cd ../../
fi
