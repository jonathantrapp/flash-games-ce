#include <stdint.h>
#include <stdio.h>
#include "../src/rules.h"
uint8_t skills[48];
int main(void) {
 for(int p=0;p<50;p++) {
  for(int s=0;s<48;s++) skills[s]=(p==1 || (p>=2 && s==p-2))?5:0;
  for(int t=0;t<12;t++)for(int l=0;l<6;l++) {
   printf("T %d %d %d %.9g %.9g %.9g %.9g %.9g %.9g\n",p,t,l,
     (double)rule_DamageCalc(t,l),(double)rule_RangeCalc(t,l),
     (double)rule_ReloadCalc(t,l),(double)rule_SecondCalc(t,l),
     (double)rule_UpgradePrice(t,l),(double)rule_BasePrice(t,l));
  }
 }
 for(int t=0;t<10;t++)for(int l=0;l<65;l++)
  printf("M %d %d %d %d %d\n",t,l,monster_Life(t,l),monster_Money(t,l),monsterSpeed[t]);
 return 0;
}
