// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

contract ScriptHelper is Script {
    function compareStrings(string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function stringArrayToString(string[] memory array) internal pure returns (string memory) {
        string memory result = "[";

        for (uint i = 0; i < array.length; i++) {
            if (i != array.length - 1)
                result = string.concat(result, "\"", array[i], "\",");
            else
                result = string.concat(result, "\"", array[i], "\"");
        }

        return string.concat(result, "]");
    }
    function stringArrayToArrayString(string[] memory array) internal pure returns (string memory) {
        string memory result = "[";

        for (uint i = 0; i < array.length; i++) {
            if (i != array.length - 1)
                result = string.concat(result, array[i], ",");
            else
                result = string.concat(result, array[i]);
        }

        return string.concat(result, "]");
    }

    function bytes32ArrayToString(bytes32[] memory array) internal pure returns (string memory) {
        string memory result = "[";

        for (uint i = 0; i < array.length; i++) {
            if (i != array.length - 1)
                result = string.concat(result, "\"", vm.toString(array[i]), "\",");
            else
                result = string.concat(result, "\"", vm.toString(array[i]), "\"");
        }

        return string.concat(result, "]");
    }
}