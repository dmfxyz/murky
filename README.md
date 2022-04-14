## Merkle Generator and Prover in Solidity

This repo contains a solidity contracts that can generate and verify merkle proofs for items of type `bytes32`. Both XOR based hashing and a concatenation based hashing are currently supported.

The root, proof generation, and verification functions are all fuzzed tested (configured 5,000 runs by default) using arbitrary bytes32 arrays and target leafs.

> Note: Code is not audited (yet). Please do your own due dilligence testing if you are planning to use this code!

### Building Locally
You can run the repo using [Foundry](https://github.com/gakonst/foundry).
1. clone the repo
2. ```git submodule update --init```
3. `forge test`

### Example Usage
```solidity
// Initialize
Merkle m = new Merkle();
// Toy Data
bytes32[] memory data = new bytes32[](4);
data[0] = bytes32("0x0");
data[1] = bytes32("0x1");
data[2] = bytes32("0x2");
data[3] = bytes32("0x3");
// Get Root, Proof, and Verify
bytes32 root = m.getRoot(data);
bytes32[] memory proof = m.getProof(data, 2); // will get proof for 0x2 value
bool verified = m.verifyProof(root, proof, data[2]); // true!
assertTrue(verified);
```

### Notes
* `Xorkle.sol` is implemented as a XOR tree. This allows for greater gas efficiency: hashes are calculated on 32 bytes instead of 64; it is agnostic of sibling order so there is less lt/gt branching. Note that XOR trees are not appropriate for all use-cases*.

* `Merkle.sol` is implemented using concatenation as thus is a generic merkle tree. It's less efficient, but compatible with [OpenZeppelin's Prover](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/cryptography/MerkleProof.sol) and other implementations. Use this one if you aren't sure. Compatiblity with OZ Prover is implemented as a fuzzed test.

### Deployment
OUTDATED::: A version of the contract is currently deployed on rinkeby: [0x6c510d5809a7b77d71a5f1be2d600c95065d7aa4](https://rinkeby.etherscan.io/address/0x6c510d5809a7b77d71a5f1be2d600c95065d7aa4)


#### TODO
- [x] Create standardized tests using FFI
- [x] Abstract out base implementation
- [x] Test results match with openzeppelin verification implementation
- [ ] \* Do a writeup on the use-cases for XORs.
- [ ] Update existing FFI test data to be less high MSB biased. Also, in general the standardized testing design needs some work.
- [ ] Write some FFI tests to verify compatibility with [uniswap merkle deployer](https://github.com/Uniswap/merkle-distributor/tree/master/src)
- [ ] Migrate to library and adjust testing accordingly
- [ ] Gas optimization for GenericMerkle (and also some lingering optimizations for merkle)

#### Latest Gas
![gas report](./reports/murky_gas_report.png)

[Gas Snapshots](./.gas-snapshot) are run only on the standardized tests:
```sh
forge snapshot --match-path src/test/StandardInput.t.sol
```

