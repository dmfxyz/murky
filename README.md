## Merkle Generator and Prover in Solidity

This repo contains a solidity contract `Merkle` that can generate and verify merkle proofs for items of type `bytes32`.

### Building Locally
You can run the repo using [Foundry](https://github.com/gakonst/foundry).
1. clone the repo
2. ```git submodule update --init```
3. `forge test`

### Deployment
A version of the contract is currently deployed on rinkeby: [0x6c510d5809a7b77d71a5f1be2d600c95065d7aa4](https://rinkeby.etherscan.io/address/0x6c510d5809a7b77d71a5f1be2d600c95065d7aa4)

### Notes
The tree is implemented as a XOR tree. This differs from OZ's proof implementation, which uses concatenation (and thus is a generic merkle tree). I think a XOR tree meets most use-cases, and is slightly more efficient: hashes are only calculated on 32 bytes instead of 64, and you don't have to worry about sibling ordering. 

A generic merkle tree implementation is incoming


#### TODO
* Add better single tests for gas optimization
* Address testing
