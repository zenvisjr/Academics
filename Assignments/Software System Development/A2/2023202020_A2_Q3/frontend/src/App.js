
import './App.css';

//files I created
import Login from "./components/login/login"
import Register from "./components/register/register"
import Chat from "./components/chat/chat"
import Admin from "./components/admin/admin"

import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import { useEffect } from 'react';
import { useState } from 'react';

// function App() {
//   const [user, setLoginUser] = useState({});

//   return (
//     <div className="App">
//       <Router>
//         <Routes>
//           <Route path="/" element={user ? <Chat setLoginUser={setLoginUser} /> : <Navigate to="/login" />} />
//           <Route path="/login" element={<Login setLoginUser={setLoginUser}/>} />
//           <Route path="/register" element={<Register />} />
//           <Route path="/admin" element={<Admin />} />
//         </Routes>
//       </Router>
//     </div>
//   );
// }

function App() {
  const [user, setLoginUser] = useState({});


  useEffect(() => {
    console.log("User1111:", user);
    

  }, [user]);

  return (
    <div className="App">
      {/* <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script> */}
      <Router>
        <Routes>
          <Route path="/login" element={<Login setLoginUser={setLoginUser} />} />
          <Route path="/register" element={<Register />} />
          <Route path="/"
            element={
              user && user.role === 'user' ? <Chat setLoginUser={setLoginUser} /> : 
              user && user.role === 'admin' ? <Navigate to="/admin" /> :
              <Navigate to="/login" />
            }
          />
          <Route path="/admin"
            element={
              user && user.role === 'admin' ? <Admin /> : <Navigate to="/login" />
            }
          />
        </Routes>
      </Router>
    </div>
  );
}

export default App;
