#include<iostream>
#include<string>

using namespace std;

string rem;
void reverse(string &s, int n)
{
    int i=0, j=n-1;
    while(i<j)
    {
        swap(s[i++], s[j--]);
    } 
}

string add(string s1, string s2)
{
    int q=0;
    while(s1[q]=='0')
    {
        q++;
    }
    s1 = s1.substr(q);

    q=0;
    while(s2[q]=='0')
    {
        q++;
    }
    s2 = s2.substr(q);

    int n = s1.size();
    int m = s2.size();

    string result_add;
    int carry = 0;
    int temp;

    int minn = min(n, m);

    reverse(s1,n);
    reverse(s2,m);

    for(int i=0;i<minn;i++)
    {
        temp = (s1[i]-'0') + (s2[i]-'0') + carry;
        carry = temp/10;
        temp = temp%10;
        result_add+= to_string(temp);
    }
    string& maxx = (n>m)?s1:s2;

    for(int i=minn; i<max(n,m); i++)
    {
        temp = (maxx[i]-'0') + carry;
        carry = temp/10;
        temp = temp%10;
        result_add+= to_string(temp);

    }
    if(carry>0)
    {
        result_add+= to_string(carry);
    }

    int p = result_add.size();

    reverse(result_add, p);
    
    int i=0;
    while(result_add[i]=='0')
    {
        i++;
    }
    result_add = result_add.substr(i);
    
    return result_add;
}
string mul(string s1, string s2)
{
    int q=0;
    while(s1[q]=='0')
    {
        q++;
    }
    s1 = s1.substr(q);

    q=0;
    while(s2[q]=='0')
    {
        q++;
    }
    s2 = s2.substr(q);

    int n = s1.size();
    int m = s2.size();

    if(s1 == "0" || s2 == "0") return "0";

    reverse(s1,n);
    reverse(s2,m);

    string result_mul;
    int carry = 0;
    int temp ,i, j, k;
    string result_temp;

    int minn;
    int maxx;
    string newS1;
    string newS2;

    if(n>m)
    {
        maxx = n;
        minn = m;
        newS1 = s1;
        newS2 = s2;
    }
    else
    {
        maxx = m;
        minn = n;
        newS1 = s2;
        newS2 = s1;
    }

    for(i=0;i<minn;i++)
    {
        carry=0;
        result_temp = "";
        for(j=0;j<maxx;j++)
        {
            temp = (newS2[i]-'0')*(newS1[j]-'0') + carry;
            carry = temp/10;
            temp = temp%10;
            result_temp += to_string(temp);
        }
        if(carry>0)
        {
            result_temp += to_string(carry);
        }
        
        int m = result_temp.size(); 
        
        reverse(result_temp, m);
        
        for(k=0;k<i;k++)
        {
            result_temp += "0";
        }
        result_mul = add(result_mul, result_temp);
    }
    i=0;
    while(result_mul[i]=='0')
    {
        i++;
    }
    result_mul = result_mul.substr(i);
    
    return result_mul;
}


string sub(string s1, string s2)
{
    int q=0;
    while(s1[q]=='0')
    {
        q++;
    }
    s1 = s1.substr(q);

    q=0;
    while(s2[q]=='0')
    {
        q++;
    }
    s2 = s2.substr(q);
    
    if(s1==s2) return "0";
    int n = s1.size();
    int m = s2.size();

    string result_sub;
    int borrow = 0;
    int temp;

    int minn = min(n, m);

    reverse(s1,n);
    reverse(s2,m);

    for(int i=0;i<minn;i++)
    {
        temp = (s1[i]-'0') - (s2[i]-'0') - borrow;
        if(temp<0)
        {
            borrow = 1;
            temp = temp + 10;
        }
        else
        {
            borrow = 0;
        }
        result_sub+= to_string(temp);
    }
    string& maxx = (n>m)?s1:s2;

    for(int i=minn; i<max(n,m); i++)
    {
        temp = (maxx[i]-'0') -borrow ;
        if(temp<0)
        {
            borrow = 1;
            temp = temp + 10;
        }
        else
        {
            borrow = 0;
        }

        result_sub+= to_string(temp);

    }

    int p = result_sub.size();
    reverse(result_sub, p);
    int i=0;
    while(result_sub[i]=='0')
    {
        i++;
    }
    result_sub = result_sub.substr(i);
    
    
    return result_sub;
}

string fac(string s1)
{
    string result_fac = "1";
    string temp = s1;
    while(temp != "1")
    {
        result_fac = mul(result_fac, temp);
        temp = sub(temp, "1");
    }
    return result_fac;
}

int compare_string(string s1, string s2)
{
    int n = s1.length();
    int m = s2.length();
    int i=0;

    if(s1==s2) return -1;
    if(n>m) return 1;
    if (n<m) return -1;
    if(s1[0]>s2[0]) return 1;
    if(s1[0]<s2[0]) return -1;

    for(int i=1;i<n;i++)
     {

        if(s1[i]>s2[i]) return 1;
        else if(s1[i]<s2[i]) return -1;
            
     }
    return 0;
 }
string div(string dividend, string divisor)
{
    if(compare_string(dividend, divisor)==-1) return "0";

    int i=0;
    while(dividend[i]=='0')
    {
        i++;
    }
    dividend= dividend.substr(i);

    int j=0;
    while(divisor[j]=='0')
    {
        j++;
    }
    divisor = divisor.substr(j);

    int n = dividend.length();
    int count;
    string temp = "";
    string result;


    for(int i=0;i<n;i++)
    {
        int q=0;
        while(temp[q]=='0')
        {
            q++;
        }
        temp = temp.substr(q);
        count=0;
        temp += dividend[i];
        if(compare_string(divisor, temp)==-1)
        {
            while(compare_string(divisor, temp)==-1)
            {
                temp = sub(temp, divisor);
                count++;
            }
            //count++;
            result += to_string(count);
        }
        else
        {
            result += to_string(count);
        }

    }
    int q=0;
    while(temp[q]=='0')
    {
        q++;
    }
    temp = temp.substr(q);
    rem = temp;

    int k=0;
    while(result[k]=='0')
    {
        k++;
    }
    result = result.substr(k);
    return result; 
}

/*string exponent(string base, string power)
{
    if(power == "0") return "1";
    if(base == "1") return "1";
    string result=base;
    while(power != "1")
    {
        result = mul(result, base);
        power = sub(power, "1");
    }
    return result;
}*/

string exponent(string base, string power)
{
    if(power == "0") return "1";
    int n = power.length();
    //int check = power[n-1];
    string d = div(power, "2");
    if(rem == "0" || rem == " ")
        {
            return mul(exponent(base, div(power, "2")),  exponent(base, div(power, "2")));
        }
        else
        {
            return mul(base, exponent(base, sub(power, "1")));
        }
    
}

string gcd(string s1, string s2)
{
    int n = s1.length();
    int m = s2.length();
    string maxx;
    string minn;
    string result;


    if(m>n)
    {
        maxx = s2;
        minn = s1;
        
    }
    else 
    {
        maxx = s1;
        minn = s2;
    }
    string q = div(maxx, minn);
    string p;

    if(rem == "0" || rem == "") {
        return minn;
    }
    else
    {
        return gcd(minn, rem);
    }
}

bool isOperator(char c)
{
    return c == '+' || c == '-' || c == '/' || c == 'x';
}
string evaluation(string s)
{
    int n = s.length();
    int count=0;
    for(int i=0;i<n;i++)
    {
        if(isOperator(s[i]))
        {
            count++;
        }
    }

    count = 2*count+1;
    string arr[count];
    string result[count];
    string op[count];
    int q=0;
    for(int i=0; i<n; i++)
    {
        if(!isOperator(s[i]))
        {
            arr[q] += s[i];
        }
        //
        else {
            q++;
            arr[q] = s[i];
            q++;
        }
    }

    int times=0, k=0, l=0;
    string opnd[count];
    string optr[count];
    for(int i=0;i<count;i++)
    {
        if(arr[i] == "+" || arr[i] == "-" || arr[i] == "/" || arr[i] == "x")
        {
            optr[k] = arr[i];
            k++;
        }
        else
            {
                if(optr[k-1] == "x" || optr[k-1] == "/")
                {
                    opnd[l-1] = (optr[k-1] == "x")? mul(opnd[l-1], arr[i]) : div(opnd[l-1], arr[i]);
                    k--;
                }
                else
                {
                    opnd[l] = arr[i];
                    l++;

                }
            }
    }
    k=0;
    for(int i=1;i<l;i++)
    {
        opnd[i] = (optr[k] == "+")? add(opnd[i-1], opnd[i]) : sub(opnd[i-1], opnd[i]);
        k++;
    }

    return opnd[l-1];    
}


int main()
{
    string s1, s2, eval;
    int n;
    cin>>n;

    switch(n)
    {
        case 1:
            cin>>eval;
            cout<<evaluation(eval)<<endl;
            break;

        case 2:           
            cin>>s1>>s2;
            cout<<exponent(s1, s2)<<endl;
            break;
        
        case 3: 
            cin>>s1>>s2;
            cout<<gcd(s1, s2)<<endl;
            break;
        case 4:
            cin>>s1;
            cout<<fac(s1)<<endl;
            break;
        
        case 0:
            return 0;

        default:
            cout<<"jaldi yaha se hato"<<endl;
            break;
    }
    return 0;
}