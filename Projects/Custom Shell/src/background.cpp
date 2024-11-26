
#include "header.h"
#include "background.h"
#include "exec.h"
using namespace std;

void background(std::vector<std::string>& arguments)
{
    pid_t pid = fork();

    if(pid == -1)
    {
        perror("ERROR in creating child process");
    }
    else if(pid == 0)
    {
         
        call_exec(arguments);//cout<<"child: "<<pid<<endl;
        //setpgid(0, 0);
        
    }
    else 
    {
        std::cout<<"["<<pid<<"]"<<endl;
        //int status;
        //waitpid(pid, &status, WUNTRACED);   //Also return if a child has stopped
    }
}