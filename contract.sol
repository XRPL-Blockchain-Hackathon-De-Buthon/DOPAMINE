// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// 외부 라이브러리 import 없이 직접 정의한 ERC20 인터페이스
interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract XrpReserveDistributor {
    address public owner;
    IERC20 public xrpToken;  // W-XRP Token 주소를 constructor에서 주입

    constructor(address _xrpToken) {
        owner = msg.sender;
        xrpToken = IERC20(_xrpToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    // ✅ 컨트랙트가 보유한 W-XRP 토큰 잔액 조회
    function getReserveBalance() public view returns (uint256) {
        return xrpToken.balanceOf(address(this));
    }

    // ✅ 보유 W-XRP를 recipients에게 균등하게 분배
    function distributeEvenly(address[] calldata recipients) external onlyOwner {
        uint256 balance = xrpToken.balanceOf(address(this));
        require(recipients.length > 0, "No recipients");
        uint256 share = balance / recipients.length;
        require(share > 0, "Not enough balance to distribute");

        for (uint i = 0; i < recipients.length; i++) {
            require(xrpToken.transfer(recipients[i], share), "Transfer failed");
        }
    }
}
