
#include "header.h"
#include "echo.h"
#include "utility.h"

bool echo(std::string& command)
{
    std::string text;
    if(command.size() == 4)
    {
        std::cout<<std::endl;
        return true;
    }
    else if(command.substr(0, 5) == "echo ")
    {
        text = command.substr(5);
        text = trim(text);
        if (text.front() == '"' && text.back() == '"') 
        {
            text = text.substr(1, text.length() - 2);
        }
        else if (text.front() == '\'' && text.back() == '\'') 
        {
            text = text.substr(1, text.length() - 2);
        }
        //cout<<"echoooooo"<<endl;
        text = tokenize(text);
        std::cout<<text<<std::endl;
        return true;
    }
    else return false;
}
