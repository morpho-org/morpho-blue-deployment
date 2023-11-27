// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IMorpho} from "../lib/morpho-blue/src/interfaces/IMorpho.sol";

import "../lib/forge-std/src/Script.sol";
import "../lib/forge-std/src/console2.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct OracleConfig {
    address baseFeed1;
    address baseFeed2;
    address quoteFeed1;
    address quoteFeed2;
    uint256 vaultConversionSample;
}

/// @dev Warning: keys must be ordered alphabetically.
struct MarketConfig {
    address collateralToken;
    uint256[] lltvs;
    address loanToken;
    string name;
    OracleConfig oracle;
}

/// @dev Warning: keys must be ordered alphabetically.
struct BundlerConfig {
    bytes32[] args;
    string name;
}

/// @dev Warning: keys must be ordered alphabetically.
struct AdaptiveCurveIrmConfig {
    uint256 adjustmentSpeed;
    uint256 curveSteepness;
    uint256 initialRateAtTarget;
    uint256 targetUtilization;
}

/// @dev Warning: keys must be ordered alphabetically.
struct DeployConfig {
    AdaptiveCurveIrmConfig adaptiveCurveIrm;
    BundlerConfig[] bundlers;
    uint256[] lltvs;
    MarketConfig[] markets;
    address owner;
    bytes32 salt;
}

contract ConfiguredScript is Script {
    using stdJson for string;

    string internal configPath;

    IMorpho internal morpho;

    function _initConfig(string memory network, bool requireMorpho) internal returns (DeployConfig memory) {
        configPath = string.concat("script/config/", network, ".json");

        vm.createSelectFork(vm.rpcUrl(network));

        string memory latestRunPath =
            string.concat("broadcast/DeployMorpho.sol/", vm.toString(block.chainid), "/run-latest.json");

        if (vm.exists(latestRunPath)) {
            string memory latestRun = vm.readFile(latestRunPath);

            require(
                keccak256(bytes(latestRun.readString("$.transactions[0].contractName"))) == keccak256("Morpho"),
                "unexpected contract deployment"
            );

            morpho = IMorpho(latestRun.readAddress("$.transactions[0].contractAddress"));
        } else {
            require(!requireMorpho, "missing Morpho deployment");
        }

        return abi.decode(vm.parseJson(vm.readFile(configPath)), (DeployConfig));
    }
}
