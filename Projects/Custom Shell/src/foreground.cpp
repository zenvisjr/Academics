#include "header.h"
#include "foreground.h"
#include "exec.h"

using namespace std;


void foreground(std::vector<std::string>& arguments)
{
    pid_t pid = fork();

    if(pid == -1)
    {
        perror("ERROR in creating child process");
    }
    else if(pid == 0)
    {
        signal(SIGINT, SIG_DFL);  
        signal(SIGTSTP, SIG_DFL);
        
        //cout<<"child: "<<pid<<endl;
        call_exec(arguments);
    }
    else 
    {
        
        int status;
        waitpid(pid, &status, WUNTRACED);   //Also return if a child has stopped
        
    }
     //signal(SIGINT, SIG_IGN); 
     //signal(SIGTSTP, SIG_IGN);
     
}