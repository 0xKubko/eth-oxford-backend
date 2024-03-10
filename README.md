## FairDAO

Automating donations to impactful blockchain initiatives through Ethereum staking.

Project built for ETH Oxford

### Build

```shell
$ forge build
```


### Scripts

First, create an ``.env`` file where you add the required variables.

```shell
$ forge script script/Deploy.s.sol --broadcast
```

Put the deployed MockETH and CharityVault addresses into ``.env`` file so the future scripts can work automatically

```shell
$ forge script script/Depost.s.sol --broadcast
```

```shell
$ forge script script/SetCharityAddress.s.sol --broadcast
```

```shell
$ forge script script/Simulate.s.sol --broadcast
```