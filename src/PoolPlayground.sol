// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

// OpenZeppelin Imports
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";

// UniswapV2 Imports
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

// Contract Imports
import {Token} from "./Token.sol";

// ================================================================
// │                    POOL PLAYGROUND CONTRACT                  │
// ================================================================

/// @title Pool Playground
/// @author EridianAlpha
/// @notice An interactive educational playground for visualizing and learning
///         Uniswap V2 mechanics by swapping testnet ERC20 tokens.
contract PoolPlayground {
    // ================================================================
    // │                            STRUCTS                           │
    // ================================================================

    struct ContractAddress {
        string identifier;
        address contractAddress;
    }

    struct TokenAddresses {
        address diamond;
        address wood;
        address stone;
    }

    struct TokenAmounts {
        uint256 diamond;
        uint256 wood;
        uint256 stone;
    }

    // ================================================================
    // │                            EVENTS                            │
    // ================================================================

    // Event to log the creation of tokens and pools
    event TokensAndPoolsCreated(address indexed user);

    // ================================================================
    // │                        STATE VARIABLES                       │
    // ================================================================

    // Constant and immutable variables
    uint256 public constant TOKEN_DECIMALS = 10 ** 18;
    TokenAmounts public MARKET_PRICE_USD = TokenAmounts({diamond: 100, wood: 20, stone: 2});

    // Mappings
    mapping(address => TokenAddresses) internal s_userTokens;
    mapping(address => TokenAmounts) internal s_userInitialTokenBalances;
    mapping(string => address) internal s_contractAddresses;

    // ================================================================
    // │                     FUNCTIONS - CONSTRUCTOR                  │
    // ================================================================

    /// @notice Constructor to set the Uniswap contract addresses for the network.
    /// @param _contractAddresses An array of ContractAddress structs.
    constructor(ContractAddress[] memory _contractAddresses) {
        // Convert the contractAddresses array to a mapping
        for (uint256 i = 0; i < _contractAddresses.length; i++) {
            s_contractAddresses[_contractAddresses[i].identifier] = _contractAddresses[i].contractAddress;
        }
    }

    /// @notice Deploy a new playground instance.
    /// @dev Overwrites any existing tokens and pools for the user.
    /// @param _userTokenAmounts The amount of tokens to mint for the user.
    /// @param _poolTokenAmounts The amount of tokens to add to the Uniswap pools.
    function deploy(TokenAmounts calldata _userTokenAmounts, TokenAmounts[] calldata _poolTokenAmounts) public {
        // Store initial token balances for the user so profit can be calculated
        s_userInitialTokenBalances[msg.sender] = _userTokenAmounts;

        // Calculate the total amount of tokens to mint
        TokenAmounts memory tokenMintAmounts = TokenAmounts({
            diamond: (_userTokenAmounts.diamond + _poolTokenAmounts[0].diamond + _poolTokenAmounts[1].diamond),
            wood: (_userTokenAmounts.wood + _poolTokenAmounts[0].wood + _poolTokenAmounts[2].wood),
            stone: (_userTokenAmounts.stone + _poolTokenAmounts[1].stone + _poolTokenAmounts[2].stone)
        });

        // Create new tokens
        TokenAddresses memory tokenAddresses = createTokens(tokenMintAmounts);

        // Create new UniswapV2 pools
        createUniswapV2Pools(tokenAddresses, _poolTokenAmounts);

        // Send remaining tokens to the user
        sendRemainingTokens(tokenAddresses);

        emit TokensAndPoolsCreated(msg.sender);
    }

    /// @notice Create tokens.
    /// @param _mintTokenAmounts The total amount of tokens to mint.
    function createTokens(TokenAmounts memory _mintTokenAmounts)
        internal
        returns (TokenAddresses memory tokenAddresses)
    {
        // Set pre-approved addresses for unlimited token spending
        address[] memory preApprovedAddresses = new address[](1);
        preApprovedAddresses[0] = s_contractAddresses["uniswapV2Router"];

        // Create new tokens with initial supply minted to this contract
        Token diamond = new Token(_mintTokenAmounts.diamond, "Diamond", "DIAMOND", preApprovedAddresses);
        Token wood = new Token(_mintTokenAmounts.wood, "Wood", "WOOD", preApprovedAddresses);
        Token stone = new Token(_mintTokenAmounts.stone, "Stone", "STONE", preApprovedAddresses);

        // Store the token addresses for the user
        tokenAddresses = TokenAddresses(address(diamond), address(wood), address(stone));
        s_userTokens[msg.sender] = tokenAddresses;
    }

    /// @notice Create UniswapV2 pools.
    /// @param _tokenAddresses The token addresses for the user.
    /// @param _poolTokenAmounts The amount of tokens to add to the Uniswap pools.
    function createUniswapV2Pools(TokenAddresses memory _tokenAddresses, TokenAmounts[] memory _poolTokenAmounts)
        internal
    {
        IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(s_contractAddresses["uniswapV2Router"]);

        // Approve Uniswap Router to spend the tokens
        Token(_tokenAddresses.diamond).approve(address(uniswapV2Router), type(uint256).max);
        Token(_tokenAddresses.wood).approve(address(uniswapV2Router), type(uint256).max);
        Token(_tokenAddresses.stone).approve(address(uniswapV2Router), type(uint256).max);

        // Create pairs and add liquidity
        // Pair 1: Diamond/Wood
        createPairAndAddLiquidity(
            uniswapV2Router,
            _tokenAddresses.diamond,
            _tokenAddresses.wood,
            _poolTokenAmounts[0].diamond,
            _poolTokenAmounts[0].wood
        );

        // Pair 2: Diamond/Stone
        createPairAndAddLiquidity(
            uniswapV2Router,
            _tokenAddresses.diamond,
            _tokenAddresses.stone,
            _poolTokenAmounts[1].diamond,
            _poolTokenAmounts[1].stone
        );

        // Pair 3: Wood/Stone
        createPairAndAddLiquidity(
            uniswapV2Router,
            _tokenAddresses.wood,
            _tokenAddresses.stone,
            _poolTokenAmounts[2].wood,
            _poolTokenAmounts[2].stone
        );
    }

    /// @notice Create UniSwapV2 pair and add liquidity.
    /// @param tokenA The address of the first token.
    /// @param tokenB The address of the second token.
    /// @param amountA The amount of tokenA to add to the pool.
    /// @param amountB The amount of tokenB to add to the pool.
    function createPairAndAddLiquidity(
        IUniswapV2Router02 uniswapV2Router,
        address tokenA,
        address tokenB,
        uint256 amountA,
        uint256 amountB
    ) internal {
        IUniswapV2Factory uniswapV2Factory = IUniswapV2Factory(s_contractAddresses["uniswapV2Factory"]);

        // Create pair if it doesn't exist
        address pair = uniswapV2Factory.getPair(tokenA, tokenB);
        if (pair == address(0)) {
            uniswapV2Factory.createPair(tokenA, tokenB);
        }

        uniswapV2Router.addLiquidity(
            tokenA,
            tokenB,
            amountA, // Amount of tokenA desired
            amountB, // Amount of tokenB desired
            0, // Min amount of tokenA
            0, // Min amount of tokenB
            address(this),
            block.timestamp
        );
    }

    /// @notice Send remaining tokens to the user.
    /// @param _tokenAddresses The token addresses for the user.
    function sendRemainingTokens(TokenAddresses memory _tokenAddresses) internal {
        Token(_tokenAddresses.diamond).transfer(msg.sender, Token(_tokenAddresses.diamond).balanceOf(address(this)));
        Token(_tokenAddresses.wood).transfer(msg.sender, Token(_tokenAddresses.wood).balanceOf(address(this)));
        Token(_tokenAddresses.stone).transfer(msg.sender, Token(_tokenAddresses.stone).balanceOf(address(this)));
    }

    // ================================================================
    // │                       FUNCTIONS - GETTERS                    │
    // ================================================================

    /// @notice Get the contract address for a given identifier.
    /// @param _identifier The identifier of the contract.
    function getContractAddress(string memory _identifier) public view returns (address) {
        return s_contractAddresses[_identifier];
    }

    /// @notice Get the deployed tokens for a user.
    /// @param _user The address of the user.
    function getUserTokens(address _user) public view returns (TokenAddresses memory) {
        return s_userTokens[_user];
    }

    /// @notice Get the all the token balances for a user.
    /// @param _user The address of the user.
    /// @return userTokenBalances The token balances for the user.
    function getUserTokenBalances(address _user) public view returns (TokenAmounts memory userTokenBalances) {
        TokenAddresses memory userTokenAddresses = s_userTokens[_user];

        userTokenBalances.diamond = Token(userTokenAddresses.diamond).balanceOf(_user);
        userTokenBalances.wood = Token(userTokenAddresses.wood).balanceOf(_user);
        userTokenBalances.stone = Token(userTokenAddresses.stone).balanceOf(_user);
    }

    /// @notice Get the initial token balances for a user.
    /// @param _user The address of the user.
    /// @return userInitialTokenBalances The initial token balances for the user.
    function getUserInitialTokenBalances(address _user)
        public
        view
        returns (TokenAmounts memory userInitialTokenBalances)
    {
        return s_userInitialTokenBalances[_user];
    }
}
