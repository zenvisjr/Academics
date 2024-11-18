#include <iostream>
#include <fstream>
#include <string>
#include <queue>
#include <climits>
#include <functional>
#include <limits>
#include <sys/stat.h>
#include <unistd.h>
#include <iomanip>

#include <chrono>


using namespace std;
using namespace chrono;

long long BUFFERSIZE = 100000;
long long tempFileCount = 0;

template <class T>
class minheapPQ
{
    public:
    T* pq;
    int psize;  
    int pcap;

    minheapPQ()
    {
        pq = new T[10];
        pcap = 10;
        psize = 0;
    }

    int size()
    {
        return psize;
    }

    void push(T key)
    {
        if(psize == pcap) resize();

        psize = psize+1;
        // pq[psize-1] = INT_MAX;
        pq[psize-1] = make_pair(numeric_limits<long long int>::max(), numeric_limits<long long int>::max());

        decrease_key(psize-1, key);
        //cout<<"size: "<<psize<<endl;
        
    }

    T top()
    {
        if(empty()) 
        {
            // cout<<"empty"<<endl;
            return T();
        }
        return pq[0];
    }

    void pop()
    {
        if(empty()) 
        {
            // cout<<"no element present"<<endl;
            return;
        }
        else
        {
            T min = pq[0];
            pq[0] = pq[psize-1];
            psize--;
            //cout<<"deleted element: "<<min<<endl;

            min_heapify(0);
            // print();
            //cout<<"size: "<<psize<<endl;

        }
    }

    bool empty()
    {
        return (psize == 0)?1:0;
    }


    //helper functions

    void resize() 
    {
        T* temp_arr = new T[pcap*2];
        for (int i = 0; i < psize; i++) 
        {
            temp_arr[i] = pq[i];
        }
        delete[] pq;
        pq = temp_arr;
        pcap = pcap*2;
    }

    void min_heapify(int index)
    {
        int min;
        int i = index;
        int left = 2*i+1;
        int right = 2*i+2;

        if(left < psize && pq[left] < pq[i]) min = left;
        else min = i;

        if(right < psize && pq[right] < pq[min]) min = right;
        
        if(min != i)
        {
            T temp = pq[i];
            pq[i] = pq[min];
            pq[min] = temp;

            min_heapify(min);
        }
    }

    void decrease_key(int position, T key)
    {
        if(key > pq[position])
        return;

        pq[position] = key;
        while(position >0 && (pq[(position-1)/2] > pq[position]))
        {
            T temp = pq[position];
            pq[position] = pq[(position-1)/2];
            pq[(position-1)/2] = temp;

            position = (position-1)/2;
        }
        //print();
    }

    void print()
    {
        for(int i=0;i<psize; i++)
        cout<<pq[i]<<" ";
        cout<<endl;
    }


};



vector<string> createSortChunks(string inputFile)
{
    // cout<<"Entering create"<<endl;
    vector<string> uselessFiles;
    ifstream file(inputFile);
    // cout<<"Entering file"<<endl;
        if (!file.is_open()) {
        perror("Failed to open the input file");
        exit(1);
    }
    
    long long num;
    // cout<<"before while"<<endl;
    while(file >> num)
    {
        // cout<<"Entering while"<<endl;
        vector<long long> data;
        data.push_back(num);
        //reading size of chunk in data vector
        
        for(long long i=1; i<BUFFERSIZE; i++)
        {
            // cout<<"Entering loop"<<endl;
            file >> num;
            data.push_back(num);
        }
        //sorting the data vector
        // cout<<"Entering sort"<<endl;
        sort(data.begin(), data.end());

        //writing the sorted data back to a temp file

        //incrementing count of no o temp files
        tempFileCount++;

        //creating the name of temp file
        string tempName = "temp" + to_string(tempFileCount) + ".txt";

        //writing data back to file
        ofstream temp(tempName);
        for(auto i : data)
        {
            // cout<<"Entering write"<<endl;
            temp << i << " ";
        }
        temp.close();

        uselessFiles.push_back(tempName);
    }
    file.close();
    return uselessFiles;
}

void mergingFiles(string outputFile, vector<string> tempFiles)
{
    // cout<<"Entering merge"<<endl;
    long long noOfTempFiles = tempFiles.size();
    // priority_queue<pair<long long, long long>, vector<pair<long long, long long>>, greater<pair<long long, long long>>> smallest;
    minheapPQ<pair<long long, long long >> smallest;


    vector<ifstream> st(noOfTempFiles);

    for(long long i=0; i<noOfTempFiles; i++)
    {
        long long nums;
        st[i].open(tempFiles[i]);
        if(st[i] >> nums)
        {
            smallest.push({nums, i});
        }
    }

    ofstream output(outputFile);
    while(!smallest.empty())
    {
        long long min = smallest.top().first;
        long long fileNo = smallest.top().second;
        smallest.pop();

        output << min << " ";

        long long nextMin;
        if(st[fileNo] >> nextMin)
        {
            smallest.push({nextMin, fileNo});
        }
    }


}

int main(int argc, char* argv[])
{
    if(argc != 3)
    {
        cout<<"Usage: ./a.out <path/to/inputfile> <path/to/outputfile>"<<endl;
        exit(1);
    }
    // else
    // {
    //     cout<<"successfully"<<endl;
    // }

    //start timer
    auto start = high_resolution_clock::now();

    //reading input and output path in a string
    string inputPath = argv[1];
    string outputPath = argv[2];

    //checking path of input file
    struct stat fileStat;
    if (stat(inputPath.c_str(), &fileStat) == -1)
    {
        perror ("cannot access the given file: INVALID INPUT FILE PATH");
        return 0;
    }

    //checking path of output file
    // struct stat st;
    // if(stat(outputPath.c_str(), &st) != 0) 
    // {
    //     perror ("cannot access the given path: INVALID OUTPUT PATH");
    //     return 0;
    // } 
    // cout<<"226"<<endl;

    // cout<<"successfully"<<endl;
    vector<string> tempFiles = createSortChunks(inputPath);
    // cout<<"230"<<endl;
    mergingFiles(outputPath, tempFiles);
    // cout<<"232"<<endl;

    // cleaning useless files
    for (auto i : tempFiles) 
    {
        remove(i.c_str());
    }

    auto stop = high_resolution_clock::now();
    auto duration = duration_cast<seconds>(stop-start);
    long long totalTimeTaken = duration.count();
    cout<<"Number of integers in a temporary file: "<<BUFFERSIZE<<endl;
    cout<<"Number of temporary files created: "<<tempFileCount<<endl;
    cout<<"Total time taken by the program: "<<setprecision(2)<<totalTimeTaken<<" seconds"<<endl;
    return 0;



}
