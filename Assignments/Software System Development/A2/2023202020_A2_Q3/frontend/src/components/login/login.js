import React, {useState} from "react";
import "./login.css";
import axios from "axios";
import { useNavigate} from "react-router-dom"

const Login = ({setLoginUser}) => {

    const navigate = useNavigate();


    const [ user, setUser] = useState({
        email:"",
        password:""
    })

    // const [emailID, setEmailID] = useState()
    // console.log(userID)

  //   useEffect(() => {
  //     console.log("email ID:", emailID);
  // });

    const handleChange = e => {
        const { name, value } = e.target
        setUser({
            ...user,
            [name]: value
        })
    }

    const login = () => {
      axios.post("http://localhost:9002/login", user)
      .then(res => {
        alert(res.data.message)
        // localStorage.setItem('user', JSON.stringify(res.data.user));

        // console.log("hiiiiiiiiiiiiiiii")
        setLoginUser(res.data.user)
        // console.log("elvish bhaiiiiiiiiiiii")
        // setEmailID(res.data.user.email)
        // console.log(res.data.user.email)
        // console.log("User ID:", userID);
        navigate("/")
      })
    }

    // const login = () => {
    //   axios.post("http://localhost:9002/login", user)
    //     .then(res => {
    //       if (res.data.message === "login successfully") {
    //         setLoginUser(res.data.user);
    //         setRole(res.data.role);  // setting the role after successful login
    //       } else {
    //         alert("Wrong username or password");
    //       }
    //     });
    // };

  return (
    <div className="container">
    <div className="loginpage">
    {console.log("user", user)}
      <h1>Login</h1>
      {/* <label htmlFor="email"><left>Email ID</left></label> */}
      <input type="email" id="email" name="email" value={user.email} onChange={handleChange} placeholder="Email" />
      {/* <label htmlFor="password">Password</label> */}
      <input type="password" id="password" name="password" value={user.password} onChange={handleChange} placeholder="Password" />
      <div className="button" onClick={login}>Login</div>
      <div className="button" onClick={() => navigate("/register")} >New user? Signup</div>
    </div>

    </div>
    
  );
};

export default Login;
