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

    OneInch private immutable oneInch = OneInch(0x11111112542D85B3EF69AE05771c2dCCff4fAa26);

    IERC20 private immutable DAI = IERC20(0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063);
    IERC20 private immutable USDC = IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
    IERC20 private immutable USDT = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
    IERC20 private immutable UST = IERC20(0x692597b009d13C4049a947CAB2239b7d6517875F);

    function swap(address caller, SwapDescription memory desc, bytes memory data) external onlyWorker {

        require(desc.dstReceiver == owner(), "Receiver is not the owner.");

        require(desc.dstToken == DAI  ||
                desc.dstToken == USDC ||
                desc.dstToken == USDT ||
                desc.dstToken == UST, "Token not supported." );

        uint256 dstBalance = desc.dstToken.balanceOf(owner());

        desc.srcToken.transferFrom(owner(), address(this), desc.amount);
        desc.srcToken.approve(address(oneInch), desc.amount);
        
        oneInch.swap(caller, desc, data);

        require(dstBalance != desc.dstToken.balanceOf(owner()), "Balance of dst token didn't change.");
    }
}

contract OneInch {
    
    function swap(
        address caller,
        SwapDescription calldata desc,
        bytes calldata data
    )
        external
        payable
        returns (uint256 returnAmount, uint256 gasLeft) {}
}
