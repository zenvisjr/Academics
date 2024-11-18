#include<iostream>
#include<string>
using namespace std;

template <typename T>
class Deque
{
    public:

    T* q;
    int qsize;
    int qcapacity;
    int f;
    int r;

    void resize(int n)
    {
        T* arr_temp = new T[n];

        if(n>qsize)
        {
            for(int i=0;i<qsize;i++)
            {
                int temp = (f+i)%qcapacity;
                arr_temp[i] = q[temp];
            }
            qcapacity = n;
            f = 0;
            r = qsize-1;
            for(int i=qsize;i<qcapacity;i++)
            {
                arr_temp[i] = T();
            }
            q = arr_temp;
        }
        else
        {
            for(int i=0;i<n;i++)
            {
                int temp = (f+i)%qcapacity;
                arr_temp[i] = q[temp];
            }
                q = arr_temp;
                qcapacity = n;
                f = 0;
                r = qcapacity-1;
        }
        /*for(int i=0;i<qcapacity;i++)
            {
                cout<<q[i]<<" ";
            }
         cout<<endl;*/
    }


    void resize(int n, T d)
    {
        T* arr_temp = new T[n];

        if(n>qsize)
        {
            for(int i=0;i<qsize;i++)
            {
                int temp = (f+i)%qcapacity;
                arr_temp[i] = q[temp];
            }
            qcapacity = n;
            f = 0;
            r = qsize-1;
            for(int i=qsize;i<qcapacity;i++)
            {
                arr_temp[i] = d;
            }
            q = arr_temp;
        }
        else
        {
            for(int i=0;i<n;i++)
            {
                int temp = (f+i)%qcapacity;
                arr_temp[i] = q[temp];
            }

                q = arr_temp;
                qcapacity = n;
                f = 0;
                r = qcapacity-1;
        }
        /*for(int i=0;i<qcapacity;i++)
            {
                cout<<q[i]<<" ";
            }
         cout<<endl;*/
    }
    void reserve(int n)
    {
        if(n>qcapacity)
        {
            T* arr_temp = new T[n];
            for(int i=0;i<qsize;i++)
            {
                int temp = (f+i)%qcapacity;
                arr_temp[i] = q[temp];
            }

            q = arr_temp;
            qcapacity = n;
            f = 0;
            r = qsize-1;
        }
        /*for(int i=0;i<qcapacity;i++)
            {
                cout<<q[i]<<" ";
            }
            cout<<endl;*/
    }

    void shrink_to_fit()
    {
        if(qcapacity>qsize)
        {
            T* arr_temp = new T[qsize];
            for(int i=0;i<qsize;i++)
            {
                int temp = (f+i)%qcapacity;
                arr_temp[i] = q[temp];
            }

                q = arr_temp;
                qcapacity = qsize;
                f = 0;
                r = qsize-1;
        }
        /*for(int i=0;i<qsize;i++)
            {
                cout<<q[i]<<" ";
            }
            cout<<endl;*/
    }

    bool empty()
    {
        return (f==r==-1 || qsize == 0)?1:0;
    }
    void deque()
    {

        q = new T[0];

        f=-1;
        r=-1;
        qcapacity=0;
        qsize=0;
    }

    void deque(int n)
    {
        q = new T[n];
        if(q == NULL)
        {
            cout<<"Memory cant be allocated"<<endl;
            return;
        }
        else
        {
            f=-1;
            r=-1;
            qcapacity=n;
            qsize=0;

            for(int i=0;i<n;i++)
            {
                q[i]=T();
            }

           /*for(int i=0;i<n;i++)
            {
                cout<<q[i]<<" ";
            }
            cout<<endl;*/
        }
        
    }

    void deque(int n, T x)
    {
        q = new T[n];
        if(q == NULL)
        {
            cout<<"Memory cant be allocated"<<endl;
            return;
        }
        else
        {
            f=-1;
            r=-1;
            qcapacity=n;
            qsize=0;

            for(int i=0;i<n;i++)
            {
                q[i]=x;
            }

        }
        /*for(int i=0;i<n;i++)
            {
                cout<<q[i]<<" ";
            }
            cout<<endl;*/
        
    }

    bool push_back(T n)
    {
        try
        {
            if(qcapacity==0)
            {
                q = new T[1];
                qcapacity=1;
                f=0;
                r=0;

            }
            else if(qsize==qcapacity)
            {
                resize(qcapacity*2);
                /*for(int i=0;i<qcapacity;i++)
                {
                    cout<<q[i]<<" ";
                }
                cout<<endl;*/

                r = (r+1)%qcapacity;
            }
            else if(f== -1 && r==-1)
            {
                f=0;
                r=0;
            }
            else
            {
                r = (r+1)%qcapacity;
            }
            if (r < 0 || r >= qcapacity) 
            {
                throw std::out_of_range("Index out of bounds");
            }
            q[r] = n;
            qsize++;
            /*for(int i=0;i<qcapacity;i++)
            {
                cout<<q[i]<<" ";
            }*/
            return true;
        } 
        catch (const std::bad_alloc &e) 
        {
            cerr << "Memory allocation not possible: " << e.what() << endl;
            return false;
        } 
        catch (const std::out_of_range &e)
        {
            cerr << "Index out of bounds: " << e.what() << endl;
            return false;
        } 
        catch (...) 
        {
            cerr << "Pta nahi bhai kya dikkat hai." << endl;
            return false;
        }
        
    }

    bool pop_back()
    {
        if(empty())
        {
            return false;
        }
        if(f==r)
        {
            f = -1;
            r = -1;
            qsize=0;
            return true;
        }
        else
        {
            r = (r-1+qcapacity)%qcapacity;
            qsize--;
            return true;
        }
        

    /*for(int i=0;i<qcapacity;i++)
        {
             cout<<q[i]<<" ";
          }
    cout<<endl;*/
    
    }

    bool push_front(T data)
    {
        try
        {
            if(qcapacity == 0)
            {
                q = new T[1];
                qcapacity = 1;
                f = r = 0;
            }
            else if(qsize==qcapacity)
            {
                resize(qcapacity*2);
                /*for(int i=0;i<qcapacity;i++)
                {
                    cout<<q[i]<<" ";
                }
                cout<<endl;*/

                f = (f+qcapacity-1)%qcapacity;

            }
            else if(f == -1 && r == -1)
            {
                f = 0;
                r = 0;
            }
            else 
            {
                f = (f-1+qcapacity)%qcapacity;
            }

            
            if (f < 0 || f >= qcapacity) 
            {
                throw out_of_range("Index out of bounds");
            }

            q[f] = data;
            qsize++;

            /*for(int i=0;i<qcapacity;i++)
            {
                cout<<q[i]<<" ";
            }
            cout<<endl;*/
            return true;
        }

        catch (const std::bad_alloc &e) 
        {
            cerr << "Memory allocation not possible: " << e.what() << endl;
            return false;
        } 
        catch (const std::out_of_range &e) 
        {
            cerr << "Index out of bounds: " << e.what() << endl;
            return false;
        } 
        catch (...) 
        {
            cerr << "Pta nahi bhai kya dikkat hai." << endl;
            return false;
        }

    }

    bool pop_front()
    {
        if(empty())
        {
            return false;
        }
        if(f==r)
        {
            f = -1;
            r = -1;
            qsize=0;
            return true;
        }
        else
        {
            f = (f+1)%qcapacity;
            qsize--;
            return true;
        }

        /*for(int i=0;i<qcapacity;i++)
            {
                cout<<q[i]<<" ";
            }
            cout<<endl;*/
        
    }

    T front()
    {
        if(empty())
        {
            return 0;
        }
        return q[f];
    }

    T back()
    {
        if(empty())
        {
            return 0;
        }
        return q[r];
    }


    int size()
    {
        return qsize;
    }

    void clear()
    {
        f = r = -1;
        qsize=0;
        qcapacity=0;

        /*for(int i=0;i<qcapacity;i++)
            {
                cout<<q[i]<<" ";
            }
            cout<<endl;*/
    }

    int capacity()
    {
        return qcapacity;
    }

    T& operator[](int n)
    {
        if(empty())
        {
            throw out_of_range("Index out of Bound");
        }
        else if(n>=0 && n<qsize)
        {
            return q[(f+n)%qcapacity];
        }
        else if (n<0 && n>=-qsize) 
        {
            return q[(f+n+qsize)%qcapacity];
        }
        else
        {
            throw out_of_range("Index out of Bound");
        }
    }

};



int main()
{
    Deque <string>d;
        string s;

    int choice = -1;
    while (choice != 0) {
        cin >> choice;
        if (choice == 1) {
            d.deque();
        }
        else if (choice == 2) {
            int n;
            cin >> n;
            d.deque(n);
        }
        else if (choice == 3) {
            int n;
            cin >> n;
            cin >> s;
            d.deque(n, s);
        }
        else if (choice == 4) {
            cin >> s;
            cout << boolalpha << d.push_back(s) << endl;
        }
        else if (choice == 5) {
            cout << boolalpha << d.pop_back() << endl;
        }
        else if (choice == 6) {
            cin >> s;
            cout << boolalpha << d.push_front(s) << endl;
        }
        else if (choice == 7) {
            cout << boolalpha << d.pop_front() << endl;
        }
        else if (choice == 8) {
            s = d.front();
            cout << s << endl;
        }
        else if (choice == 9) {
            s = d.back();
            cout << s << endl;
        }
        else if (choice == 10) {
            int position;
            cin>> position;
            cout << d[position] << endl;
        }
        else if (choice == 11) {
            cout << boolalpha << d.empty() << endl;
        }
        else if (choice == 12) {
            cout << d.size() << endl;
        }
        else if (choice == 13) {
            int size;
            cin>>size;
            d.resize(size);
        }
        else if (choice == 14) {
            int size;
            cin>>size;
            cin>>s;
            d.resize(size, s);
        }
        else if (choice == 15) {
            int size;
            cin>>size;
            d.reserve(size);
        }
        else if (choice == 16) {
            d.shrink_to_fit();
        }
        else if (choice == 17) {
            d.clear();
        }
        else if (choice == 18) {
            cout << d.capacity() << endl;
        }
        else if (choice == 0)
        {
            return 0;
        }
        else
            cout<<"Jaldi yaha se hato"<<endl;
    }
    return 0;
}