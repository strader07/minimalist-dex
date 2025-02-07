// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";

// import "forge-std/console.sol";

interface IPriceOracle {
    function getPrice(address token) external view returns (uint256);
}

interface IERC20Decimals {
    function decimals() external view returns (uint8);
}

contract MLP is ERC20, Ownable {
    constructor() ERC20("Minimalist LP Token", "MLP") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}

contract MinimalistDEX is Ownable {
    struct Liquidity {
        uint256 reserveA;
        uint256 reserveB;
        MLP lpToken;
        mapping(address => uint256) userReserveA;
        mapping(address => uint256) userReserveB;
    }

    mapping(bytes32 => Liquidity) public liquidityPool;
    IPriceOracle public priceOracle;

    event LiquidityAdded(
        address indexed provider,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 lpMinted
    );
    event LiquidityRemoved(
        address indexed provider,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB,
        uint256 lpBurned
    );
    event TokensSwapped(
        address indexed swapper,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    constructor(address _priceOracle) Ownable(msg.sender) {
        priceOracle = IPriceOracle(_priceOracle);
    }

    function getPoolKey(
        address tokenA,
        address tokenB
    ) public pure returns (bytes32) {
        return
            tokenA < tokenB
                ? keccak256(abi.encodePacked(tokenA, tokenB))
                : keccak256(abi.encodePacked(tokenB, tokenA));
    }

    function getLiquidityPool(
        address tokenA,
        address tokenB
    )
        external
        view
        returns (uint256 reserveA, uint256 reserveB, address lpToken)
    {
        bytes32 poolKey = getPoolKey(tokenA, tokenB);
        Liquidity storage pool = liquidityPool[poolKey];
        return (pool.reserveA, pool.reserveB, address(pool.lpToken));
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB
    ) external {
        require(tokenA != tokenB, "Tokens must be different");
        require(amountA > 0 && amountB > 0, "Invalid liquidity amount");

        IERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        bytes32 poolKey = getPoolKey(tokenA, tokenB);
        Liquidity storage pool = liquidityPool[poolKey];

        if (address(pool.lpToken) == address(0)) {
            pool.lpToken = new MLP();
        }

        uint256 lpMintAmount = amountA + amountB;
        pool.lpToken.mint(msg.sender, lpMintAmount);
        pool.reserveA += amountA;
        pool.reserveB += amountB;
        pool.userReserveA[msg.sender] += amountA;
        pool.userReserveB[msg.sender] += amountB;

        emit LiquidityAdded(
            msg.sender,
            tokenA,
            tokenB,
            amountA,
            amountB,
            lpMintAmount
        );
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 percent
    ) external {
        require(percent > 0 && percent <= 100, "Invalid percent");
        bytes32 poolKey = getPoolKey(tokenA, tokenB);
        Liquidity storage pool = liquidityPool[poolKey];
        require(
            address(pool.lpToken) != address(0),
            "Liquidity pool does not exist"
        );
        require(
            pool.userReserveA[msg.sender] > 0 &&
                pool.userReserveB[msg.sender] > 0,
            "No liquidity to remove"
        );

        uint256 amountA = (pool.userReserveA[msg.sender] * percent) / 100;
        uint256 amountB = (pool.userReserveB[msg.sender] * percent) / 100;
        uint256 lpBurnAmount = (pool.lpToken.balanceOf(msg.sender) * percent) /
            100;

        pool.lpToken.burn(msg.sender, lpBurnAmount);
        pool.reserveA -= amountA;
        pool.reserveB -= amountB;
        pool.userReserveA[msg.sender] -= amountA;
        pool.userReserveB[msg.sender] -= amountB;

        IERC20(tokenA).transfer(msg.sender, amountA);
        IERC20(tokenB).transfer(msg.sender, amountB);

        emit LiquidityRemoved(
            msg.sender,
            tokenA,
            tokenB,
            amountA,
            amountB,
            lpBurnAmount
        );
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external returns (uint256 amountOut) {
        require(tokenIn != tokenOut, "Invalid swap pair");
        require(amountIn > 0, "Invalid swap amount");

        uint256 priceIn = priceOracle.getPrice(tokenIn);
        uint256 priceOut = priceOracle.getPrice(tokenOut);
        require(priceIn > 0 && priceOut > 0, "Invalid pair price");

        uint8 decimalsIn = IERC20Decimals(tokenIn).decimals();
        uint8 decimalsOut = IERC20Decimals(tokenOut).decimals();

        amountOut =
            (amountIn * priceIn * (10 ** decimalsOut)) /
            (priceOut * 10 ** decimalsIn);
        require(
            IERC20(tokenOut).balanceOf(address(this)) >= amountOut,
            "Not enough liquidity"
        );

        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenOut).transfer(msg.sender, amountOut);

        emit TokensSwapped(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }
}
