// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IMorpho, MarketParams} from "../lib/morpho-blue/src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "../lib/morpho-blue/src/libraries/MarketParamsLib.sol";

import "./config/ConfiguredScript.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct DeployMorphoConfig {
    uint256[] lltvs;
    address owner;
    bytes32 salt;
}

contract DeployMorpho is ConfiguredScript {
    using MarketParamsLib for MarketParams;

    function _configDir() internal pure override returns (string memory) {
        return "morpho";
    }

    function run(string memory network) public returns (DeployMorphoConfig memory config) {
        config = abi.decode(_init(network, false), (DeployMorphoConfig));

        // Deploy Morpho Blue
        vm.broadcast();
        morpho = IMorpho(
            _deployCreate2Code("lib/morpho-blue/out/Morpho.sol/Morpho.json", abi.encode(msg.sender), config.salt)
        );

        console2.log("Deployed Morpho Blue at: %s", address(morpho));

        // Deploy & enable AdaptiveCurveIrm
        vm.broadcast();
        irm = IAdaptiveCurveIrm(
            deployCode(
                "lib/morpho-blue-irm/out/AdaptiveCurveIrm.sol/AdaptiveCurveIrm.json", abi.encode(address(morpho))
            )
        );

        require(irm.MORPHO() == address(morpho), "unexpected morpho");

        console2.log("Deployed AdaptiveCurveIrm at: %s", address(irm));

        vm.broadcast();
        morpho.enableIrm(address(irm));

        require(morpho.isIrmEnabled(address(irm)), "irm not enabled");

        // Enable all LLTVs
        for (uint256 i; i < config.lltvs.length; ++i) {
            uint256 lltv = config.lltvs[i];

            console2.log("Enabling LLTV %e...", lltv);

            vm.broadcast();
            morpho.enableLltv(lltv);

            require(morpho.isLltvEnabled(lltv), string.concat("lltv not enabled: ", vm.toString(lltv)));
        }

        // Transfer ownership
        console2.log("Set %s as owner...", config.owner);

        vm.broadcast();
        morpho.setOwner(config.owner);

        require(morpho.owner() == config.owner, "unexpected owner");
    }
}
