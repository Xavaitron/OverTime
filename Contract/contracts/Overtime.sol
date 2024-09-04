// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
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
        uint [] dependencies;
        uint256 hourlyWage;
        uint256 deadline;
        bool divisible;
        uint workersLeft;
    }

    address public admin;
    uint[] PricePoints;
    mapping(uint=>mapping(uint=>address[]))priceWorkerMap;
    mapping(address => Worker) public workers;
    mapping (uint=>mapping (address=>uint)) assignedWorker;
    address[][] assignedList;
    Task[] public tasks;
    uint totalPayment;
    uint totalHours;
    
    constructor() {
        admin = msg.sender;     
        totalPayment = 0;   
        totalHours =0;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action.");
        _;
    }
    function registerWorker(uint256 _hours, uint256 _expertise, uint256 _minWage,address _wallet) external {
        require(!workers[_wallet].registered, "Worker already registered.");
        workers[_wallet] = Worker({
            hoursAvailable: _hours,
            expertise: _expertise,
            minWage: _minWage,
            wallet: _wallet,
            registered: true
        });
        uint x = PricePoints.length;
        for(uint i = 0; i<PricePoints.length;i++){
            if(PricePoints[i] >= _minWage) {x = i;break;}
        }
        if(x==PricePoints.length || PricePoints[x]!=_minWage){
            PricePoints.push(_minWage);
            for(uint i = PricePoints.length-1;i>x;i--){
                PricePoints[i] += PricePoints[i-1];
                PricePoints[i-1] = PricePoints[i]-PricePoints[i-1];
                PricePoints[i]-=PricePoints[i-1];
            }
        }
        priceWorkerMap[_minWage][_expertise].push(_wallet);
    }
    uint maxExpertiseLevel=3;
    function lower_bound(uint target) internal view returns (uint){
        uint l = 0;
        uint r=PricePoints.length-1;
        while(r-l>0){
            uint m = (l+r)/2;
            if(PricePoints[m]==target)return m;
            else if(PricePoints[m]<target)l = m+1 ;
            else r=m;
        }
        return l;
    }
    address[] assigned;
    function addTask(uint256 timeRequired, uint256 expertiseRequired,uint[] calldata dependencies, uint256 hourlyWage, uint256 deadline, bool divisible) public onlyAdmin {
        require(1<=expertiseRequired && expertiseRequired<4 && deadline>block.timestamp,"invalid input");
        tasks.push(Task(timeRequired, expertiseRequired,dependencies, hourlyWage, deadline, divisible,0));
        
        address[] memory t;
        assignedList.push(t);
        allocate(tasks.length-1);
    }
    bool [] public doneTask;
    function checkStatusTask() public{
        for(uint i =0;i<tasks.length;i++){
             if(tasks[i].requiredTime>0)allocate(i);
            if(i<doneTask.length)doneTask[i] = tasks[i].requiredTime==0 && tasks[i].workersLeft==0;
            else doneTask.push(tasks[i].requiredTime==0 && tasks[i].workersLeft==0);
        }
    }
    function getStatusTask()public view returns (bool[]memory){
        return doneTask;
    }
    function getTaskList()public view returns (Task[]memory){return tasks;}
    function allocate(uint taskId) internal{
        if(PricePoints.length==0)return;
        if(tasks[taskId].hourlyWage<PricePoints[0])return;
        uint x = lower_bound(tasks[taskId].hourlyWage);
        delete assigned;
        if(tasks[taskId].divisible){
            while(x>=0){
                for(uint exp = tasks[taskId].expertiseRequired;exp<=maxExpertiseLevel;exp++){
                    for(uint i = 0;i<priceWorkerMap[PricePoints[x]][exp].length;i++){
                        address a= priceWorkerMap[PricePoints[x]][exp][i];
                        bool f= false;
                        for(uint it = 0; it<tasks[taskId].dependencies.length;it++){
                            if(assignedWorker[tasks[taskId].dependencies[it]][a]!=NULL_VAL){f=true;break;}
                        }
                        if(f || workers[a].hoursAvailable==0)continue;
                        if(workers[a].hoursAvailable<tasks[taskId].requiredTime){
                            tasks[taskId].requiredTime-=workers[a].hoursAvailable;
                            assignedWorker[taskId][a]=workers[a].hoursAvailable;
                            assignedList[taskId].push(a);
                            workers[a].hoursAvailable=0;
                            tasks[taskId].workersLeft++;
                        }else{
                            workers[a].hoursAvailable-=tasks[taskId].requiredTime;
                            assignedWorker[taskId][a] = tasks[taskId].requiredTime;
                            tasks[taskId].requiredTime=0;
                            assignedList[taskId].push(a);
                            tasks[taskId].workersLeft++;
                            return;
                        }
                    }
                }
                if(x==0)return;
                x-=1;
            }
        }else{
            while(x>=0){
                for(uint exp = tasks[taskId].expertiseRequired;exp<=maxExpertiseLevel;exp++){
                    for(uint i = 0;i<priceWorkerMap[PricePoints[x]][exp].length;i++){
                        address a= priceWorkerMap[PricePoints[x]][exp][i];
                        bool f= false;
                        for(uint it = 0; it<tasks[taskId].dependencies.length;it++){
                            if(assignedWorker[tasks[taskId].dependencies[it]][a]!=NULL_VAL){f=true;break;}
                        }
                        if(f)continue;
                        if(workers[a].hoursAvailable>=tasks[taskId].requiredTime){
                            assignedWorker[taskId][a] = tasks[taskId].requiredTime;
                            workers[a].hoursAvailable-=tasks[taskId].requiredTime;
                            tasks[taskId].requiredTime=0;
                            assignedList[taskId].push(a);
                            tasks[taskId].workersLeft++;
                            return;
                        }
                    }
                }
                if(x==0)return;
                x -=1;
            }
        }
    }
    uint dones =0;
    function getDoneTask() public view returns (uint){return dones;}
    function getAllocation() public view returns(address[][]memory){return assignedList;}
    function getTotalPayments() public view returns (uint){return totalPayment;}
    function getTotalHours() public view returns (uint){return totalHours;}
    function getTotalTasks() public view returns(uint){return tasks.length;}
    uint NULL_VAL=10000000000000000000000000;
    function completeTask(uint256 taskId,address _worker) external payable onlyAdmin {
        require(assignedWorker[taskId][_worker]!=0 ,"This task is not allocated yet.");
        require(assignedWorker[taskId][_worker]<NULL_VAL ,"This task is already completed by worker.");
        require(msg.value>=assignedWorker[taskId][_worker]*tasks[taskId].hourlyWage*1000000000,"insufficient funds");
        require(block.timestamp <= tasks[taskId].deadline,"task has expired");
        payable(_worker).transfer(assignedWorker[taskId][_worker] * tasks[taskId].hourlyWage*1000000000);
        totalPayment+=assignedWorker[taskId][_worker] * tasks[taskId].hourlyWage;
        totalHours +=assignedWorker[taskId][_worker];
        tasks[taskId].workersLeft-=1;
        if(tasks[taskId].requiredTime==0 && tasks[taskId].workersLeft==0){dones+=1;}
        payable (msg.sender).transfer(msg.value-assignedWorker[taskId][_worker] * tasks[taskId].hourlyWage*1000000000);
         assignedWorker[taskId][_worker]=NULL_VAL;
    }
    function g(uint a,address b)public view returns(uint){return assignedWorker[a][b];}
    function checkWallet(address _worker) public view returns(bool){
        return _worker.balance>0;
    }//error is same as invalid wallet
}
