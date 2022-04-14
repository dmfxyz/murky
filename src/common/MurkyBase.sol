// LICENSE IDENTIFIER: MIT
pragma solidity 0.8.13;

abstract contract MurkyBase {
    /***************
    * CONSTRUCTOR *
    ***************/
    constructor() {}

    /********************
    * HASING FUNCTIONS *
    ********************/
    function hashLeafPairs(bytes32 left, bytes32 right) public pure virtual returns (bytes32 _hash);


    /**********************
    * PROOF VERIFICATION *
    **********************/
    
    function verifyProof(bytes32 root, bytes32[] memory proof, bytes32 valueToProve) public pure returns (bool) {
        // proof length must be less than max array size
        bytes32 rollingHash = valueToProve;
        unchecked {
            for(uint i = 0; i < proof.length; ++i){
                rollingHash = hashLeafPairs(rollingHash, proof[i]);
            }
        }
        return root == rollingHash;
    }

    /********************
    * PROOF GENERATION *
    ********************/

    function getRoot(bytes32[] memory data) public pure returns (bytes32) {
        require(data.length > 1, "won't generate root for single leaf");
        while(data.length > 1) {
            data = hashLevel(data);
        }
        return data[0];
    }

    function getProof(bytes32[] memory data, uint256 node) public pure returns (bytes32[] memory) {
        require(data.length > 1, "won't generate proof for single leaf");
        // The size of the proof is equal to the ceiling of log2(numLeaves) 
        bytes32[] memory result = new bytes32[](log2ceil_naive(data.length));
        uint256 pos = 0;

        // Two overflow risks: node, pos
        // node: max array size is 2**256-1. Largest index in the array will be 1 less than that. Also,
           // for dynamic arrays, size is limited to 2**64-1
        // pos: pos is bounded by log2(data.length), which should be less than type(uint256).max 
        while(data.length > 1) {
            unchecked {
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
            }
            data = hashLevel(data);
        }
        return result;
    }

    function hashLevel(bytes32[] memory data) internal pure returns (bytes32[] memory) {
        bytes32[] memory result;

        // TODO: can store data.length to avoid mload calls
        if (data.length % 2 == 1){
            result = new bytes32[](data.length / 2 + 1);
            result[result.length - 1] = hashLeafPairs(data[data.length - 1], bytes32(0));
        } else {
            result = new bytes32[](data.length / 2);
        }

        // pos is upper bounded by data.length / 2, so safe even if array is at max size
        unchecked {
            uint256 pos = 0;
            for (uint256 i = 0; i < data.length-1; i+=2){
                result[pos] = hashLeafPairs(data[i], data[i+1]);
                ++pos;
            }
        }
        return result;
    }

    /******************
    * MATH "LIBRARY" *
    ******************/
    
    /// @dev  Note that x is assumed > 0
    function log2ceil_naive(uint256 x) public pure returns (uint256) {
        uint256 ceil = 0;
        uint256 lsb = (~x + 1) & x;
        bool powerOf2 = x == lsb;
        
        // if x == type(uint256).max, than ceil is capped at 256
        // if x == 0, then (~x + 1) & x == 0, so ceil won't underflow
        unchecked {
            while( x > 0) {
                x >>= 1;
                ceil++;
            }
            if (powerOf2) {
                ceil--;
            }
        }
        return ceil;
    }

    /// Original bitmagic adapted from https://github.com/paulrberg/prb-math/blob/main/contracts/PRBMath.sol
    /// @dev Note that x assumed > 1
    function log2ceil_bitmagic(uint256 x) public pure returns (uint256){
        if (x <= 1) {
            return 0;
        }
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