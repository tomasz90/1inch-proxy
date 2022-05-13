// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

struct SwapDescription {
        IERC20 srcToken;
        IERC20 dstToken;
        address srcReceiver;
        address dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }

contract OwnableByWorker is Ownable {
    address private _worker;

    event WorkOwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        setWorker(tx.origin);
        transferOwnership(tx.origin);
    }

    modifier onlyWorker() {
        // worker is deployer
        require(
            worker() == tx.origin,
            "OwnableByWorker: caller is not the owner"
        );
        _;
    }

    function worker() public view returns (address) {
        return _worker;
    }

    function setWorker(address newWorker) public onlyOwner {
        address oldWorker = _worker;
        _worker = newWorker;
        emit WorkOwnershipTransferred(oldWorker, newWorker);
    }
}

contract OneInchProxy is OwnableByWorker {

    OneInch public oneInch;

    IERC20 public dai;
    IERC20 public usdc;
    IERC20 public usdt;
    IERC20 public ust;

    constructor(address _router, address _dai, address _usdc, address _usdt, address _ust) {
        oneInch = OneInch(_router);
        dai = IERC20(_dai);
        usdc = IERC20(_usdc);
        usdt = IERC20(_usdt);
        ust = IERC20(_ust);
    }

    function swap(address caller, SwapDescription memory desc, bytes memory data) external onlyWorker {

        require(desc.dstReceiver == owner(), "Receiver is not the owner.");

        require(desc.dstToken == dai  ||
                desc.dstToken == usdc ||
                desc.dstToken == usdt ||
                desc.dstToken == ust, "Token not supported." );

        uint256 dstBalance = desc.dstToken.balanceOf(owner());

        desc.srcToken.transferFrom(owner(), address(this), desc.amount);
        desc.srcToken.approve(address(oneInch), desc.amount);
        
        oneInch.swap(caller, desc, data);

        require(dstBalance != desc.dstToken.balanceOf(owner()), "Balance of dst token didn't change.");
    }
}

interface OneInch {
    
    function swap(
        address caller,
        SwapDescription calldata desc,
        bytes calldata data
    )
        external
        payable
        returns (uint256 returnAmount, uint256 gasLeft);
}
