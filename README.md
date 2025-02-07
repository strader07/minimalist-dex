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

| Contract          | Address (Sepolia) |
| ----------------- | ----------------- |
| **MinimalistDEX** | `0x...`           |
| **PriceOracle**   | `0x...`           |
| **MockToken A**   | `0x...`           |
| **MockToken B**   | `0x...`           |

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

### **Run Specific Test File**

```sh
forge test ./test/MinimalistDEX.t.sol -vvvv
```

### **Run Specific Tests**

```sh
forge test --match-test testSwapSamePriceDifferentDecimals
```

### **Check Test Coverage**

```sh
forge coverage
```

### **Test Results**

╭-----------------------+-----------------+-----------------+-----------------+-----------------╮
| File | % Lines | % Statements | % Branches | % Funcs |
+===============================================================================================+
| src/MinimalistDEX.sol | 100.00% (59/59) | 100.00% (62/62) | 100.00% (19/19) | 100.00% (8/8) |
|-----------------------+-----------------+-----------------+-----------------+-----------------|
| src/MockToken.sol | 100.00% (5/5) | 100.00% (3/3) | 100.00% (0/0) | 100.00% (2/2) |
|-----------------------+-----------------+-----------------+-----------------+-----------------|
| src/PriceOracle.sol | 100.00% (6/6) | 100.00% (4/4) | 100.00% (2/2) | 100.00% (2/2) |
|-----------------------+-----------------+-----------------+-----------------+-----------------|
| Total | 100.00% (70/70) | 100.00% (69/69) | 100.00% (21/21) | 100.00% (12/12) |
╰-----------------------+-----------------+-----------------+-----------------+-----------------╯

View the detailed coverage report [here](./coverage_report/index.html).

---

## Deployment & Verification

### **Deploy Contracts to Sepolia**

1. Create an `.env` file with your private key and RPC URL:

   ```sh
   SEPOLIA_RPC_URL=<your-rpc-url>
   PRIVATE_KEY=<your-private-key>
   ```

2. Deploy with Foundry:
   ```sh
   forge script script/DeployDEX.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast
   ```

### **Verify Contracts**

```sh
forge verify-contract --chain-id 11155111 --num-of-optimizations 200 --watch
```

---

## Future Enhancements

- **Slippage Protection**: Prevent swaps from executing beyond a threshold price.
- **Real Oracle Integration**: Use Chainlink for real-time USD-based prices.
- **Liquidity Mining**: Introduce rewards for liquidity providers.
- **Market Making**: Improve asset pricing incorporating both of oracle and internal pool.
