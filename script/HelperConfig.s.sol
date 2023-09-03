// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIL_PRICE = 1700e8;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaNetworkConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetNetworkConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilNetworkConfig();
        }
    }

    function getSepoliaNetworkConfig()
        public
        pure
        returns (NetworkConfig memory sepoliaConfig)
    {
        sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    function getMainnetNetworkConfig()
        public
        pure
        returns (NetworkConfig memory mainnetConfig)
    {
        mainnetConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
    }

    function getOrCreateAnvilNetworkConfig()
        public
        returns (NetworkConfig memory anvilConfig)
    {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIL_PRICE
        );
        vm.stopBroadcast();

        anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
    }
}
