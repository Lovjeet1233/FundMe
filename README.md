# FundMe Smart Contract

A decentralized crowdfunding smart contract built on Ethereum that allows users to fund projects with ETH and enables the contract owner to withdraw the collected funds.

## Overview

FundMe is a Solidity smart contract that:
- Accepts ETH payments from users
- Converts ETH to USD using Chainlink Price Feeds
- Enforces a minimum funding amount in USD
- Tracks all funders and their contribution amounts
- Allows only the contract owner to withdraw funds

## Features

- **Minimum Contribution**: Requires a minimum contribution of $5 USD (converted from ETH)
- **Price Conversion**: Uses Chainlink Price Feeds to get the latest ETH/USD exchange rate
- **Funder Tracking**: Maintains a list of all addresses that have funded the contract
- **Contribution Tracking**: Records the amount funded by each address
- **Owner-Only Withdrawal**: Only the contract creator can withdraw funds
- **Fallback Functions**: Contains `receive()` and `fallback()` functions to handle direct ETH transfers

## Functions

### Public Functions

- `fund()`: Allows users to fund the contract with ETH (must meet minimum USD value)
- `getLatestPrice()`: Retrieves the latest ETH/USD price from Chainlink
- `getConversionRate(uint256 ethAmount)`: Converts ETH amount to USD equivalent
- `getVersion()`: Returns the version of the Chainlink Price Feed being used
- `withDraw()`: Allows the owner to withdraw all funds and reset funder balances

### View/Pure Functions

- `minimumUsd`: Public variable that stores the minimum funding amount in USD (with 18 decimals)
- `funders`: Array containing addresses of all funders
- `addressToAmountFunded`: Mapping that tracks how much each address has funded
- `owner`: Address of the contract owner

## Security Features

- Owner verification for withdrawals
- Multiple withdrawal methods (transfer, send, call) for flexibility and security
- Input validation to ensure minimum funding requirements

## Usage

### As a Funder

To fund the contract:
1. Call the `fund()` function with ETH attached
2. Ensure the ETH value is equivalent to at least $5 USD
3. Your address will be added to the funders list and your contribution recorded

### As the Owner

To withdraw funds:
1. Call the `withDraw()` function
2. All funds will be transferred to your address
3. The funders array will be reset
4. All funder balances will be set to zero

## Technical Details

- Built with Solidity ^0.8.18
- Uses Chainlink Price Feed Oracle (AggregatorV3Interface)
- Price Feed Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
- Handles direct ETH transfers through receive() and fallback() functions

## License

SPDX-License-Identifier: MIT

## Development Notes

The contract includes multiple methods for sending ETH:
- `transfer`: Automatically reverts on failure
- `send`: Returns false on failure
- `call`: Currently used as the primary method (returns false on failure)

The contract also handles direct ETH transfers through:
- `receive()`: Called when ETH is sent with empty calldata
- `fallback()`: Called when ETH is sent with non-empty calldata

Both functions forward to the `fund()` function to ensure all contributions meet minimum requirements.
