import express from "express"
import cors from "cors"
import mongoose from "mongoose"
import bcrypt from "bcrypt"

//setting configuration
const app = express()
app.use(express.json())
app.use(express.urlencoded({extended: true}))
app.use(cors())

// mongoose.connect('mongodb://127.0.0.1:27017/liteChatGPT_DB', 
// {
//     useNewUrlParser: true, 
//     useUnifiedTopology: true })
//   .then(() => console.log('Connected to MongoDB'))
//   .catch(err => {
//     console.error('Could not connect to MongoDB:', err);
// }, 
// )
mongoose.connect('mongodb://localhost:27017/liteChatGPT_DB', 
{ 
    useNewUrlParser: true, 
    useUnifiedTopology: true })
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => {
    console.error('Could not connect to MongoDB:', err);
  });


//line 1 to 17 is constant for eery MERN project 

// const userSchema = new mongoose.Schema({
//     name: String,
//     email: String,
//     password: String
// })
//creating schema to store email id and password
const registerSchema = new mongoose.Schema ({
    name: String,
    role: String,
    email: String,
    password: String,
     
})

//creating model of registerSchema
const User = mongoose.model("User", registerSchema) 



//routes
app.post("/login", async (req, res) => {
  try {
      console.log(req.body);
      const { email, password } = req.body;
      
      // Check if email already exists
      const existingUser = await User.findOne({ email: email });
      
      if (existingUser) {
          const validPassword = await bcrypt.compare(password, existingUser.password);  // Using bcrypt to compare encrypted password

          if (validPassword) {
              res.send({
                  message: "Login successful",
                  user: {
                      name: existingUser.name,
                      email: existingUser.email,
                      role: existingUser.role
                  }
              });
          } else {
              res.send({ message: "Wrong password" });
          }
      } else {
          res.send({ message: "No user exists with the current email" });  
      }
      
  } catch (err) {
      console.error(err);
      return res.status(500).send(err);
  }
});



// app.post("/register", (req, res) => {
//     // res.send("MY API register")
//     console.log(req.body)
//     const {name, role, email, password} = req.body;
    
//     //before storing data, see if email already exist
//     User.findOne({email: email}, 
//     (err, user) => {
//         if(user)
//         {
//             res.send({message: "user already registerd"})
//         }
//         else
//         {
//             const user = new User({
//                 //shorthand notation
//                 name, 
//                 role, 
//                 email, 
//                 password
//             })
        
//             // user.save()
//             user.save(err => {
//                 if(err) res.send(err)
//                 else res.send({message: "successful"})
        
//             })
//         }

//     })

// });

app.post("/register", async (req, res) => {
    try {
        console.log(req.body);
        const { name, role, email, password } = req.body;
        
        //encrypting password
        const saltRounds = 5;
        const encryptedPassword = await bcrypt.hash(password, saltRounds);

        // Check if email already exists
        const existingUser = await User.findOne({ email: email });
        
        if (existingUser) {
            return res.send({ message: "User already registered" }); 
        }
        
        const user = new User({ 
            name, 
            role, 
            email, 
            password: encryptedPassword  
            // password,
        });
        
        await user.save();
        
        return res.status(201).send({ message: "User successfully registered" });
        
        
    } catch (err) {
        console.error(err);
        return res.status(500).send(err);
    }
});


//creating schema to store question and answer
const gptSchema = new mongoose.Schema ({
    question: String,
    answer: String 
})

//creating model of gptSchema
const Admin = mongoose.model("Admin", gptSchema) 

app.post('/admin', async (req, res) => {
  const { question, answer } = req.body;
  
  try {
    const existingQues = await Admin.findOne({ question: question });
    
    // If the question exists
    if (existingQues) 
    {
      // If the answer also exists
      if (existingQues.answer === answer) 
      {
        
        return res.send({ message: "Question and answer already exist", alert: "Question and answer already exist" });
      }
      
      // Updating answer for the existing question
      existingQues.answer = answer;
      await existingQues.save();  
      return res.send({ message: "Answer updated successfully", alert: "Answer is updated" }); 
    }
    
    // If the question doesn't exist, create a new entry
    const form = new Admin({ question, answer });
    await form.save();
    res.send({ message: "Data saved successfully", alert: "Data saved successfully" });
  } 
  catch (err) {
    console.error(err);
    res.send({ message: "Internal Server Error" });
  }
});

//   console.log("186")
  app.get('/getQuestions', async (req, res) => {
    console.log("188")
    try {
        const forms = await Admin.find({}, 'question');  // only fetch the 'question' field
        const questions = forms.map(form => form.question);  // extract questions from forms
        res.status(200).send({ questions });
      } catch (err) {
        console.error(err);
        res.status(500).send({ message: 'Internal Server Error' });
      }
    });

 app.post('/getAnswer', async (req, res) => {
  const { question } = req.body;
  try {
    const form = await Admin.findOne({ question });
    if (form) {
      res.status(200).send({ answer: form.answer });
    } else {
      res.status(404).send({ message: 'Question not found' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).send({ message: 'Internal Server Error' });
  }
});


/***********************************************implementing history****************************** */


//creating schema to store question and answer
const historySchema = new mongoose.Schema ({

  // email: String,
  question: String,
  answer: String
})

//creating model of gptSchema
const History = mongoose.model("History", historySchema) 


app.post("/saveHistory", async (req, res) => {
  try {
    // console.log("seeing if data is correct", req.body)
    const { email, question, answer } = req.body;
    const newHistory = new History({
      // email,
      question,
      answer
    });

    await newHistory.save();
    res.status(200).send({ message: "History saved successfully" });
  } catch (err) {
    console.error("Could not save history:", err);
    res.status(500).send({ message: "Internal Server Error" });
  }
});


//   app.get("/get-user", async (req, res) => {
//     const user = await User.findById(req.userId);
//     res.send({ id: user._id, ...otherFields });
//   });

//   app.get("/get-admin", async (req, res) => {
//     const admin = await Admin.findById(req.adminId);
//     res.send({ id: admin._id, ...otherFields });
//   });
  
// app.post("/save-chat-id", async (req, res) => {
//   try {
//     const { userId, questionId } = req.body;
//     const user = await User.findById(userId);
//     if (!user) {
//       return res.status(404).send({ message: "User not found" });
//     }
//     user.chatHistoryIds.push(questionId);
//     await user.save();
//     return res.send({ message: "Chat ID saved successfully" });
//   } catch (error) {
//     console.error(error);
//     return res.status(500).send({ message: "Internal Server Error" });
//   }
// });


app.get("/chat-history", async (req, res) => {
  console.log("hitting chat his")
  try {

    
    //as no condition is given in find() so all question will be feteched
    const chatHistory = await History.find({})

    return res.send(chatHistory);
  } catch (error) {
    console.error(error);
    return res.status(500).send({ message: "Internal Server Error" });
  }
});


app.delete("/chat-history", async (req, res) => {
  try {

    //deleteing history
    await History.deleteMany({})

    res.send({ message: "Chat history deleted." });
  } catch (error) {
    console.error(error);
    return res.status(500).send({ message: "Internal Server Error" });
  }
});


app.listen(9003, () => {
    console.log( "starting at port 9002")

})

