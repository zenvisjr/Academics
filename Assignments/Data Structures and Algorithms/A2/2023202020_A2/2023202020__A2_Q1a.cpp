#include<iostream>
#include<climits>
using namespace std;

// int* pq;
// int psize;
class minheapPQ
{
    public:
    int* pq;
    int psize;  
    int pcap;

    void priority_queue()
    {
        pq = new int[10];
        pcap = 10;
        psize = 0;
    }

    int size()
    {
        return psize;
    }

    void push(int key)
    {
        if(psize == pcap) resize();

        psize = psize+1;
        pq[psize-1] = INT_MAX;
        decrease_key(psize-1, key);
        //cout<<"size: "<<psize<<endl;
        
    }

    int top()
    {
        if(empty()) 
        {
            cout<<"empty"<<endl;
            return 0;
        }
        return pq[0];
    }

    void pop()
    {
        if(empty()) cout<<"no element present"<<endl;
        else
        {
            int min = pq[0];
            pq[0] = pq[psize-1];
            psize--;
            //cout<<"deleted element: "<<min<<endl;

            min_heapify(0);
            print();
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
        int* temp_arr = new int[pcap*2];
        for (int i = 0; i < psize; i++) {
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
            int temp = pq[i];
            pq[i] = pq[min];
            pq[min] = temp;

            min_heapify(min);
        }
    }

    void decrease_key(int position, int key)
    {
        if(key > pq[position])
        return;

        pq[position] = key;
        while(position >0 && (pq[(position-1)/2] > pq[position]))
        {
            int temp = pq[position];
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

class maxheapPQ
{
    public:
    int* pq;
    int psize;  
    int pcap;

    void priority_queue()
    {
        pq = new int[10];
        pcap = 10;
        psize = 0;
    }

    int size()
    {
        return psize;
    }

    void push(int key)
    {
        if(psize == pcap) resize();
 
        psize = psize+1;
        pq[psize-1] = INT_MIN;
        increase_key(psize-1, key);
    }

    int top()
    {
        if(empty()) 
        {
            cout<<"empty"<<endl;
            return 0;
        }
        return pq[0];
    }

    void pop()
    {
        if(empty()) cout<<"no element present"<<endl;
        else
        {
            int max = pq[0];
            pq[0] = pq[psize-1];
            psize--;
            cout<<"deleted element: "<<max<<endl;

            max_heapify(0);
            print();
            cout<<"size: "<<psize<<endl;

        }
    }

    bool empty()
    {
        return (psize == 0)?1:0;
    }

    //helper functions

    void resize() 
    {
        int* temp_arr = new int[pcap*2];
        for (int i = 0; i < psize; i++) {
            temp_arr[i] = pq[i];
        }
        delete[] pq;
        pq = temp_arr;
        pcap = pcap*2;
    }


    void increase_key(int position, int key)
    {
        if(key < pq[position])
        return;

        pq[position] = key;
        while(position >0 && (pq[(position-1)/2] < pq[position]))
        {
            int temp = pq[position];
            pq[position] = pq[(position-1)/2];
            pq[(position-1)/2] = temp;

            position = (position-1)/2;
        }
    }

    void max_heapify(int index)
    {
        int max;
        int i = index;
        int left = 2*i+1;
        int right = 2*i+2;

        if(left < psize && pq[left] > pq[i]) max = left;
        else max = i;

        if(right < psize && pq[right] > pq[max]) max = right;
        
        if(max != i)
        {
            int temp = pq[i];
            pq[i] = pq[max];
            pq[max] = temp;

            max_heapify(max);
        }
    }

    void print()
    {
        for(int i=0;i<psize; i++)
        cout<<pq[i]<<" ";
        cout<<endl;
    }

    void clear()
    {
        delete [] pq;
        psize = 0;
    }

};

#include <iostream>
using namespace std;



void switch_menu(auto &heap) {
    int choice = -1;
    while (choice != 0) {
        cin >> choice;
        if (choice == 1) {
            heap.priority_queue();
            heap.print();
        }
        else if (choice == 2) {
            cout << "size: " << heap.size() << endl;
        }
        else if (choice == 3) {
            int n;
            cin >> n;
            heap.push(n);
            heap.print();
        }
        else if (choice == 4) {
            cout << "top: " << heap.top() << endl;
        }
        else if (choice == 5) {
            heap.pop();
            heap.print();
        }
        else if (choice == 6) {
            cout << boolalpha << heap.empty() << endl;
        }
        else if (choice == 0) {
            return;
        }
        else {
            cout << "Jaldi yaha se hato" << endl;
        }
    }
}


int main() 
{
    minheapPQ min;
    maxheapPQ max;
    int decide;

    cout << "On which heap u want to perform operation: 1. MIN HEAP 2. MAX HEAP" << endl;
    cin >> decide;

    if (decide == 1)  switch_menu(min);
    else  switch_menu(max);
    return 0;
}

