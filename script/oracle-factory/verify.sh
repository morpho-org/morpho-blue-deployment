#!/bin/sh

if [ -f .env ]
then
  export $(grep -v '#.*' .env | xargs)
fi

if cd lib/morpho-blue-oracles/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 8453 --constructor-args 0x 0x2DC205F24BCb6B311E5cdf0745B0741648Aebd3d src/morpho-chainlink/MorphoChainlinkOracleV2Factory.sol:MorphoChainlinkOracleV2Factory --show-standard-json-input > etherscan.json
  cd ../../
fi
