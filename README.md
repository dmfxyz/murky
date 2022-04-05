## Merkle Generator and Prover in Solidity

This repo contains a solidity contract `Merkle` that can generate and verify merkle proofs for items of type `bytes32`.

It is still a WIP. Major areas of focus are:  
1. Comment and clean up code
2. Explore optimal `log2ceil` implementations
3. Further optimizations beyond `log2ceil`

You can run the repo using [Foundry](https://github.com/gakonst/foundry).
1. clone the repo
2. ```git submodule update --init```
3. `forge test`
