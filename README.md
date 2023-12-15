# Morpho Blue Deployment

Morpho Blue is a noncustodial lending protocol implemented for the Ethereum Virtual Machine.
Morpho Blue offers a new trustless primitive with increased efficiency and flexibility compared to existing lending platforms.
It provides permissionless risk management and permissionless market creation with oracle agnostic pricing.
It also enables higher collateralization factors, improved interest rates, and lower gas consumption.
The protocol is designed to be a simple, immutable, and governance-minimized base layer that allows for a wide variety of other layers to be built on top.
Morpho Blue also offers a convenient developer experience with a singleton implementation, callbacks, free flash loans, and account management features.

## Whitepaper

The protocol is described in detail in the [Morpho Blue Whitepaper](./morpho-blue-whitepaper.pdf).

## Getting Started

### Installation

- `yarn`
- `cp .env.example .env`

### Deployment

- Add the desired network key and its corresponding RPC url to `foundry.toml`
- `yarn deploy:{component} {network} --broadcast --slow --sender {sender}` followed with appropriate private key management parameters

> [!NOTE]
> If the provided network's RPC url uses a variable environment (such as `ALCHEMY_KEY`), it should be defined in your `.env`

For example: `yarn deploy:morpho goerli --broadcast --slow --ledger --sender 0x7Ef4174aFdF4514F556439fa2822212278151Db6`

All deployments that require an instance of Morpho expects that instance to have previously been deployed on the same network using `yarn deploy:morpho {network} --broadcast`, so that Morpho's address is saved and committed to this repository in [broadcast logs](./broadcast/DeployMorpho.sol/1/run-latest.json).

> [!NOTE]
> Broadcast run logs are to be committed to this repository for future reference.


### Etherscan verification

> [!NOTE]
> Your `.env` should contain a valid `ETHERSCAN_API_KEY`.

After each contract deployed, a verification command is automatically added to the verify script associated to the component deployed (for example: [`script/morpho/verify.sh`](script/morpho/verify.sh)).

- Verify all contracts deployed for a component: `yarn verify:{component}`

For example: `yarn verify:morpho`

> [!NOTE]
> Verify scripts are **NOT** to be committed to this repository because they are expected to be run only once.


## License

All scripts are licensed under [`MIT`](./LICENSE).
