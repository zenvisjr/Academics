#include "header.h"
#include "history.h"

using namespace std;

int hist_save()
{
    while(history_length > 20)
    {
        remove_history(0);   // removes the oldes command from the list
        history_length--;
    }

    const char * path = "/home/zenvis/Desktop/history.txt";
//     FILE* file = fopen(path, "w");
   
//    if(file == NULL)
//    {
//     perror("unable to open file due to some failure");
//     return 0;
//    }
    // int fd;
    // fd = open(path, O_CREAT | O_RDWR  | O_APPEND, 0644);
    //const char * path = "/home/zenvis/Desktop/history.txt";
    int i = write_history(path);
    if(i != 0)
    {
        perror("unable to write history to file");
    }
    //fclose(file);
    return 0;
}

int hist_read()
{
     const char * path = "/home/zenvis/Desktop/history.txt";
//     FILE* file = fopen(path, "r");
   
//    if(file == NULL)
//    {
//     perror("unable to open file due to some failure");
//     return 0;
//    }
   int i = read_history(path);
   if(i != 0)
    {
        perror("unable to read history from file");
    }
    //fclose(file);
    return 0;
}

 bool hist_retrieve()
{
     //cout<<"entering history function"<<endl;

    HIST_ENTRY ** history = history_list();
    //cout<<history_length<<endl;

    if(history_length>10)
    {
        int temp = history_length - 10;
        for(int i=temp; i<history_length; i++)
        {
            //line is a member of the HIST_ENTRY structure that contains the actual command string of that history entry.
            cout<<history[i]->line<<endl;
        }
    }
    else
        {
            for(int i=0; i<history_length; i++)
            {
            
                cout<<history[i]->line<<endl;
            }

        }
    return true;
}

 bool hist_retrieve_num(int num)
{
     //cout<<"entering history function"<<endl;
     if(num>20)
     {
        perror("can't retrieve more than 20 commands");
        return false;
     }

    HIST_ENTRY ** history = history_list();
    //cout<<history_length<<endl;
    int temp = history_length;
    for(int i= temp-num; i<history_length; i++)
    {
    
        cout<<history[i]->line<<endl;
    }
    return true;
}
