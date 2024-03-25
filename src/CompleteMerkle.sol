// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./common/MurkyBase.sol";

/// @notice simple, kinda efficient (and improving!) Merkle proof generator and verifier using complete binary trees
/// @author dmfxyz
/// @dev Note Merkle Tree implemented as a Complete Binary Tree
contract CompleteMerkle is MurkyBase {
    /**
     *
     * HASHING FUNCTION *
     *
     */
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

    function _initTree(bytes32[] memory data) internal pure returns (bytes32[] memory) {
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

    function buildTree(bytes32[] memory data) private pure returns (bytes32[] memory) {
        bytes32[] memory tree = _initTree(data);
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
                let posToWrite := add(tree, shr(1, mul(sub(i, 1), 0x20)))
                mstore(posToWrite, hash_leafs(left, right))
            }
        }
        return tree;
    }

    function getRoot(bytes32[] memory data) public pure override returns (bytes32) {
        require(data.length > 1, "wont generate root for single leaf");
        bytes32[] memory tree = buildTree(data);
        return tree[0];
    }

    function verifyProof(bytes32 root, bytes32[] memory proof, bytes32 valueToProve)
        external
        pure
        override
        returns (bool)
    {
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
            let roll := mload(0x40) // TODO CHECK Sv.s.M
            mstore(roll, valueToProve)
            let len := mload(proof)
            for { let i := 0 } lt(i, len) { i := add(i, 1) } {
                mstore(roll, hash_leafs(mload(roll), mload(add(add(proof, 0x20), mul(i, 0x20)))))
            }
            mstore(roll, eq(mload(roll), root))
            return(roll, 0x20)
        }
    }

    function getProof(bytes32[] memory data, uint256 index) public pure override returns (bytes32[] memory) {
        require(data.length > 1, "wont generate proof for single leaf");
        bytes32[] memory tree = buildTree(data);

        assembly {
            let iter := sub(sub(mload(tree), index), 0x1)
            let ptr := mload(0x40)
            mstore(ptr, 0x20)
            let proofSizePtr := add(ptr, 0x20)
            let proofIndexPtr := add(ptr, 0x40)
            for {} 0x1 {} {
                // while (true)
                let sibling := mload(add(tree, mul(add(iter, shl(0x1, and(iter, 0x1))), 0x20)))
                mstore(proofIndexPtr, sibling)
                iter := shr(1, sub(iter, eq(and(iter, 0x1), 0x0)))
                if eq(iter, 0x0) { break }
                proofIndexPtr := add(proofIndexPtr, 0x20)
            }
            mstore(proofSizePtr, div(sub(proofIndexPtr, proofSizePtr), 0x20))
            return(ptr, add(0x40, sub(proofIndexPtr, proofSizePtr)))
        }
    }
}
