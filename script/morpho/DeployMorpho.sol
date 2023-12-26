// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import {IMorpho, MarketParams} from "../../lib/morpho-blue/src/interfaces/IMorpho.sol";
import {MarketParamsLib} from "../../lib/morpho-blue/src/libraries/MarketParamsLib.sol";

import "../ConfiguredScript.sol";

/// @dev Warning: keys must be ordered alphabetically.
struct DeployMorphoSalt {
    bytes32 irm;
    bytes32 morpho;
}

/// @dev Warning: keys must be ordered alphabetically.
struct DeployMorphoConfig {
    uint256[] lltvs;
    address owner;
    DeployMorphoSalt salt;
}

contract DeployMorpho is ConfiguredScript {
    using MarketParamsLib for MarketParams;

    function _scriptDir() internal pure override returns (string memory) {
        return "morpho";
    }

    function run(string memory network) public returns (DeployMorphoConfig memory config) {
        config = abi.decode(_init(network, false), (DeployMorphoConfig));

        // Deploy Morpho Blue
        morpho = IMorpho(_deployCreate2Code("morpho-blue", "Morpho", abi.encode(msg.sender), config.salt.morpho));

        // Deploy & enable AdaptiveCurveIrm
        irm = IAdaptiveCurveIrm(
            _deployCreate2Code("morpho-blue-irm", "AdaptiveCurveIrm", abi.encode(address(morpho)), config.salt.irm)
        );

        require(irm.MORPHO() == address(morpho), "unexpected morpho");

        vm.broadcast();
        morpho.enableIrm(address(irm));
        vm.broadcast();
        morpho.enableIrm(address(0));

        require(morpho.isIrmEnabled(address(irm)), "irm not enabled");
        require(morpho.isIrmEnabled(address(0)), "address(0) not enabled");

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
