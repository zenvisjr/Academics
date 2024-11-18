import React, { useState } from "react";
import "./register.css";
import axios from "axios";
import { useNavigate} from "react-router-dom"

const Register = () => {

  const navigate = useNavigate();

  const [user, setUser] = useState({
    name: "",
    role: "user",  
    email: "",
    password: "",
  });
  const [isEmailValid, setEmailValid] = useState(true);
  const [isPassStrong, setPassStrong] = useState(true);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setUser({
      ...user,
      [name]: value,
    });

  if (name === "email") {
    const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
    setEmailValid(emailPattern.test(value));
  }

  if (name === "password") {
    const strongPasswordPattern = /^(?=.{6,})/;
    setPassStrong(strongPasswordPattern.test(value));
  }
}

  const register = () => {
    const {name, email, password} = user;
    const emailPattern = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$/;
    // const PasswordPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*])(?=.{6,})/;
    const PasswordPattern = /^(?=.{6,})/; //password must be > length 6

    if (name && emailPattern.test(email) && PasswordPattern.test(password)) {
    // if (name && emailPattern.test(email) && password) {
    // if(name && email && password) {
      // alert("entered successfully")
      axios.post("http://localhost:9002/register", user)
      .then(res => {
        alert(res.data.message);
        console.log(res);
        navigate("/login")
        // window.location.reload();
        
      })
      .catch(err => {
        console.log(err);
      });
    } else {
      alert("please fill all details");
    }
  };
  

  return (
    <div className="container">
      <div className="registerpage">
        {console.log("user", user)}
        <h1>Register</h1>

        <input type="text" name="name" value={user.name} onChange={handleChange} placeholder="Name"
        />

        <select name="role" value={user.role}  onChange={handleChange}>
        <option value="user">User</option>
        <option value="admin">Admin</option>
        </select>

        <input type="email" name="email" value={user.email} onChange={handleChange} placeholder="Email"/>
        {!isEmailValid && <div className="error">Please enter a valid email</div>}


        <input type="password" name="password" value={user.password} onChange={handleChange} placeholder="Password"/>
        {!isPassStrong && <div className="error">Weak Password</div>}

        
        <div className="button" onClick={register}>Register</div>
        <div>or</div>
        <div className="button" onClick={() => navigate("/login")}>Login</div>
      </div>
    </div>
  );
};

export default Register;
