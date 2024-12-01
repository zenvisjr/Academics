#include "header.h"
#include "redirection.h"
#include "exec.h"

using namespace std;

bool output_redirection(vector<string>& command, string& sep, vector<string>& output)
{
    //cout<<"inside output redirection"<<endl;
    pid_t pid;
    pid = fork();
    //cout<<pid<<endl;

    if(pid<0)
    {
        perror("unable to create child process");
        return 0;
    }

    if(pid==0)
    {
        int fd;
        if(sep == ">") fd = open(output[0].c_str(), O_CREAT | O_WRONLY  | O_TRUNC, 0644);
        else fd = open(output[0].c_str(), O_WRONLY  | O_APPEND);
        //cout<<fd<<endl;
        if(fd== -1)
        {
            perror("unable to open file");
            exit(EXIT_FAILURE);
        }
        //int ofd;
        //ofd = dup(STDOUT_FILENO);
        if(dup2(fd, STDOUT_FILENO) == -1)
        {
            perror("unable to write on output file");
            exit(EXIT_FAILURE);
        }
            //cout<<"after dup"<<endl;
        //system("ls -l");

        call_exec(command);
        
        //cout<<"after ls"<<endl;
        
        close(fd);
       // close(ofd);
        exit(0);
    }
    else
    {
        wait(NULL);
        //cout<<"hyhyhyh"<<endl;
    }
   
return true;
}

// void handle_sigchld(int sig) {
//     while (waitpid(-1, NULL, WNOHANG) > 0);
// }
bool input_redirection(vector<string>& command, vector<string>& output)
{
    //cout<<"inside input redirection"<<endl;
    //int pip[2];
    pid_t pid;
    pid = fork();

    if(pid<0)
    {
        perror("unable to create child process");
        return 0;
    }

    if(pid==0)
    {
        int fd;
        fd = open(output[0].c_str(), O_RDONLY);
    
        //cout<<fd<<endl;
        if(fd== -1)
        {
            perror("file do not exist");
            exit(EXIT_FAILURE);
        }
        //int ofd;
        //ofd = dup(STDOUT_FILENO);
        if(dup2(fd, STDIN_FILENO) == -1)
        {
            perror("unable to write on output file");
            exit(EXIT_FAILURE);
        }
            //cout<<"after dup"<<endl;
        //system("ls -l");

        call_exec(command);
        
        //cout<<"after ls"<<endl;
        
        close(fd);
       // close(ofd);
        exit(0);
    }
    else
    {
        wait(NULL);
        //cout<<"hyhyhyh"<<endl;
    }
   
return true;
}

bool input_output_redirection(vector<string>& command,string& sep, vector<string>& input,vector<string>& output)
{
    //cout<<"inside input output redirection"<<endl;
    pid_t pid;
    pid = fork();

    if(pid<0)
    {
        perror("unable to create child process");
        return 0;
    }

    if(pid==0)
    {
        //cout<<"inside input output redirection child process"<<endl;
        //taking input from input file to command
        int fd1;
        fd1 = open(input[0].c_str(), O_RDONLY);
    
        //cout<<fd1<<endl;
        if(fd1== -1)
        {
            perror("file do not exist");
            exit(EXIT_FAILURE);
        }
        //int ofd;
        //ofd = dup(STDOUT_FILENO);
        if(dup2(fd1, STDIN_FILENO) == -1)
        {
            perror("unable to write on output file");
            exit(EXIT_FAILURE);
        }
        //cout<<"after dup"<<endl;
        close(fd1);
        //cout<<"inside"<<endl;
        //writing output of command to output file
        int fd2;
        //cout<<"output: "<< output[0]<<endl;
        //cout<<sep<<endl;
        //cout<<"output: "<< output[0]<<endl;
        if(sep == ">") fd2 = open(output[0].c_str(), O_CREAT | O_WRONLY  | O_TRUNC, 0644);
        else fd2 = open(output[0].c_str(), O_WRONLY  | O_APPEND);
        //cout<<sep<<endl;
        //cout<<fd2<<endl;
        if(fd2 == -1)
        {
            perror("unable to open file");
            exit(EXIT_FAILURE);
        }
        //int ofd;
        //ofd = dup(STDOUT_FILENO);
        if(dup2(fd2, STDOUT_FILENO) == -1)
        {
            perror("unable to write on output file");
            exit(EXIT_FAILURE);
        }
        //cout<<"after dup"<<endl;
        close(fd2);
        //cout<<"outside"<<endl;
        call_exec(command);
    }
    else
    {
        wait(NULL);
        //cout<<"hyhyhyh"<<endl;
    }
   
return true;
}
