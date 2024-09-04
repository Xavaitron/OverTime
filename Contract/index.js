const ethers = require("ethers");
require("dotenv").config();
const express = require("express");
const cors = require("cors")
const app = express();
app.use(express.json());
app.use(cors())

const API = process.env.INFURA_API;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const contractAddress = process.env.CONTRACT_ADDRESS;

const provider = new ethers.InfuraProvider("sepolia", API);
const signer = new ethers.Wallet(PRIVATE_KEY, provider);

const abi = require("./ABI.json");
const contractInstance = new ethers.Contract(contractAddress, abi, signer);

app.post("/addTask", async (req, res) => {
  const { time, expertise, dependencies, wage, deadline, divisible } = req.body;

  try {
    const tx = await contractInstance.addTask(
      time,
      expertise,
      dependencies,
      wage,
      deadline,
      divisible
    );
    await tx.wait();
    res
      .status(200)
      .json({ message: "Task added successfully", transactionHash: tx.hash });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to add task" });
  }
});

app.post("/addWorker", async (req, res) => {
  const { hours, expertise, min_wage, wallet } = req.body;

  try {
    const tx = await contractInstance.registerWorker(
      hours,
      expertise,
      min_wage,
      wallet
    );
    await tx.wait();
    res
      .status(200)
      .json({ message: "Worker added successfully", transactionHash: tx.hash });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to add worker" });
  }
});

app.get("/checkStatus", async (req, res) => {
  try {

    await contractInstance.checkStatusTask();
    const tasksStatus = await contractInstance.getStatusTask();
    const tasksAllocation = await contractInstance.getAllocation();

    // console.log('tasksStatus:', tasksStatus);
    // console.log('tasksAllocation:', tasksAllocation);

    // // Ensure tasksStatus is an array
    // if (!Array.isArray(tasksStatus)) {
    //   throw new Error("tasksStatus is not an array");
    // }

    // // Ensure tasksAllocation is an array of arrays
    // if (!Array.isArray(tasksAllocation) || !tasksAllocation.every(Array.isArray)) {
    //   throw new Error("tasksAllocation is not a valid array of arrays");
    // }

    const formattedTasks = tasksStatus.map((status, taskId) => ({
      task_id: taskId.toString(),
      worker_id: tasksAllocation[taskId] && tasksAllocation[taskId].length > 0
        ? tasksAllocation[taskId].map(id => id.toString())
        : null,
      status: status,
    }));

    res.status(200).json({ tasks: formattedTasks });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to fetch task status" });
  }
});


app.post("/checkWallet", async (req, res) => {
  const { worker_id } = req.body;

  try {
    const status = await contractInstance.checkWallet(worker_id);
    res.status(200).json({ status : status.toString() });
  } catch (error) {
    console.error(error);
    res.status(200).json({ error: "Failed to check wallet balance" });
  }
});

app.get("/getTotalTasks", async (req, res) => {
  try {
    const totalTasks = await contractInstance.getTotalTasks();
    
    res.status(200).json({ totalTasks: totalTasks.toString() });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to fetch total tasks" });
  }
});

app.get("/getAdmin", async (req, res) => {
  try {
    const Admin = await contractInstance.admin;
    
    res.status(200).json({ admin: Admin });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to fetch admin" });
  }
});

app.get("/getTotalPayment", async (req, res) => {
  try {
    const Payment = await contractInstance.getTotalPayments();
    
    res.status(200).json({ payment: Payment.toString() });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to fetch total payment" });
  }
});

app.get("/getTotalHours", async (req, res) => {
  try {
    const Hours = await contractInstance.getTotalHours();
    
    res.status(200).json({ hours: Hours.toString() });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Failed to fetch total hours" });
  }
});

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
