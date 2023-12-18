// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC20} from "../../lib/forge-std/src/interfaces/IERC20.sol";
import {IChainlinkOracle} from "../../lib/morpho-blue-oracles/src/interfaces/IChainlinkOracle.sol";

import "../ConfiguredScript.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct OracleConfig {
    address baseFeed1;
    address baseFeed2;
    address collateralToken;
    address loanToken;
    uint256 maxPrice;
    uint256 minPrice;
    string name;
    address quoteFeed1;
    address quoteFeed2;
    bytes32 salt;
    uint256 vaultConversionSample;
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

            address vault = oracleConfig.vaultConversionSample > 1 ? oracleConfig.collateralToken : address(0);
            uint256 baseTokenDecimals = IERC20(oracleConfig.collateralToken).decimals();
            uint256 quoteTokenDecimals = IERC20(oracleConfig.loanToken).decimals();

            vm.broadcast();
            IChainlinkOracle oracle = IChainlinkOracle(
                _deployCreate2Code(
                    "morpho-blue-oracles",
                    "ChainlinkOracle",
                    abi.encode(
                        vault,
                        oracleConfig.baseFeed1,
                        oracleConfig.baseFeed2,
                        oracleConfig.quoteFeed1,
                        oracleConfig.quoteFeed2,
                        oracleConfig.vaultConversionSample,
                        baseTokenDecimals,
                        quoteTokenDecimals
                    ),
                    oracleConfig.salt
                )
            );

            require(address(oracle.VAULT()) == vault, "unexpected vault");
            require(
                oracle.VAULT_CONVERSION_SAMPLE() == oracleConfig.vaultConversionSample,
                "unexpected vault conversion sample"
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
