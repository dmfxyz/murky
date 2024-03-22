// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

/// @notice Nascent, simple, kinda efficient (and improving!) Merkle proof generator and verifier
/// @author dmfxyz
/// @dev Note Generic Merkle Tree
contract CompleteMerkle {
    /**
     *
     * HASHING FUNCTION *
     *
     */
    function initTree(bytes32[] memory data) private pure returns (bytes32[] memory) {
        require(data.length > 1, "wont generate root for single leaf");

        bytes32[] memory tree = new bytes32[](2 * data.length - 1);
        assembly {
            let dlen := mload(data)
            let titer := add(sub(mload(tree), dlen), 1)
            for { let i := add(data, mul(dlen, 0x20)) } gt(i, data) { i := sub(i, 0x20) } {
                mstore(add(tree, mul(titer, 0x20)), mload(i))
                titer := add(titer, 1)
            }
        }
        return tree;
    }

    function buildTree(bytes32[] memory data) public pure returns (bytes32[] memory) {
        bytes32[] memory tree = initTree(data);
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
            for { let i := mload(tree) } gt(i, 1) { i := sub(i, 2) } {
                // TODO: clean all this up, mainly broken out for early understanding and debugging
                let left := mload(add(tree, mul(sub(i, 1), 0x20)))
                let right := mload(add(tree, mul(i, 0x20)))
                let indexToWrite := div(sub(i, 1), 2)
                let posToWrite := add(tree, mul(indexToWrite, 0x20))
                mstore(posToWrite, hash_leafs(left, right))
            }
        }
        return tree;
    }

    function getRoot(bytes32[] memory data) public pure returns (bytes32) {
        bytes32[] memory tree = buildTree(data);
        return tree[0];
    }

    function verifyProof(bytes32 root, bytes32[] memory proof, bytes32 valueToProve) external pure returns (bool) {
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
            let roll := mload(0x40)
            mstore(roll, valueToProve)
            let len := mload(proof)
            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                mstore(roll, hash_leafs(mload(roll), mload(add(add(proof, 0x20), mul(i, 0x20)))))
            }
            mstore(roll, eq(mload(roll), root))
            return(roll, 0x20)
        }
    }

    function getProof(bytes32[] memory data, uint256 index) public pure returns (bytes32[] memory) {
        require(index < data.length);
        bytes32[] memory tree = buildTree(data);

        assembly {
            let iter := sub(sub(mload(tree), index), 0x1)
            let ptr := mload(0x40)
            mstore(ptr, 0x20)
            let proofSizePtr := add(ptr, 0x20)
            let proofIndexPtr := proofSizePtr
            for {} eq(0x0, 0x0) {} {
                // WHile true
                switch eq(iter, 0)
                case 1 { break }
                mstore(proofSizePtr, add(mload(proofSizePtr), 0x1))
                proofIndexPtr := add(proofIndexPtr, 0x20)
                switch and(iter, 0x1)
                case 0x1 {
                    // iter is ODD
                    let sibling := mload(add(add(tree, 0x20), mul(add(iter, 1), 0x20)))
                    mstore(proofIndexPtr, sibling)
                    iter := div(iter, 2)
                }
                default {
                    // iter is EVEN
                    let sibling := mload(add(add(tree, 0x20), mul(sub(iter, 1), 0x20)))
                    mstore(proofIndexPtr, sibling)
                    iter := div(sub(iter, 1), 2)
                }
            }
            mstore(0x40, add(proofIndexPtr, 0x20))
            return(ptr, add(0x20, sub(add(proofIndexPtr, 0x20), proofSizePtr)))
        }
    }
}
