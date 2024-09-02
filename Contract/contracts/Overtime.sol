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
        uint256 hourlyWage;
        uint256 deadline;
        bool divisible;
        bool allocated;
    }

    address admin;
    uint[] PricePoints;
    mapping(uint=>mapping(uint=>address[]))priceWorkerMap;
    mapping(address => Worker) public workers;
    mapping (uint=>mapping (address=>uint)) assignedWorker;
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
    function registerWorker(uint256 _hours, uint256 _expertise, uint256 _minWage) external {
        require(!workers[msg.sender].registered, "Worker already registered.");
        
        workers[msg.sender] = Worker({
            hoursAvailable: _hours,
            expertise: _expertise,
            minWage: _minWage,
            wallet: msg.sender,
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
        priceWorkerMap[_minWage][_expertise].push(msg.sender);
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
    function addTask(uint256 _requiredTime, uint256 _expertiseRequired, uint256 _hourlyWage, uint256 _deadline,bool _divisible) external onlyAdmin returns (bool){
        require(PricePoints.length>0);
        if(_hourlyWage<PricePoints[0])return false;
        uint x = lower_bound(_hourlyWage);
        delete assigned;
        if(_divisible){
            uint done = 0;
            while(x>=0){
                for(uint exp = _expertiseRequired;exp<=maxExpertiseLevel;exp++){
                    for(uint i = 0;i<priceWorkerMap[PricePoints[x]][exp].length;i++){
                        address a= priceWorkerMap[PricePoints[x]][exp][i];
                        assigned.push(a);
                        done+=workers[a].hoursAvailable;
                        if(done>=_requiredTime){
                            uint taskId = tasks.length;
                            tasks.push(Task({
                                requiredTime: _requiredTime,
                                expertiseRequired: _expertiseRequired,
                                hourlyWage: _hourlyWage,
                                deadline: _deadline,
                                divisible: _divisible,
                                allocated: true
                            }));
                            for(uint t = 0;t<assigned.length-1;t++){
                                done-=workers[assigned[t]].hoursAvailable;
                                assignedWorker[taskId][assigned[t]]=workers[assigned[t]].hoursAvailable;
                                workers[assigned[t]].hoursAvailable=0;
                            }
                            workers[assigned[assigned.length-1]].hoursAvailable-=done;
                            assignedWorker[taskId][assigned[assigned.length-1]] = done;
                            
                            return true;
                        }
                    }
                }
                x-=1;
            }
        }else{
            while(x>=0){
                for(uint exp = _expertiseRequired;exp<=maxExpertiseLevel;exp++){
                    for(uint i = 0;i<priceWorkerMap[PricePoints[x]][exp].length;i++){
                        address a= priceWorkerMap[PricePoints[x]][exp][i];
                        if(workers[a].hoursAvailable>=_requiredTime){
                            uint taskId= tasks.length;
                            assignedWorker[taskId][a] = _requiredTime;
                            tasks.push(Task({
                                requiredTime: _requiredTime,
                                expertiseRequired: _expertiseRequired,
                                hourlyWage: _hourlyWage,
                                deadline: _deadline,
                                divisible: _divisible,
                                allocated: true
                            }));
                            workers[a].hoursAvailable-=_requiredTime;
                            return true;
                        }
                    }
                }
                x -=1;
            }
        }
        return false;
    }
    function getTotalPayments() public view returns (uint){return totalPayment;}
    function getTotalHours() public view returns (uint){return totalHours;}
    function getTotalTasks() public view returns(uint){return tasks.length;}
    function completeTask(uint256 taskId,address _worker) external payable onlyAdmin {
        require(assignedWorker[taskId][_worker]!=0 ,"This task is not allocated yet.");
        require(msg.value>=assignedWorker[taskId][_worker]*tasks[taskId].hourlyWage/1000000000,"insufficient funds");
        require(block.timestamp <= tasks[taskId].deadline,"task has expired");
        payable(_worker).transfer(assignedWorker[taskId][_worker] * tasks[taskId].hourlyWage/1000000000);
        totalPayment+=assignedWorker[taskId][_worker] * tasks[taskId].hourlyWage;
        totalHours +=assignedWorker[taskId][_worker];
        payable (msg.sender).transfer(msg.value);
        delete assignedWorker[taskId][_worker];
    }
}
