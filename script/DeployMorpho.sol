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
        morpho = IMorpho(_deployCreate2Code("morpho-blue", "Morpho", abi.encode(msg.sender), config.salt));

        // Deploy & enable AdaptiveCurveIrm
        irm = IAdaptiveCurveIrm(_deployCode("morpho-blue-irm", "AdaptiveCurveIrm", abi.encode(address(morpho))));

        require(irm.MORPHO() == address(morpho), "unexpected morpho");

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
