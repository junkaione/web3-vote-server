// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Vote is Ownable {
    // 投票人
    struct Voter {
        uint256 amount; // 票数
        bool isVoted; // 是否已投票
        address delegator; // 代理人地址
        uint256 targetId; // 目标ID
    }

    // 投票看板
    struct Board {
        string name; // 目标
        uint256 totalAmount; // 票数
    }

    // 主持人信息
    address public host;

    // 投票人集合
    mapping(address => Voter) public voters;

    // 主题集合
    Board[] public board;

    // 数据初始化
    constructor(string[] memory nameList) Ownable(msg.sender) {
        host = msg.sender;
        voters[host].amount = 1;
        for (uint256 i = 0; i < nameList.length; i++) {
            Board memory boardItem = Board(nameList[i], 0);
            board.push(boardItem);
        }
    }

    // 返回看板集合
    function getBoardInfo() public view returns (Board[] memory) {
        return board;
    }

    // 给某些地址赋予选票
    function mandate(address[] calldata addressList) public onlyOwner {
        for (uint256 i = 0; i < addressList.length; i++) {
            if (!voters[addressList[i]].isVoted) {
                voters[addressList[i]].amount = 1;
            }
        }
    }

    // 将投票权委托给别人
    function dalegate(address to) public {
        Voter storage sender = voters[msg.sender];
        // 如果已经投过票，就不能再委托别人投票
        require(!sender.isVoted, "you aleardy voted.");
        // 不能委托自己
        require(msg.sender != to, "not to delegate youself.");
        // 避免循环委托
        while (voters[to].delegator != address(0)) {
            to = voters[to].delegator;
            require(to == msg.sender, unicode"不能循环委托");
        }
        // 开始授权
        sender.isVoted = true;
        sender.delegator = to;
        // 代理人数据修改
        Voter storage _delegator = voters[to];
        if (_delegator.isVoted) {
            // 追票
            board[_delegator.targetId].totalAmount += sender.amount;
        } else {
            _delegator.amount += sender.amount;
        }
    }

    // 投票
    function vote(uint targetId) public {
        Voter storage sender = voters[msg.sender];
        require(sender.amount != 0, "Has no right to vote.");
        require(!sender.isVoted, "Already voted.");
        sender.isVoted = true;
        sender.targetId = targetId;
        board[targetId].totalAmount += sender.amount;
        emit voteSuccess(unicode"投票成功");
    }

    // 投票成功事件
    event voteSuccess(string);
}
