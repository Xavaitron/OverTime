pragma solidity ^0.8.0;

contract Overtime {

    struct Worker {
        uint256 hoursAvailable;
        uint256 expertise;
        uint256 minWage;
        address wallet;
        bool registered;
    }

    struct Task {
        uint256 requiredTime;
        uint256 expertiseRequired;
        uint256 hourlyWage;
        uint256 deadline;
        bool divisible;
        bool allocated;
        address workerAssigned;
    }

    address public admin;
    address[] public workerAddresses;
    mapping(address => Worker) public workers;
    Task[] public tasks;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }

    modifier onlyRegistered() {
        require(workers[msg.sender].registered, "Worker not registered.");
        _;
    }

    function registerWorker(uint256 _hours, uint256 _expertise, uint256 _minWage) external {
        require(!workers[msg.sender].registered, "Worker already registered.");

        workers[msg.sender] = Worker({
            hoursAvailable: _hours,
            expertise: _expertise,
            minWage: _minWage,
            wallet: msg.sender,
            registered: true
        });

        workerAddresses.push(msg.sender); // Add worker's address to the array
    }

    function addTask(uint256 _requiredTime, uint256 _expertiseRequired, uint256 _hourlyWage, uint256 _deadline, bool _divisible) external onlyAdmin {
        tasks.push(Task({
            requiredTime: _requiredTime,
            expertiseRequired: _expertiseRequired,
            hourlyWage: _hourlyWage,
            deadline: _deadline,
            divisible: _divisible,
            allocated: false,
            workerAssigned: address(0)
        }));
    }

    function allocateTasks() external onlyAdmin {
        for(uint256 i = 0; i < tasks.length; i++) {
            if(!tasks[i].allocated) {
                for(uint256 j = 0; j < workerAddresses.length; j++) {
                    address workerAddress = workerAddresses[j];
                    Worker memory worker = workers[workerAddress];
                    if(worker.registered && worker.expertise >= tasks[i].expertiseRequired && worker.minWage <= tasks[i].hourlyWage && worker.hoursAvailable >= tasks[i].requiredTime) {
                        tasks[i].workerAssigned = worker.wallet;
                        tasks[i].allocated = true;
                        workers[worker.wallet].hoursAvailable -= tasks[i].requiredTime;
                        break;
                    }
                }
            }
        }
    }

    function completeTask(uint256 taskId) external onlyRegistered {
        Task storage task = tasks[taskId];
        require(task.workerAssigned == msg.sender, "Task not assigned to this worker.");
        require(block.timestamp >= task.deadline, "Task deadline not yet reached.");
        
        payable(msg.sender).transfer(task.requiredTime * task.hourlyWage);
        task.allocated = false;  // Mark task as completed
    }

    function getWorker(address workerAddress) external view returns (Worker memory) {
        return workers[workerAddress];
    }

    function getTask(uint256 taskId) external view returns (Task memory) {
        return tasks[taskId];
    }

    receive() external payable {}
}
