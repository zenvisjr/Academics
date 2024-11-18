import React from "react"
import "./chat.css"
import { useNavigate} from "react-router-dom"
import { useState, useEffect } from "react";
import axios from "axios";

// function ExtractQues()
// {
//     const qt = axios.get("http://localhost:9002/getQuestions")

//     .then(res => {
//         console.log(res)
//         setQuestions(res.data.questions);
//     })
//     .catch(err => console.log(err));
// }

//console.log("8");
const Chat = () => {
    const navigate = useNavigate();
    console.log("11");
    const [questions, setQuestions] = useState([]);
    // const [selectedQuestion, setSelectedQuestion] = useState("");
    // console.log(selectedQuestion)
    const [answer, setAnswer] = useState("");
    const [darkMode, setDarkMode] = useState(false); 
    const [chatHistory, setChatHistory] = useState([]);
    // console.log("15");

    useEffect(() => {
        // console.log("18");
        axios.get("http://localhost:9002/getQuestions")
            .then(res => {
                console.log(res);
                setQuestions(res.data.questions);
            })
            .catch(err => console.log(err));

            
        
    }, []);

    const fetchChatHistory = async () => {
        // fetch chat history from backend
        axios.get("http://localhost:9002/chat-history")
        .then(res => {
            console.log("finally getting response", res);
            setChatHistory(res.data);
            console.log("seeing chat", chatHistory)

            // Show chat history in new window
        showHistoryInNewWindow(res.data);   

        })
        .catch(err => console.log(err));
      };

      const showHistoryInNewWindow = (chatHistory) => {
        let newWindow = window.open("", "Chat History", "width=400,height=600");
        
        // Clear existing content
        newWindow.document.body.innerHTML = "";
      
        let html = "<html><head><title>Chat History</title></head><body>";
      
        html += '<h1>Chat History</h1><div class="chat-history-popup">';
        
        chatHistory.forEach((entry, index) => {
          html += `<div><p><strong>${index + 1}. Question:</strong> ${entry.question}<strong> Answer:</strong> ${entry.answer}</p></div>`;
        });
        
        html += "</div></body></html>";
        
        newWindow.document.write(html);
      }
      
      
    
    // console.log("25");

    // Fetch answer when a question is selected
    const getAnswer = (question) => {
        console.log("29");
        // setSelectedQuestion(question);
        if (question === "Select a question") {
            setAnswer("");
            return;
        }
        axios.post("http://localhost:9002/getAnswer", 
        { 
            question: question 
        })
            .then(res => {
                setAnswer(res.data.answer);

                /*******************************************saving history **************************/
                // const email = "ayushrai.cse@gmail.com"
                axios.post("http://localhost:9002/saveHistory", {
                // email: emailID,
                question: question,
                answer: res.data.answer
            })
            .then((res) => {
                console.log(res.data.message); // "History saved successfully"
            })
        })
            .catch(err => console.log(err));
    }


    // const fetchChatHistory = async () => {
    //     // fetch chat history from backend
    //     const response = await axios.get("/chat-history");
    //     console.log("Fetched Chat History:", response.data);
    //     setChatHistory(response.data);
    //   };
      
      const deleteChatHistory = async () => {
        // delete chat history in backend
        await axios.delete("http://localhost:9002/chat-history");
        setChatHistory([]); // clear history in frontend
      };


    // console.log("33");
    const toggle = () => {
        setDarkMode(!darkMode);
    }


    return (
        <div className={`chatarea ${darkMode ? "dark-mode" : ""}`}>
            <h1>Chat Area</h1>
            {/* console.log("47"); */}
            <div className={`toggle ${darkMode ? "dark-mode" : ""}`} onClick={toggle}>Dark Mode</div>
            <div className={`button ${darkMode ? "dark-mode" : ""}`} onClick={fetchChatHistory}>Show History</div>
            <div className={`button ${darkMode ? "dark-mode" : ""}`} onClick={deleteChatHistory}>Delete History</div>
            

                <select className={darkMode ? "dark-mode" : ""} onChange={(e) => getAnswer(e.target.value)}> 
                <option>Select a question</option>
                    {questions.map((q) => (
                        <option > {q} </option> ))}
                </select>
                <p>{answer}</p>
                {/* <ExtractQues/> */}
                {/* console.log("54"); */}

            <div className={`button ${darkMode ? "dark-mode" : ""}`} onClick={() => navigate("/login")}>Logout</div>
        </div>
    );
}

export default Chat