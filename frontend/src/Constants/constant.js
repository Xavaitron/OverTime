const contractAddress = "0xe22C453e9F4B7Ab875550200390B6381432bab2F";
const contractAbi = [
  {
    inputs: [],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_requiredTime",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_expertiseRequired",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_hourlyWage",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_deadline",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "_divisible",
        type: "bool",
      },
    ],
    name: "addTask",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "admin",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "allocateTasks",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "taskId",
        type: "uint256",
      },
    ],
    name: "completeTask",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "taskId",
        type: "uint256",
      },
    ],
    name: "getTask",
    outputs: [
      {
        components: [
          {
            internalType: "uint256",
            name: "requiredTime",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "expertiseRequired",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "hourlyWage",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "deadline",
            type: "uint256",
          },
          {
            internalType: "bool",
            name: "divisible",
            type: "bool",
          },
          {
            internalType: "bool",
            name: "allocated",
            type: "bool",
          },
          {
            internalType: "address",
            name: "workerAssigned",
            type: "address",
          },
        ],
        internalType: "struct Overtime.Task",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "workerAddress",
        type: "address",
      },
    ],
    name: "getWorker",
    outputs: [
      {
        components: [
          {
            internalType: "uint256",
            name: "hoursAvailable",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "expertise",
            type: "uint256",
          },
          {
            internalType: "uint256",
            name: "minWage",
            type: "uint256",
          },
          {
            internalType: "address",
            name: "wallet",
            type: "address",
          },
          {
            internalType: "bool",
            name: "registered",
            type: "bool",
          },
        ],
        internalType: "struct Overtime.Worker",
        name: "",
        type: "tuple",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "_hours",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_expertise",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "_minWage",
        type: "uint256",
      },
    ],
    name: "registerWorker",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    name: "tasks",
    outputs: [
      {
        internalType: "uint256",
        name: "requiredTime",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "expertiseRequired",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "hourlyWage",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "deadline",
        type: "uint256",
      },
      {
        internalType: "bool",
        name: "divisible",
        type: "bool",
      },
      {
        internalType: "bool",
        name: "allocated",
        type: "bool",
      },
      {
        internalType: "address",
        name: "workerAssigned",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    name: "workerAddresses",
    outputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "address",
        name: "",
        type: "address",
      },
    ],
    name: "workers",
    outputs: [
      {
        internalType: "uint256",
        name: "hoursAvailable",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "expertise",
        type: "uint256",
      },
      {
        internalType: "uint256",
        name: "minWage",
        type: "uint256",
      },
      {
        internalType: "address",
        name: "wallet",
        type: "address",
      },
      {
        internalType: "bool",
        name: "registered",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    stateMutability: "payable",
    type: "receive",
  },
];

export { contractAbi, contractAddress };
