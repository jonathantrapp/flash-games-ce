#include <tice.h>
#include <stdint.h>
#include <string.h>
void scout_unpack(void*,const uint8_t*,const uint8_t*);
volatile uint8_t unpack_diag[4];
static uint8_t input[1024],output[1026],expected[1024];
static int check(int in,int out){memset(output,0xa5,sizeof output);scout_unpack(output+1,input,input+in);if(output[0]!=0xa5||output[out+1]!=0xa5)return 1;return memcmp(output+1,expected,out)!=0;}
int main(void){
 for(int n=1;n<=128;n++){
  input[0]=n-1;for(int i=0;i<n;i++)expected[i]=input[i+1]=(i*7+n)&255;
  if(check(n+1,n)){unpack_diag[1]=n;unpack_diag[2]=1;goto failed;}
  input[0]=127+n;input[1]=n^85;memset(expected,input[1],n);
  if(check(2,n)){unpack_diag[1]=n;unpack_diag[2]=2;goto failed;}
 }
 for(int seed=1;seed<=100;seed++){
  unsigned state=seed;int in=0,out=0;
  while(out<950){state=state*109+89;int n=(state%17)+1;if(state&128){input[in++]=127+n;input[in++]=state&255;memset(expected+out,state&255,n);}else{input[in++]=n-1;for(int i=0;i<n;i++)expected[out+i]=input[in++]=(state+i)&255;}out+=n;}
  if(check(in,out)){unpack_diag[1]=seed;unpack_diag[2]=3;goto failed;}
 }
 unpack_diag[0]=1;unpack_diag[3]=100;os_ClrHome();os_PutStrFull("UNPACK PASS 356 cases");while(!os_GetCSC()){}return 0;
failed:unpack_diag[0]=2;os_ClrHome();os_PutStrFull("UNPACK FAILED");while(!os_GetCSC()){}return 1;
}
