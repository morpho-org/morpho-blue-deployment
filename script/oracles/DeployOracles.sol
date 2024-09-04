// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC20} from "../../lib/forge-std/src/interfaces/IERC20.sol";
import {IMorphoChainlinkOracleV2} from
    "../../lib/morpho-blue-oracles/src/morpho-chainlink/interfaces/IMorphoChainlinkOracleV2.sol";

import "../ConfiguredScript.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct OracleConfig {
    address baseFeed1;
    address baseFeed2;
    address baseVault;
    uint256 baseVaultConversionSample;
    address collateralToken;
    address loanToken;
    uint256 maxPrice;
    uint256 minPrice;
    string name;
    address quoteFeed1;
    address quoteFeed2;
    address quoteVault;
    uint256 quoteVaultConversionSample;
    bytes32 salt;
}

contract DeployOracle is ConfiguredScript {
    function _scriptDir() internal pure override returns (string memory) {
        return "oracles";
    }

    function run(string memory network) public returns (OracleConfig[] memory config) {
        config = abi.decode(_init(network, false), (OracleConfig[]));

        for (uint256 i; i < config.length; ++i) {
            OracleConfig memory oracleConfig = config[i];

            console2.log("  Market [%s]", oracleConfig.name);

            uint256 baseTokenDecimals = IERC20(oracleConfig.collateralToken).decimals();
            uint256 quoteTokenDecimals = IERC20(oracleConfig.loanToken).decimals();

            IMorphoChainlinkOracleV2 oracle = IMorphoChainlinkOracleV2(
                _deployCreate2Code(
                    "morpho-blue-oracles",
                    "MorphoChainlinkOracleV2",
                    abi.encode(
                        oracleConfig.baseVault,
                        oracleConfig.baseVaultConversionSample,
                        oracleConfig.baseFeed1,
                        oracleConfig.baseFeed2,
                        baseTokenDecimals,
                        oracleConfig.quoteVault,
                        oracleConfig.quoteVaultConversionSample,
                        oracleConfig.quoteFeed1,
                        oracleConfig.quoteFeed2,
                        quoteTokenDecimals,
                        oracleConfig.salt
                    ),
                    oracleConfig.salt
                )
            );
            require(address(oracle.BASE_FEED_1()) == oracleConfig.baseFeed1, "unexpected baseFeed1");
            require(address(oracle.BASE_FEED_2()) == oracleConfig.baseFeed2, "unexpected baseFeed2");
            require(address(oracle.QUOTE_FEED_1()) == oracleConfig.quoteFeed1, "unexpected quoteFeed1");
            require(address(oracle.QUOTE_FEED_2()) == oracleConfig.quoteFeed2, "unexpected quoteFeed2");

            uint256 price = oracle.price();
            require(price <= oracleConfig.maxPrice, string.concat("price too high: ", vm.toString(price)));
            require(price >= oracleConfig.minPrice, string.concat("price too low: ", vm.toString(price)));
        }
    }
}
