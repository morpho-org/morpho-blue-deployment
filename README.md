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

> [!IMPORTANT]
> It is advised to use a dedicated address whose only purpose is to deploy all contracts associated with Blue so that addresses are common across EVM-compatible chains.

- `yarn`
- Add the network key and its corresponding RPC url to `foundry.toml`
- `yarn deploy:{component} {network} --broadcast` followed with appropriate private key management parameters

For example: `yarn deploy:morpho mainnet --broadcast --ledger`

## Licence

All scripts are licensed under [`GPL-2.0-or-later`](./LICENSE).
