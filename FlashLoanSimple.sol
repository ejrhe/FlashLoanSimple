//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IPoolAddressesProvider {
    function getPool() external view returns (address);
}

interface IPool {
    function flashLoanSimple(
        address receiverAddress,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}

 contract FlashLoanContract {
    IPoolAddressesProvider private immutable ADDRESSES_PROVIDER;
    IPool private immutable POOL;
    address private owner;


    constructor(address _addressProvider) {
        ADDRESSES_PROVIDER = IPoolAddressesProvider(_addressProvider);
        POOL = IPool(ADDRESSES_PROVIDER.getPool());
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
       require(msg.sender == owner, "Only owner can call");
        _;
    }

    function FlashLoanSimple(address asset, uint256 amount) external {
        POOL.flashLoanSimple(
            address(this),
            asset,
            amount,
            "",
            0
        );
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata //params
    ) external returns (bool) {
        require(msg.sender == address(POOL), "Caller must be Pool");
        require(initiator == address(this), "Initiator invalid");
        
       // Your Profit Logic

        uint256 amountOwing = amount + premium;
        IERC20(asset).approve(address(POOL), amountOwing);

        return true;
    }

    function withdraw(address _token) external onlyOwner {
        uint256 balance = IERC20(_token).balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        IERC20(_token).transfer(owner, balance);
    }

    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        payable(owner).transfer(balance);
    }

    receive() external payable {}
}
