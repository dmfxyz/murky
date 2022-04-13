## Merkle Generator and Prover in Solidity

This repo contains a solidity contracts that can generate and verify merkle proofs for items of type `bytes32`. Both a XOR based hashing and a concatenation based hashing are currently supported.

### Building Locally
You can run the repo using [Foundry](https://github.com/gakonst/foundry).
1. clone the repo
2. ```git submodule update --init```
3. `forge test`

### Deployment
OUTDATED::: A version of the contract is currently deployed on rinkeby: [0x6c510d5809a7b77d71a5f1be2d600c95065d7aa4](https://rinkeby.etherscan.io/address/0x6c510d5809a7b77d71a5f1be2d600c95065d7aa4)

### Notes
* `Merkle.sol` is implemented as a XOR tree. This allows for greater gas efficiency: hashes are calculated on 32 bytes instead of 64; it is agnostic of sibling order so there is less lt/gt branching. Note that XOR trees are not appropriate for all use-cases*.

* `GenericMerkle.sol` is implemented using concatenation as thus is a generic merkle tree. It's less efficient, but compatible with [OpenZeppelin's Prover](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol) and other implementations. Use this one if you aren't sure. Compatiblity with OZ Prover is implemented as a fuzzed test.


#### TODO
* \* Do a writeup on the use-cases for XORs.
* Write some FFI tests to verify compatibility with [uniswap merkle deployer](https://github.com/Uniswap/merkle-distributor/tree/master/src)
* Migrate to library and adjust testing accordingly
* Gas optimization for GenericMerkle (and also some lingering optimizations for merkle)
