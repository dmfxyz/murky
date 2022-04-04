// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;
import "ds-test/test.sol";

bytes32 constant empty_leaf = 0;
contract Merkle is DSTest {

    constructor() {}

    function hashLevel(bytes32[] memory data) public pure returns (bytes32[] memory) {
        require(data.length > 0, "cannot hash empty level");
        bool oddCount = data.length % 2 == 1;
        bytes32[] memory result;

        if (oddCount){
            result = new bytes32[](data.length / 2 + 1);
            result[result.length - 1] = hashLeafPairs(data[data.length - 1], bytes32(0));
        } else {
            result = new bytes32[](data.length / 2);
        }

        uint256 pos = 0;
        for (uint256 i = 0; i < data.length-1; i+=2){
            result[pos] = hashLeafPairs(data[i], data[i+1]);
            ++pos;
        }

        return result;


    }

    function hashLeafPairs(bytes32 left, bytes32 right) public pure returns (bytes32) {
        return keccak256(abi.encode(left ^ right));
    }

    function getRoot(bytes32[] memory data) public pure returns (bytes32) {
        bytes32[] memory result = data;

        while(result.length > 1) {
            result = hashLevel(result);
        }
        return result[0];
    }

    function getProof(bytes32[] memory data, uint256 layer) public returns (bytes32[] memory) {

        // NOTE::  This could definitely over/underflow. Got to investigate edge cases. 
        // NOTE:: Also, this: https://graphics.stanford.edu/~seander/bithacks.html#IntegerLogDeBruijn
        // The size of the proof is equal to the ceiling of log2(numLeaves) 
        // Calculate this ceiling by repeatedly shifting the length uint until there are no set bits left
        uint256 ls = data.length;
        uint256 proofsize = 0;
        while(ls > 0){
            ls >>= 1;
            ++proofsize;
        }

        // handles case where numLeaves is eq to 2^n, n E Z-+, in this case the above overshoots by 1.
        uint256 lsb = (~data.length + 1) & data.length;
        if (lsb == data.length) {
            --proofsize;
        }
        
        //uint256 proofsize = log2ceil(data.length);
        bytes32[] memory result = new bytes32[](proofsize);
        bytes32[] memory curData = data;
        uint256 currentLayer = layer;
        uint256 pos = 0;
        while(curData.length > 1) {

            if(layer % 2 == 1) {
                result[pos] = curData[layer - 1];
            } else {
                if (layer + 1 == curData.length){
                    result[pos] = bytes32(0);  
                } else {
                    result[pos] = curData[layer + 1];
                }
            }
            ++pos;
            layer = layer / 2;
            curData = hashLevel(curData);
        }

        return result;
    }
}
