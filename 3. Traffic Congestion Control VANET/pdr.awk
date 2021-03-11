BEGIN {
i=0
tm=2.21
}


{
if(FILENAME=="des_X_Y")
{ 
  desX=$1
  desY=$2
}

if(FILENAME=="sou-des")
{ 
  s=$1
  d=$2
}

if(FILENAME=="pdr.xg")
 {
    if(($1<100 && $1>-1) && ($2<100 && $2>-1))
    {         
       n[i,1]=$1
       n[i,2]=$2
       n[i,3]=$3
       n[i,4]=$4
       i++;
    } 
 }
}

END {
so=s;
min=10000;
print s > "path2"
while(so!=d)
{
 for(h=0;h<i;h++)
 {
   if(so==n[h,1])
   {
    dis=sqrt( ((desX-n[h,3])*(desX-n[h,3]))+ ( (desY-n[h,4])*(desY-n[h,4]) ) )
     if(dis<min)
     {
      min=dis;
      node=n[h,2];
     }
   }
 }
print node > "path2"
so=node
}
}

