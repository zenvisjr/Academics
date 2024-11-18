#Q1: Website Redesign 

## Introduction

1. I have redesign the complete website, including pages for research, training, experiences, others and contact information
2. Search functionality is not implemented 

## How to Run

1. Navigate to the "Q1" folder
2. Locate the "about.html" file and click on it


#Q2: play with SPOTIFY APIs


## Introduction
This project allows you to interact with various Spotify APIs to fetch and display details about tracks, playlists, and artists

## Features

1. **Track Information**: Fetch detailed information about a particular track using its Spotify track ID
2. **Playlist Overview**: Fetch details about a playlist, including its top 3 songs, using the playlist's ID
3. **Artist's Top Tracks**: Discover the top 3 songs from any artist using their Spotify artist ID


## Prerequisites

- Internet connection to fetch data from Spotify's API
- Modern web browser (Google Chrome preferred)


## Technologies Used

- **Frontend**: HTML
- **Styling**: CSS
- **Backend**: Javascript

## How to Run

2. Navigate to the `Q2` folder
3. Open `index.html` in your preferred web browser


# Q3: Lite ChatGPT

## Features
- **User Authentication**: Login and Registration where each email ID is unique
- **Role-based redirection**: Logged in user will be redirected to chat area if his/her role is USER and to admin area if his/her role is ADMIN
- **Admin Page**: Admins can add new questions and answers as well as update answers of existing question
- **Predefined Questions**: Users can select questions from a dropdown and will get answer below it
- **Chat History**: common history of all users are stored where users can view and delete the chat history
- **Dark Mode**: Toggleable dark mode for the chat UI and Admin UI, not whole page


## Technologies Used
- **Frontend**: React.js
- **Styling**: CSS
- **Backend**: Node.js, Express.js
- **Database**: MongoDB


## How to Run the Project

### Prerequisites
- Node.js and npm must be installed
- MongoDB must be installed and running
```bash
sudo systemctl start mongod
```
-to run mongoDB
```bash
mongosh
```
-nodemon must be installed globally
```bash
nodemon install -g nodemon
```
### Backend

1. Navigate to the `backend` directory
2. Install the necessary packages

```bash
npm install
```
3. Start the server

```bash
nodemon index.js
```

4. The backend server will start running on `http://localhost:9002/`

### Frontend

1. Navigate to the `frontend` directory
2. Install the necessary packages

```bash
npm install
```
3. Start the React app

```bash
npm start
```

4. The frontend will start and automatically open `http://localhost:3000/` in the web browser

NOTE: I anm using Studio 3T Linux to see my databse in GUI


