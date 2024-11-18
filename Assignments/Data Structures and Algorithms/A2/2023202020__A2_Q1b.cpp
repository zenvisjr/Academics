#include<iostream>
#include<climits>
using namespace std;

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

        // inscreasing size of pq to hold 1 more element
        psize = psize+1;
        int * temp = new int[psize];
        for(int i=0; i<psize; i++)
        {
            temp[i] = pq[i];
        }
        delete[] pq;
        pq = temp;

        //finally inserting the element at last position
        pq[psize-1] = INT_MAX;
        decrease_key(psize-1, key);
        //cout<<"size: "<<psize<<endl;
        
    }

    int top()
    {
        if(empty()) 
        {
            //cout<<"empty"<<endl;
            return 0;
        }
        return pq[0];
    }

    void pop()
    {
        if(empty()) 
        {
            //cout<<"no element present"<<endl;
            return;

        }
        
        // if(psize == 1)
        // {
        //     psize--;
        //     return;
        // }
        else
        {
            int min = pq[0];
            pq[0] = pq[psize-1];
            psize--;
            //cout<<"deleted element: "<<min<<endl;

            min_heapify(0);
            //print();
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
    

    void clear()
    {
        delete [] pq;
        psize = 0;

        // cout<<"size: "<<psize<<endl;
        // cout<<"capacity: "<<pcap<<endl;
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

        // cout<<"size: "<<psize<<endl;
        // cout<<"capacity: "<<pcap<<endl;
    }

    int size()
    {
        return psize;
    }

    void push(int key)
    {
        if(psize == pcap) resize();
 
        psize = psize+1;
        // int * temp = new int[psize];
        // for(int i=0; i<psize; i++)
        // {
        //     temp[i] = pq[i];
        // }
        // delete[] pq;
        // pq = temp;

        //finally inserting the element at last position
        pq[psize-1] = INT_MIN;
        increase_key(psize-1, key);
        //cout<<"size: "<<psize<<endl;
    }

    int top()
    {
        if(empty()) 
        {
            //cout<<"empty"<<endl;
            return 0;
        }
        return pq[0];
    }

    void pop()
    {
        if(empty()) 
        {
            //cout<<"no element present"<<endl;
            return;
        }
        // if(psize == 1)
        // {
        //     psize--;
        //     return;
        // }
        else
        {
            int max = pq[0];
            pq[0] = pq[psize-1];
            psize--;
            //cout<<"deleted element: "<<max<<endl;

            max_heapify(0);
            //print();
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
        //print();
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

        // cout<<"size: "<<psize<<endl;
        // cout<<"capacity: "<<pcap<<endl;
    }
    void heapsort()
{
    //build_max_heap();
    //int size = pq.length()
    int size = psize;
    //cout<<"size: " <<psize<<endl;
    //int size = d;
    for(int i=psize-1; i>=1 ; i--)
    {
        int temp = pq[0];
        pq[0] = pq[i];
        pq[i] = temp;
        //swap(&pq[0], &pq[i]);
        //print();
        psize--;
        max_heapify(0);
        //print();
    }
    psize = size;
    //print();
}

    float median()
    {
        if(psize%2 != 0)
        {
            return pq[psize/2];
        }
        else
        {
            float a = pq[(psize)/2];
            //cout<<"a: "<<a<<endl;
            float b = pq[(psize-2)/2];
            //cout<<"b: "<<b<<endl;
            float result = (a+b)/2;
            //cout<<"result: "<<result<<endl;
            return result;
        }
    }

};


#include <iostream>
using namespace std;



int david_backery(int sales[], int n, int d);


int main() 
{
    // minheapPQ min;
    // maxheapPQ max;
    int decide;

    // cout << "On which heap u want to perform operation: 1. MIN HEAP 2. MAX HEAP" << endl;
    // cin >> decide;

    // if (decide == 1)  switch_menu(min);
    //  else  switch_menu(max);

    int n, d;
    // cout<<"Enter n and d"<<endl;
     cin>>n>>d;
    if(n<d)
    {
        //cout<<"not possible"<<endl;
        exit(0);
    }
    int sales[n] /*= {2,3,4,2,1,6,3,6, 14, 12, 16, 5, 15, 12, 1}*/;
    // cout<<"Enter sales of n days:"<<endl;
    for(int i =0; i<n ; i++)
    {
        cin>>sales[i];
    }
    // cout<<endl;

    int days = david_backery(sales, n, d);
    //cout<<"days: "<<days<<endl;
    cout<<days<<endl;

    return 0;
}

int david_backery(int sales[], int n, int d)
{
    // for(int i = 0; i<n ; i++)
    // {
    //     cout<<sales[i]<<" "<<endl;
    // }
    // cout<<"n: "<<n<<endl;
    // cout<<"d: "<<d<<endl;
    //cout<<"503"<<endl;
    maxheapPQ maxh;
    minheapPQ minh;

    maxheapPQ maxA;
    minheapPQ minA;

    maxA.priority_queue();
    minA.priority_queue();


    maxh.priority_queue();
    minh.priority_queue();

    int remove[n] = {0};
    int index = 0;

    int i, j, k, start=0, end=0, count=0;
    int combine_size=0;
    for(i = 0; i<n; i++)
    {
        if(i==0)
        {
            continue;
        }
        
        //cout<<"current sale: "<<sales[i]<<endl;
        if(maxA.empty() || sales[i-1] <= maxA.top())
        {
                maxA.push(sales[i-1]);
        }
        else
        {
            minA.push(sales[i-1]);
        }

        //balancing heap
        if(maxA.size() > minA.size()+1)
        {
            minA.push(maxA.top());
            maxA.pop(); 
        }
        else if (minA.size() > maxA.size())
        {
            maxA.push(minA.top());
            minA.pop(); 
        }

        if(i<d)
        {
            continue;
        }
        end = i;
        //cout<<"512"<<endl;
        //finding median of trailing d days

        //writing removing logic
        
        if(start>0)
        {
        //     cout<<"in: "<<sales[i-1]<<endl;
        //     cout<<"out: "<<sales[start-1]<<endl;
            remove[sales[start-1]]++;
            int bal=0;
            if(sales[start-1]<=maxh.top()) bal=-1;
            else bal = 1;

            //cout<<"bal: "<<bal<<endl;

            // if(sales[i-1]<= maxh.top()) bal++;
            // else bal--;

            // if(bal < 0)
            // {
            //     maxh.push(minh.top());
            //     minh.pop();
            // }
            // else if(bal > 0)
            // {
            //     minh.push(maxh.top());
            //     maxh.pop();
            // }

            // while (!maxh.empty() && remove[maxh.top()] > 0)
            // {
            //     remove[maxh.top()]--;
            //     maxh.pop();
            // }

            // while (!minh.empty() && remove[minh.top()] > 0)
            // {
            //     remove[minh.top()]--;
            //     minh.pop();
            // }

            if(maxh.empty() || sales[i-1] <= maxh.top())
            {
                    maxh.push(sales[i-1]);
                    bal++;
            }
            else
            {
                minh.push(sales[i-1]);
                bal--;
            }


            if(bal < 0)
            {
                //cout<<"Enter bal<0"<<endl;
                maxh.push(minh.top());
                minh.pop();
            }
            else if(bal > 0)
            {
                //cout<<"Enter bal>0"<<endl;
                minh.push(maxh.top());
                maxh.pop();
            }


            while (!maxh.empty() && remove[maxh.top()] > 0)
            {
                //cout<<"Enter max>0"<<endl;
                remove[maxh.top()]--;
                maxh.pop();
            }

            while (!minh.empty() && remove[minh.top()] > 0)
            {
                //cout<<"Enter min>0"<<endl;
                remove[minh.top()]--;
                minh.pop();
            }

            //balancing heap
            // if(maxh.size() > minh.size()+1)
            // {
            //     minh.push(maxh.top());
            //     maxh.pop(); 
            // }
            // else if(minh.size() > maxh.size())
            // {
            //     maxh.push(minh.top());
            //     minh.pop(); 
            // }

            //again checking top is marked for deletion
            // while (!maxh.empty() && remove[maxh.top()] > 0)
            // {
            //     remove[maxh.top()]--;
            //     maxh.pop();
            // }

            // while (!maxh.empty() && remove[minh.top()] > 0)
            // {
            //     remove[minh.top()]--;
            //     minh.pop();
            // }
            
        }
        else
        {
            for(j=start; j<end; j++)
            {
                
                if(maxh.empty() || sales[j] <= maxh.top())
                {
                    maxh.push(sales[j]);
                }
                else
                {
                    minh.push(sales[j]);
                }

                //balancing heap
                if(maxh.size() > minh.size()+1)
                {
                    minh.push(maxh.top());
                    maxh.pop(); 
                }
                else if(minh.size() > maxh.size())
                {
                    maxh.push(minh.top());
                    minh.pop(); 
                }
            
            }

        }

        


        float medD = 0;
        combine_size = minh.size() + maxh.size();
        //cout<<"print max heap d days: ";
        //maxh.print();
        //cout<<"max element in left: "<<maxh.top()<<endl;
        //cout<<"print min heap d days: ";
        //minh.print();
        //cout<<"max element in right: "<<maxh.top()<<endl;
        
        if(d%2 != 0)
        {
            //cout<<"Enter median d days:"<<endl;
            if(minh.size()>maxh.size())
            {
                medD = minh.top();
            }
            else
            {
                medD = maxh.top();
            }
        }
        else
        {
            //cout<<"Enter else median d days:"<<endl;
            medD = (static_cast<float>(minh.top() + maxh.top()))/2.0;
        }
        //cout<<"**************************************************median D:"<<medD<<endl;
        // minh.clear();
        // maxh.clear();

        float medA = 0;
        combine_size = minA.size() + maxA.size();

        //cout<<"print max heap all days: ";
        //maxA.print();
        //cout<<"max element in left: "<<maxA.top()<<endl;
       // cout<<"print min heap all days: ";
        //minA.print();
        //cout<<"max element in right: "<<minA.top()<<endl;
        if(combine_size%2 != 0)
        {
            //cout<<"Enter median all days:"<<endl;
            if(minA.size()>maxA.size())
            {
                medA = minA.top();
            }
            else
            {
                medA = maxA.top();
            }
        }
        else
        {
            //cout<<"Enter else median all days:"<<endl;
            medA = (static_cast<float>(minA.top() + maxA.top()))/2.0;
        }
        //cout<<"**********************************************median A:"<<medA<<endl;

        //finding median of sales from start

        //max.print();

        // max.heapsort();

        // float med1 = max.median();

        //cout<<"**********med1: "<<med1<<endl;
        
        //finding median from start to current day
        //max.clear();

        // max.priority_queue();

        // for(k=0; k<end; k++)
        // {
        //     max.push(sales[k]);
        // }
        // //max.print();

        // max.heapsort();

        // float med2 = max.median();
        //cout<<"***********med2: "<<med2<<endl;

        float med = medD + medA;
        //cout<<"*********med: "<<med<<endl;

        if(sales[i] >= med ) count++;
        
        //cout<<"count days: "<<count<<endl;

        start++;
        //cout<<"count: "<<count<<endl;
    
    }
    return count;
}
