import React, {useState} from "react"
import "./admin.css"
import { useNavigate} from "react-router-dom"
import axios from "axios";

const Admin = () => {

  const [darkMode, setDarkMode] = useState(false); 

    const navigate = useNavigate();
  
    const [form, setForm] = useState({
      question: "",
      answer: "" ,
    })

    const handleChange = (e) => {
        const { name, value } = e.target;
        setForm({
          ...form,
          [name]: value,
        });
      };
    
      const formSubmit = () => {
          // alert("entered successfully")
          const {question, answer} = form;
          if(question && answer) 
          {
          axios.post("http://localhost:9002/admin", form)
          .then(res => {
            alert(res.data.message);
            console.log(res);
            // window.location.reload();
          })
          .catch(err => {
            // Handle the error here
            console.log(err);
          });
        } 
        else 
        {
          alert("please fill all details");
        }
      };

      const toggle = () => {
        setDarkMode(!darkMode);
    }



    return (
        <div className="container">
            <div className={`adminarea ${darkMode ? "dark-mode" : ""}`}>

                <h1>Admin Area</h1>
                <div>
                <div className={`toggle ${darkMode ? "dark-mode" : ""}`} onClick={toggle}>Dark Mode</div>
                    <input type="text" placeholder="Enter Question" name="question" value={form.question} onChange={handleChange}/>
                </div>
                <div>
                    <input type="answer" placeholder="Enter Answer" name="answer" value={form.answer} onChange={handleChange}/>
                </div>
                <div className={`button ${darkMode ? "dark-mode" : ""}`} onClick={formSubmit}> Submit</div>
                <div>or</div>
                <div className={`button ${darkMode ? "dark-mode" : ""}`} onClick={() => navigate("/login")}>
                    Logout
                </div>
            </div>
        </div>
        
      )
    }
export default Admin