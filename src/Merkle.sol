// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

bytes32 constant empty_leaf = 0;
contract Merkle {

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

        while(data.length > 1) {
            data = hashLevel(data);
        }
        return data[0];
    }

    function getProof(bytes32[] memory data, uint256 node) public pure returns (bytes32[] memory) {
        // The size of the proof is equal to the ceiling of log2(numLeaves) 
        uint256 proofsize = log2ceil_naive(data.length);

        bytes32[] memory result = new bytes32[](proofsize);
        uint256 pos = 0;
        while(data.length > 1) {

            if(node % 2 == 1) {
                result[pos] = data[node - 1];
            } 
            else if (node + 1 == data.length) {
                result[pos] = bytes32(0);  
            } 
            else {
                result[pos] = data[node + 1];
            }
            ++pos;
            node = node / 2;
            data = hashLevel(data);
        }

        return result;
    }

    function verifyProof(bytes32 root, bytes32[] memory proof, bytes32 valueToProve) public pure returns (bool) {
        for(uint i = 0; i < proof.length; ++i){
            valueToProve = hashLeafPairs(valueToProve, proof[i]);
        }
        return root == valueToProve;
    }

    // assumes x > 0;
    function log2ceil_naive(uint256 x) public pure returns (uint256) {
        uint256 ceil = 0;
        uint256 lsb = (~x + 1) & x;
        bool powerOf2 = x == lsb;
        while( x > 0) {
            x >>= 1;
            ceil++;
        }
       
        if (powerOf2) {
            ceil--;
        }
        return ceil;
    }

    // Original bitmagic adapted from https://github.com/paulrberg/prb-math/blob/main/contracts/PRBMath.sol
    // assumes x > 1;
    function log2ceil_bitmagic(uint256 x) public pure returns (uint256){
        uint256 msb;
        uint256 _x = x;
        if (x >= 2**128) {
            x >>= 128;
            msb += 128;
        }
        if (x >= 2**64) {
            x >>= 64;
            msb += 64;
        }
        if (x >= 2**32) {
            x >>= 32;
            msb += 32;
        }
        if (x >= 2**16) {
            x >>= 16;
            msb += 16;
        }
        if (x >= 2**8) {
            x >>= 8;
            msb += 8;
        }
        if (x >= 2**4) {
            x >>= 4;
            msb += 4;
        }
        if (x >= 2**2) {
            x >>= 2;
            msb += 2;
        }
        if (x >= 2**1) {
            msb += 1;
        }

        
        uint256 lsb = (~_x + 1) & _x;
        if ((lsb == _x) && (msb > 0)) {
            return msb;
        } else {
            return msb + 1;
        }
    }
}
