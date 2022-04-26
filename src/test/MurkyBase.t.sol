pragma solidity 0.8.13;

import "forge-std/Test.sol";
import "../common/MurkyBase.sol";

contract MurkyBaseTest is Test, MurkyBase {

    // Hacky way to test the base functions until transitioned to library
    function hashLeafPairs(bytes32, bytes32) public pure virtual override returns (bytes32) {
        return bytes32(0x0);
    }

    function testLogCeil_naive(uint256 x) public{
        vm.assume(x > 0);
        this.log2ceil_naive(x);
    }

    function testLogCeil_bitmagic(uint256 x) public {
        vm.assume(x > 0);
        this.log2ceil_bitmagic(x);
    }


    function testLogCeil_KnownPowerOf2() public {
        assertEq(3, this.log2ceil_bitmagic(8));
    }
    function testLogCeil_Known() public {
        assertEq(8, this.log2ceil_bitmagic(129));
    }

}