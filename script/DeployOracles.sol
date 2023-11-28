// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC20} from "../lib/forge-std/src/interfaces/IERC20.sol";

import {IOracle} from "../lib/morpho-blue/src/interfaces/IOracle.sol";
import {IMorpho, MarketParams, Id} from "../lib/morpho-blue/src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "../lib/morpho-blue/src/libraries/MarketParamsLib.sol";

import "./config/ConfiguredScript.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct OracleConfig {
    address baseFeed1;
    address baseFeed2;
    address collateralToken;
    uint256 expectedPrice;
    address loanToken;
    string name;
    address quoteFeed1;
    address quoteFeed2;
    uint256 vaultConversionSample;
}

contract DeployOracle is ConfiguredScript {
    function _configDir() internal pure override returns (string memory) {
        return "oracles";
    }

    function run(string memory network) public returns (OracleConfig[] memory config) {
        config = abi.decode(_init(network, false), (OracleConfig[]));

        for (uint256 i; i < config.length; ++i) {
            OracleConfig memory oracleConfig = config[i];

            uint256 baseTokenDecimals = IERC20(oracleConfig.collateralToken).decimals();
            uint256 quoteTokenDecimals = IERC20(oracleConfig.loanToken).decimals();

            vm.broadcast();
            address oracle = deployCode(
                "lib/morpho-blue-oracles/out/ChainlinkOracle.sol/ChainlinkOracle.json",
                abi.encode(
                    oracleConfig.vaultConversionSample > 1 ? oracleConfig.collateralToken : address(0),
                    oracleConfig.baseFeed1,
                    oracleConfig.baseFeed2,
                    oracleConfig.quoteFeed1,
                    oracleConfig.quoteFeed2,
                    oracleConfig.vaultConversionSample,
                    baseTokenDecimals,
                    quoteTokenDecimals
                )
            );

            console2.log("  Deployed ChainlinkOracle for market [%s] at: %s", oracleConfig.name, oracle);

            uint256 price = IOracle(oracle).price();
            uint256 priceRatio = price * 1 ether / oracleConfig.expectedPrice;
            require(priceRatio <= 10 ether, string.concat("price too high: ", vm.toString(price)));
            require(priceRatio >= 0.1 ether, string.concat("price too low: ", vm.toString(price)));
        }
    }
}
