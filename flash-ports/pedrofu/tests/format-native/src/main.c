#include <tice.h>
#include <graphx.h>
#include <keypadc.h>
#include <stdio.h>
#include <string.h>
volatile unsigned int format_diag[3];
#define CHECK(expected,fmt,...) do { \
 for(unsigned cap=0;cap<64;cap++){ \
  char buffer[80];memset(buffer,0x6b,sizeof buffer); \
  int n=snprintf(buffer+8,cap,fmt,__VA_ARGS__);unsigned length=strlen(expected); \
  bool bad=n!=(int)length; \
  for(unsigned i=0;i<80;i++){ \
   char wanted=0x6b;if(cap&&i>=8&&i<8+cap){unsigned p=i-8;if(p<cap-1&&p<length)wanted=expected[p];else if(p==(length<cap?length:cap-1))wanted=0;} \
   if(buffer[i]!=wanted)bad=true; \
  } \
  format_diag[1]++;format_diag[2]+=bad; \
 } }while(0)
int main(void){
 gfx_Begin();format_diag[0]=90;
 CHECK("-8388608","%d",(int)(-8388607-1));
 CHECK("8388607","%d",8388607);
 CHECK("16777215","%u",16777215U);
 CHECK("FFFFFF","%06X",16777215U);
 CHECK("D1A87E","%06X",0xD1A87EU);
 CHECK("4294967295","%lu",4294967295UL);
 CHECK("-7","%02d",-7);
 CHECK("07","%02d",7);
 CHECK("Pedro 100%","%s %d%%","Pedro",100);
 CHECK("0.05","%d.%02d",0,5);
 format_diag[0]=1;while(1){kb_Scan();}
}
