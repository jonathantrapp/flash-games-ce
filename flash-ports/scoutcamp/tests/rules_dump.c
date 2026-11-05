#include <stdint.h>
#include <stdio.h>
#include "../src/rules.h"
uint8_t skills[48];
static int skillNeeded(int idx){const SkillRule*r=&skillRules[idx];int id=r->icon;if((id==SK_LIGHTNINGROD||id==SK_CRIPPLER)&&!skills[SK_SHOCKER])return 999;if((id==SK_ICELAUNCHER||id==SK_SLUSHEE)&&!skills[SK_SNOWFORT])return 999;if((id==SK_CRUSHER||id==SK_QUAKE)&&!skills[SK_ROLYPOLY])return 999;int spent=0;for(int i=0;i<48;i++)if(skillRules[i].group==r->group&&skillRules[i].rank<r->rank)spent+=skills[skillRules[i].icon];return r->rank*3-spent;}
int main(void) {
 for(int p=0;p<246;p++) {
  for(int s=0;s<48;s++) skills[s]=p<6?p:((s==(p-6)/5)?(p-6)%5+1:0);
  for(int s=0;s<48;s++)printf("S %d %d %d\n",p,s,skillNeeded(s));
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
