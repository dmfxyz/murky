// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "./common/MurkyBase.sol";

/// @notice Nascent, simple, kinda efficient (and improving!) Merkle proof generator and verifier
/// @author dmfxyz
/// @dev Note Generic Merkle Tree
contract Merkle is MurkyBase {

    /********************
    * HASHING FUNCTION *
    ********************/

    function hashLeafPairs(bytes32 left, bytes32 right) public pure override returns (bytes32 _hash) {
       assembly {
           // TODO: This can be aesthetically simplified with a switch. Not sure it will
           // save much gas but there are other optimizations to be had in here.
           if or(lt(left, right), eq(left,right)) {
               mstore(0x0, left)
               mstore(0x20, right)
           }
           if gt(left, right) {
               mstore(0x0, right)
               mstore(0x20, left)
           }
           _hash := keccak256(0x0, 0x40)
       }
    }
}