import React from "react";
// import { ethers } from "ethers";
// import { contractAbi, contractAddress } from "./Constants/constant";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Intro from "./components/intro.js";
import "./App.css";

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element = {<Intro />}/>
      </Routes>
    </BrowserRouter>
  );
}

export default App;
