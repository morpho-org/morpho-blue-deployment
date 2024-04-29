#!/bin/sh

if [ -f .env ]
then
  export $(grep -v '#.*' .env | xargs)
fi

if cd lib/morpho-blue/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000937ce2d6c488b361825d2db5e8a70e26d48afed5 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb src/Morpho.sol:Morpho
  cd ../../
fi

if cd lib/morpho-blue-irm/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb 0x46415998764C29aB2a25CbeA6254146D50D22687 src/AdaptiveCurveIrm.sol:AdaptiveCurveIrm
  cd ../../
fi

if cd lib/morpho-blue/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000937ce2d6c488b361825d2db5e8a70e26d48afed5 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb src/Morpho.sol:Morpho
  cd ../../
fi

if cd lib/morpho-blue-irm/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb 0x46415998764C29aB2a25CbeA6254146D50D22687 src/AdaptiveCurveIrm.sol:AdaptiveCurveIrm
  cd ../../
fi

if cd lib/morpho-blue/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000937ce2d6c488b361825d2db5e8a70e26d48afed5 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb src/Morpho.sol:Morpho
  cd ../../
fi

if cd lib/morpho-blue-irm/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb 0x46415998764C29aB2a25CbeA6254146D50D22687 src/AdaptiveCurveIrm.sol:AdaptiveCurveIrm
  cd ../../
fi

if cd lib/morpho-blue/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000937ce2d6c488b361825d2db5e8a70e26d48afed5 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb src/Morpho.sol:Morpho
  cd ../../
fi

if cd lib/morpho-blue-irm/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb 0x46415998764C29aB2a25CbeA6254146D50D22687 src/AdaptiveCurveIrm.sol:AdaptiveCurveIrm
  cd ../../
fi

if cd lib/morpho-blue/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000937ce2d6c488b361825d2db5e8a70e26d48afed5 0xBBBBBbbBBb9cC5e90e3b3Af64bdAF62C37EEFFCb src/Morpho.sol:Morpho
  cd ../../
fi

if cd lib/morpho-blue-irm/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb 0x46415998764C29aB2a25CbeA6254146D50D22687 src/AdaptiveCurveIrm.sol:AdaptiveCurveIrm
  cd ../../
fi

if cd lib/morpho-blue-irm/;
then
FOUNDRY_PROFILE=build forge verify-contract --watch --chain-id 84532 --constructor-args 0x000000000000000000000000bbbbbbbbbb9cc5e90e3b3af64bdaf62c37eeffcb 0x46415998764C29aB2a25CbeA6254146D50D22687 src/AdaptiveCurveIrm.sol:AdaptiveCurveIrm
  cd ../../
fi
