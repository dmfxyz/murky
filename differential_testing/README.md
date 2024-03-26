## Differential Testing
Differential testing is used to compare Murky's solidity implementation to reference implementations in other languages. This directory contains the scripts needed to support this testing, as well as the differential tests themselves.

Currently two reference implementations are tested. The first is adapted from [Uniswap/merkle-distributor](https://github.com/uniswap/merkle-distributor), and the second is from [OpenZeppelin/merkle-tree](https://github.com/OpenZeppelin/merkle-tree). Both are written in Javascript.


### Setup
From the [scripts directory](./scripts/), run
```sh
npm install
npm run compile
```


### Test the javascript implementation
From the scripts directory:
1. To test that the Uniswap/merkle-distributor differential test will work:
```sh
npm run generate-root
```

2. To test that the OpenZeppelin/merkle-tree differential test will work:
```sh
npm run generate-complete-root ../data/complete_root_input.json
npm run generate-complete-proof ../data/complete_proof_input.json
```

If all commands output data without exception, then you are ready to run the differential tests. 
### Run the differential test using foundry
Now you can run the tests.  
From the **root** of the Murky repo, run:
```sh
forge test --ffi --contracts differential_testing/test/
```
> Note: The differential tests can take some time to run. An extended period of time without output does not necessarily indicate a problem.



