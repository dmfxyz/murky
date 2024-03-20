// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./common/MurkyBase.sol";

/// @notice Nascent, simple, kinda efficient (and improving!) Merkle proof generator and verifier
/// @author dmfxyz
/// @dev Note Generic Merkle Tree
contract CompleteMerkle is MurkyBase {
    /**
     *
     * HASHING FUNCTION *
     *
     */

    /// ascending sort and concat prior to hashing
    function hashLeafPairs(bytes32 left, bytes32 right) public pure override returns (bytes32 _hash) {
        assembly {
           switch lt(left, right)
           case 0 {
               mstore(0x0, right)
               mstore(0x20, left)
           }
           default {
               mstore(0x0, left)
               mstore(0x20, right)
           }
           _hash := keccak256(0x0, 0x40)
        }
    }

    function _getTree(bytes32[] memory data) public pure returns (bytes32[] memory) {
        require(data.length > 1, "won't generate root for single leaf");

        bytes32[] memory tree = new bytes32[](2 * data.length - 1);
        assembly {
            let dlen := mload(data)
            let titer := add(sub(mload(tree), dlen), 1)
            for {let i := add(data, mul(dlen, 0x20))} gt(i, data) { i := sub(i, 0x20)} {
                mstore(add(tree, mul(titer, 0x20)), mload(i))
                titer := add(titer, 1)
            }
         }
        //  for (uint256 i = 0; i < data.length; ++i) {
        //     tree[tree.length - i - 1] = data[i];
        // }
        return tree;
    }

    function getRoot(bytes32[] memory data) public pure override returns (bytes32) {
        bytes32[] memory tree = _getTree(data);
        assembly {
            function hash_leafs(left, right) -> _hash {
                switch lt(left, right)
                case 0 {
                    mstore(0x0, right)
                    mstore(0x20, left)
                }
                default {
                    mstore(0x0, left)
                    mstore(0x20, right)
                }
                _hash := keccak256(0x0, 0x40)
            }
            for {let i := mload(tree)} gt(i, 1) {i := sub(i, 2)} {
                // TODO: clean all this up, mainly broken out for early understanding and debugging
                let left := mload(add(tree, mul(sub(i, 1), 0x20)))
                let right := mload(add(tree, mul(i, 0x20)))
                let indexToWrite := div(sub(i, 1), 2)
                let posToWrite := add(tree, mul(indexToWrite, 0x20))
                mstore(posToWrite, hash_leafs(left, right))
            }
        }
        // for (uint256 i = tree.length - 1; i > 0; i -= 2) {
        //     uint256 posToWrite = (i - 1) / 2;
        //     tree[posToWrite] = hashLeafPairs(tree[i - 1], tree[i]);
        // }
        return tree[0];
    }
}
