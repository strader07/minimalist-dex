# Minimalist DEX - Proof of Concept

## Project Description

This project is a **minimalist Decentralized Exchange (DEX) proof of concept** that allows users to:

- **Add Liquidity**: Users can provide liquidity to token pairs and receive LP tokens.
- **Swap Tokens**: Users can swap tokens based on their USD price.
- **Remove Liquidity**: Users can remove liquidity based on percentage ownership of the pool.
- **Price Oracle Integration**: Prices are fetched from a USD-referenced **Price Oracle**.

The project is implemented in **Solidity** using **Foundry** for testing and **Sepolia Testnet** for deployment.

---

## Architecture

### Smart Contracts:

1. **MinimalistDEX.sol**
   - Core DEX contract.
   - Handles liquidity management, swaps, and LP token tracking.
2. **PriceOracle.sol**
   - Stores USD-referenced token prices.
   - Enables fair token swaps using real-time pricing.
3. **MockToken.sol**
   - A mock ERC20 token for testing.
   - Configurable token name, symbol, decimals, and supply.
4. **MLP.sol** (Minimalist Liquidity Pool Token)
   - ERC20-based LP token contract.
   - Tracks liquidity contributions of users.

---

### Assumptions and Scope Limitations

- The token pricing for swaps purely relies on the external price oracle.
- The token price has been assumed to be always valid, there is no explicit validation check.
- Slippage protection for swaps has been scoped out.
- No rewards logic was implemented for LP contributors.
- LP token allocation has been simplified without implying any business logic.

---

## Deployed Addresses

| Contract          | Address (Sepolia)                                                                                                                   |
| ----------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **MinimalistDEX** | [`0x62eA3e856A006e09DfF6DD70850f9c73f74Dec79`](https://sepolia.arbiscan.io/address/0x62eA3e856A006e09DfF6DD70850f9c73f74Dec79#code) |
| **PriceOracle**   | [`0xd32b0ccAD5deCfC9C7fAFbA89D918153202dbF4a`](https://sepolia.arbiscan.io/address/0xd32b0ccad5decfc9c7fafba89d918153202dbf4a#code) |
| **MockToken A**   | [`0x612de751150638dB0E8CC8eF53CD94005742faC2`](https://sepolia.arbiscan.io/address/0x612de751150638dB0E8CC8eF53CD94005742faC2#code) |
| **MockToken B**   | [`0x31b9DbB5A4d34c9e730d676Bf254f0e1b5eb03FA`](https://sepolia.arbiscan.io/address/0x31b9DbB5A4d34c9e730d676Bf254f0e1b5eb03FA#code) |
| **StableCoin A**  | [`0x8e0d3Ded296c324050EeF42662c6a778a96DFe73`](https://sepolia.arbiscan.io/address/0x8e0d3Ded296c324050EeF42662c6a778a96DFe73#code) |
| **StableCoin B**  | [`0xE7A42EF87A5B717B46940120A0E84e2399acff90`](https://sepolia.arbiscan.io/address/0xE7A42EF87A5B717B46940120A0E84e2399acff90#code) |

---

## Running Locally & Testing

### **Prerequisites**

1. Install Foundry:

   ```sh
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. Clone the repository:

   ```sh
   git clone https://github.com/your-repo/minimalist-dex.git
   cd minimalist-dex
   ```

3. Install dependencies:

   ```sh
   forge install
   ```

4. Build the contracts:
   ```sh
   forge build
   ```

### **Run Tests**

```sh
forge test -vv
```

#### **Run Specific Test File**

```sh
forge test ./test/MinimalistDEX.t.sol -vvvv
```

#### **Run Specific Tests**

```sh
forge test --match-test testSwapSamePriceDifferentDecimals
```

#### **Check Test Coverage**

```sh
forge coverage
```

#### **Test Results** (📊 Code Coverage)

| File                    | % Lines             | % Statements        | % Branches          | % Functions         |
| ----------------------- | ------------------- | ------------------- | ------------------- | ------------------- |
| `src/MinimalistDEX.sol` | 100.00% (59/59)     | 100.00% (62/62)     | 100.00% (19/19)     | 100.00% (8/8)       |
| `src/MockToken.sol`     | 100.00% (5/5)       | 100.00% (3/3)       | 100.00% (0/0)       | 100.00% (2/2)       |
| `src/PriceOracle.sol`   | 100.00% (6/6)       | 100.00% (4/4)       | 100.00% (2/2)       | 100.00% (2/2)       |
| **Total**               | **100.00% (70/70)** | **100.00% (69/69)** | **100.00% (21/21)** | **100.00% (12/12)** |

View the detailed coverage report [here](./coverage_report/index.html).

---

## Deployment & Verification

### **Deploy Contracts to Sepolia**

1. Create an `.env` file with your private key and RPC URL:

   ```sh
   SEPOLIA_RPC_URL=<your-rpc-url>
   ARB_SEPOLIA_RPC_URL=<your-rpc-url-in-arbitrum>
   ETHERSCAN_API_KEY=<your-etherscan-api-key>
   ARBISCAN_API_KEY=<your-arbiscan-api-key>
   PRIVATE_KEY=<your-private-key>
   ```

2. Deploy and verify with Foundry:

   ```sh
   souece .env

   forge script --chain arbitrum-sepolia script/DeployDex.s.sol:DeployDEX --rpc-url $ARB_SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify --etherscan-api-key $ARBISCAN_API_KEY
   ```

---

## Future Enhancements

- **Slippage Protection**: Prevent swaps from executing beyond a threshold price.
- **Real Oracle Integration**: Use Chainlink for real-time USD-based prices.
- **Liquidity Mining**: Introduce rewards for liquidity providers.
- **Market Making**: Improve asset pricing incorporating both of oracle and internal pool.
