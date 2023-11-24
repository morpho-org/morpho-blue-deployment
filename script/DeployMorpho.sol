// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IERC20} from "../lib/forge-std/src/interfaces/IERC20.sol";

import {Morpho, MarketParams, MarketParamsLib, Id} from "../lib/morpho-blue/src/Morpho.sol";

import "./ConfiguredScript.sol";

contract DeployMorpho is ConfiguredScript {
    using MarketParamsLib for MarketParams;

    function run(string memory network) external {
        DeployConfig memory config = _initConfig(network);

        console2.log("Running deployment script using %s...", msg.sender);

        // Deploy Morpho Blue
        vm.broadcast();
        morpho = IMorpho(address(new Morpho{salt: config.salt}(msg.sender)));

        console2.log("Deployed Morpho Blue at: %s", address(morpho));

        // Deploy & enable AdaptiveCurveIrm
        vm.broadcast();
        address irm = deployCode(
            "lib/morpho-blue-irm/out/AdaptiveCurveIrm.sol/AdaptiveCurveIrm.json",
            abi.encode(
                address(morpho),
                config.adaptiveCurveIrm.curveSteepness,
                config.adaptiveCurveIrm.adjustmentSpeed,
                config.adaptiveCurveIrm.targetUtilization,
                config.adaptiveCurveIrm.initialRateAtTarget
            )
        );

        console2.log("Deployed AdaptiveCurveIrm at: %s", irm);

        vm.broadcast();
        morpho.enableIrm(irm);

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
                            marketConfig.oracle.vault,
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
                    irm: irm,
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
