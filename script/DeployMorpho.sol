// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC20} from "../lib/forge-std/src/interfaces/IERC20.sol";

import {IMorpho, MarketParams, Id} from "../lib/morpho-blue/src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "../lib/morpho-blue/src/libraries/MarketParamsLib.sol";

import "./ConfiguredScript.sol";

contract DeployMorpho is ConfiguredScript {
    using MarketParamsLib for MarketParams;

    function run(string memory network) public returns (DeployConfig memory config) {
        config = _init(network, false);

        // Deploy Morpho Blue
        vm.broadcast();
        morpho = IMorpho(
            _deployCreate2Code("lib/morpho-blue/out/Morpho.sol/Morpho.json", abi.encode(msg.sender), config.salt.morpho)
        );

        console2.log("Deployed Morpho Blue at: %s", address(morpho));

        // Deploy & enable AdaptiveCurveIrm
        vm.broadcast();
        irm = IAdaptiveCurveIrm(
            deployCode(
                "lib/morpho-blue-irm/out/AdaptiveCurveIrm.sol/AdaptiveCurveIrm.json",
                abi.encode(
                    address(morpho),
                    config.adaptiveCurveIrm.curveSteepness,
                    config.adaptiveCurveIrm.adjustmentSpeed,
                    config.adaptiveCurveIrm.targetUtilization,
                    config.adaptiveCurveIrm.initialRateAtTarget
                )
            )
        );

        console2.log("Deployed AdaptiveCurveIrm at: %s", address(irm));

        vm.broadcast();
        morpho.enableIrm(address(irm));

        // Enable all LLTVs
        for (uint256 i; i < config.lltvs.length; ++i) {
            uint256 lltv = config.lltvs[i];

            console2.log("Enabling LLTV %e...", lltv);

            vm.broadcast();
            morpho.enableLltv(lltv);
        }

        // Create all markets
        for (uint256 i; i < config.markets.length; ++i) {
            MarketConfig memory marketConfig = config.markets[i];

            console2.log("Preparing market [%s]...", marketConfig.name);

            for (uint256 j; j < marketConfig.lltvs.length; ++j) {
                address oracle;

                // Deploy corresponding ChainlinkOracle
                if (marketConfig.collateralToken != address(0)) {
                    uint256 baseTokenDecimals = IERC20(marketConfig.collateralToken).decimals();
                    uint256 quoteTokenDecimals = IERC20(marketConfig.loanToken).decimals();

                    vm.broadcast();
                    oracle = deployCode(
                        "lib/morpho-blue-oracles/out/ChainlinkOracle.sol/ChainlinkOracle.json",
                        abi.encode(
                            marketConfig.oracle.vaultConversionSample > 1 ? marketConfig.collateralToken : address(0),
                            marketConfig.oracle.baseFeed1,
                            marketConfig.oracle.baseFeed2,
                            marketConfig.oracle.quoteFeed1,
                            marketConfig.oracle.quoteFeed2,
                            marketConfig.oracle.vaultConversionSample,
                            baseTokenDecimals,
                            quoteTokenDecimals
                        )
                    );

                    console2.log("  Deployed ChainlinkOracle at: %s", oracle);
                }

                MarketParams memory marketParams = MarketParams({
                    collateralToken: marketConfig.collateralToken,
                    loanToken: marketConfig.loanToken,
                    lltv: marketConfig.lltvs[j],
                    irm: address(irm),
                    oracle: oracle
                });

                console2.log("  Creating market %s...", vm.toString(Id.unwrap(marketParams.id())));

                vm.broadcast();
                morpho.createMarket(marketParams);
            }
        }

        // Transfer ownership
        console2.log("Set %s as owner...", config.owner);

        vm.broadcast();
        morpho.setOwner(config.owner);
    }
}
