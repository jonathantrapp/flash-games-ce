/* Generated directly from the supplied SWF AS3 formulas. */
#ifndef SCOUT_RULES_H
#define SCOUT_RULES_H
enum { SK_ROCKTOWER=0,SK_SLINGSHOT=1,SK_SOAPBOX=2,SK_HARDROCK=3,SK_FINISHHIM=4,SK_GATHEREDMOSS=5,SK_CONFUSION=6,SK_ENCOURAGEMENT=7,SK_BIGBUCKS=8,SK_SNOWFORT=9,SK_ICELAUNCHER=10,SK_SLUSHEE=11,SK_FROSTBITE=12,SK_REFRIGERATION=13,SK_BRAINFREEZE=14,SK_ICESHARDS=15,SK_BLUERAZZ=16,SK_CASHFLOW=17,SK_SHOCKER=18,SK_CRIPPLER=19,SK_LIGHTNINGROD=20,SK_CHAINLIGHTNING=21,SK_SHOCKTRAP=22,SK_ARCING=23,SK_MEGAWATT=24,SK_HEARTSTOPPER=25,SK_CONSTRUCTION=26,SK_ROLYPOLY=27,SK_CRUSHER=28,SK_QUAKE=29,SK_ROCKNROLL=30,SK_POISONTRAP=31,SK_ROLLBACK=32,SK_FLATTEN=33,SK_QUAKEUP=34,SK_ENHANCEMENT=35,SK_FIREPOWER=36,SK_EAGLEEYE=37,SK_RAPIDFIRE=38,SK_CRITICAL=39,SK_FREE_PEBBLES=40,SK_SHATTER=41,SK_SELL_TOWER=42,SK_CONDUCTANCE=43,SK_SHOCK_ROCK=44,SK_ROLLING_THUNDER=45,SK_BRITTLE_BONES=46,SK_ON_A_ROLL=47 };
typedef struct {const char *name;uint8_t group,rank,column,icon;} SkillRule;
static const SkillRule skillRules[]={
{"Rock Tower",0,0,0,SK_ROCKTOWER},
{"Big Bucks",0,0,2,SK_BIGBUCKS},
{"Slingshot",0,1,0,SK_SLINGSHOT},
{"Soapbox",0,1,2,SK_SOAPBOX},
{"Hard Rock",0,2,0,SK_HARDROCK},
{"Finish Him!",0,2,2,SK_FINISHHIM},
{"Gathered Moss",0,3,0,SK_GATHEREDMOSS},
{"Head Trauma",0,3,1,SK_CONFUSION},
{"Encouragement",0,3,2,SK_ENCOURAGEMENT},
{"Free Pebbles",0,4,0,SK_FREE_PEBBLES},
{"Firepower",0,4,1,SK_FIREPOWER},
{"Shatter",0,4,2,SK_SHATTER},
{"Snow Fort",1,0,0,SK_SNOWFORT},
{"Cash Flow",1,0,2,SK_CASHFLOW},
{"Ice Launcher",1,1,0,SK_ICELAUNCHER},
{"Slushee Maker",1,1,2,SK_SLUSHEE},
{"Frostbite",1,2,0,SK_FROSTBITE},
{"Refrigeration",1,2,2,SK_REFRIGERATION},
{"Brain Freeze",1,3,0,SK_BRAINFREEZE},
{"Ice Shards",1,3,1,SK_ICESHARDS},
{"Blue Raspberry",1,3,2,SK_BLUERAZZ},
{"Cold Hard Cash",1,4,0,SK_SELL_TOWER},
{"Eagle Eye",1,4,1,SK_EAGLEEYE},
{"Conductance",1,4,2,SK_CONDUCTANCE},
{"Shocker",2,0,0,SK_SHOCKER},
{"Construction",2,0,2,SK_CONSTRUCTION},
{"Crippler",2,1,0,SK_CRIPPLER},
{"Lightning Rod",2,1,2,SK_LIGHTNINGROD},
{"Chain Lightning",2,2,0,SK_CHAINLIGHTNING},
{"Shock Trap",2,2,2,SK_SHOCKTRAP},
{"Arcing",2,3,0,SK_ARCING},
{"Megawatt",2,3,1,SK_MEGAWATT},
{"Heartstopper",2,3,2,SK_HEARTSTOPPER},
{"Shock Rock",2,4,0,SK_SHOCK_ROCK},
{"Rapid Fire",2,4,1,SK_RAPIDFIRE},
{"Rolling Thunder",2,4,2,SK_ROLLING_THUNDER},
{"Roly Poly",3,0,0,SK_ROLYPOLY},
{"Enhancement",3,0,2,SK_ENHANCEMENT},
{"Crusher",3,1,0,SK_CRUSHER},
{"Quake-o-matic",3,1,2,SK_QUAKE},
{"Rock n' Roll",3,2,0,SK_ROCKNROLL},
{"Poison Trap",3,2,2,SK_POISONTRAP},
{"Rollback",3,3,0,SK_ROLLBACK},
{"Flatten",3,3,1,SK_FLATTEN},
{"Seismology",3,3,2,SK_QUAKEUP},
{"Brittle Bones",3,4,0,SK_BRITTLE_BONES},
{"Critical Strike",3,4,1,SK_CRITICAL},
{"On A Roll",3,4,2,SK_ON_A_ROLL},
};
extern uint8_t skills[48];
enum { ROCK,ROLL,SNOW,SHOCK,SLING,SOAPBOX,CRUSHER,QUAKE,ICE,SLUSHEE,CRIPPLER,LIGHTNING };
static const char *const towerNames[]={"Rock Tower","Roly Poly","Snow Fort","Shock Tower","Slingshot Tower","Soapbox","Crusher","Quake-O-Matic","Ice Launcher","Slushee Maker","Crippler","Lightning Rod"};
static float rule_DamageCalc(int type,int param1) { switch(type) {
case 0:return (5.5 + param1 * 2 + 0.5 * skills[SK_ROCKTOWER]) * (1 + skills[SK_HARDROCK] * 0.05 + skills[SK_FIREPOWER] * 0.02);
case 1:return (4 * param1 + 15) * (1 + skills[SK_HARDROCK] * 0.05 + skills[SK_FIREPOWER] * 0.02);
case 2:return 0.3 + param1 * 0.1;
case 3:return (4 * param1 + 5) * (1 + skills[SK_FIREPOWER] * 0.02);
case 4:return (7.5 * param1 + 20 + skills[SK_SLINGSHOT] * 3) * (1 + skills[SK_HARDROCK] * 0.05 + skills[SK_FIREPOWER] * 0.02);
case 5:return 2 * param1 + 15 + skills[SK_SOAPBOX] * 2;
case 6:return (8 * param1 + 15) * (1 + skills[SK_HARDROCK] * 0.05 + skills[SK_FIREPOWER] * 0.02);
case 7:return (3 + 1 * param1) * (1 + skills[SK_FIREPOWER] * 0.02);
case 8:return (1 + param1 + skills[SK_ICESHARDS] * 2) * (1 + skills[SK_FIREPOWER] * 0.02);
case 9:return 0.25 + skills[SK_SLUSHEE] * 0.05;
case 10:return 25 + 5 * skills[SK_CRIPPLER];
case 11:return (skills[SK_LIGHTNINGROD] * 15 + 35 + 10 * param1) * (1 + skills[SK_FIREPOWER] * 0.02);
default:return 0;} }
static float rule_RangeCalc(int type,int param1) { switch(type) {
case 0:return (int)((60 + param1 * 15) * (1 + skills[SK_EAGLEEYE] * 0.02));
case 1:return (int)((25 + param1 * 10) * (1 + skills[SK_EAGLEEYE] * 0.02));
case 2:return (int)((70 + param1 * 10) * (1 + skills[SK_EAGLEEYE] * 0.02));
case 3:return (int)((50 + param1 * 15) * (1 + skills[SK_EAGLEEYE] * 0.02));
case 4:return (int)((120 + param1 * 30) * (1 + skills[SK_EAGLEEYE] * 0.02));
case 5:return (int)((20 + param1 * 10) * (1 + skills[SK_EAGLEEYE] * 0.02));
case 6:return (int)(0);
case 7:return (int)((16 + 4.8 * skills[SK_QUAKE]) * (1 + skills[SK_EAGLEEYE] * 0.02));
case 8:return (int)((70 + param1 * 10) * (1 + skills[SK_EAGLEEYE] * 0.02));
case 9:return (int)(10);
case 10:return (int)((20 + param1 * 20) * (1 + skills[SK_EAGLEEYE] * 0.02));
case 11:return (int)(0);
default:return 0;} }
static float rule_ReloadCalc(int type,int param1) { switch(type) {
case 0:return (2 - 0.3 * param1) * (1 - skills[SK_RAPIDFIRE] * 0.02);
case 1:return (5 - 0.4 * param1) * (1 - skills[SK_RAPIDFIRE] * 0.02 - skills[SK_ROCKNROLL] * 0.05);
case 2:return (1.5 - 0.2 * param1) * (1 - skills[SK_RAPIDFIRE] * 0.02);
case 3:return (3 - 0.25 * param1) * (1 - skills[SK_RAPIDFIRE] * 0.02);
case 4:return (6 - 0.6 * param1) * (1 - skills[SK_RAPIDFIRE] * 0.02);
case 5:return 0.5;
case 6:return (3.75 - 0.25 * skills[SK_CRUSHER]) * (1 - skills[SK_RAPIDFIRE] * 0.02 - skills[SK_ROCKNROLL] * 0.05);
case 7:return (1.6 - param1 * 0.13) * (1 - skills[SK_RAPIDFIRE] * 0.02 - skills[SK_ROCKNROLL] * 0.05);
case 8:return (2 - 0.3 * param1) * (1 - skills[SK_RAPIDFIRE] * 0.02);
case 9:return (4 - 0.4 * param1) * (1 - skills[SK_RAPIDFIRE] * 0.02);
case 10:return 0;
case 11:return (7 - param1 * 0.5) * (1 - skills[SK_RAPIDFIRE] * 0.02);
default:return 0;} }
static float rule_SecondCalc(int type,int param1) { switch(type) {
case 0:return 1;
case 1:return skills[SK_ROLYPOLY] + 5;
case 2:return 3 + skills[SK_SNOWFORT] * 1;
case 3:return (int)(1 + param1 * 1);
case 4:return 1;
case 5:return 1;
case 6:return skills[SK_ROLYPOLY] * 2;
case 7:return (int)(0);
case 8:return 0.25 + skills[SK_ICELAUNCHER] * 0.25;
case 9:return 1.5 + param1 * 1.5;
case 10:return (int)(0);
case 11:return (int)(0);
default:return 0;} }
static float rule_UpgradePrice(int type,int param1) { switch(type) {
case 0:return (int)((param1 + 1) * (param1 + 1) * (param1 + 1) * 7 + 60);
case 1:return (int)((param1 + 1) * (param1 + 1) * (param1 + 1) * 8 + 100);
case 2:return (int)((param1 + 1) * (param1 + 1) * (param1 + 1) * 7 + 70);
case 3:return (int)((param1 + 1) * (param1 + 1) * (param1 + 1) * 7 + 80);
case 4:return (int)(rule_UpgradePrice(0,param1));
case 5:return (int)(rule_UpgradePrice(0,param1));
case 6:return (int)(rule_UpgradePrice(1,param1));
case 7:return (int)(rule_UpgradePrice(1,param1));
case 8:return (int)(rule_UpgradePrice(2,param1));
case 9:return (int)(rule_UpgradePrice(2,param1));
case 10:return (int)(rule_UpgradePrice(3,param1));
case 11:return (int)(rule_UpgradePrice(3,param1));
default:return 0;} }
static float rule_BasePrice(int type,int param1) { switch(type) {
case 0:return (int)(50 * (1 - skills[SK_CONSTRUCTION] * 0.04));
case 1:return (int)(100 * (1 - skills[SK_CONSTRUCTION] * 0.04));
case 2:return (int)(60 * (1 - skills[SK_CONSTRUCTION] * 0.04));
case 3:return (int)(80 * (1 - skills[SK_CONSTRUCTION] * 0.04));
case 4:return (int)(150 * (1 - skills[SK_CONSTRUCTION] * 0.04));
case 5:return (int)(200 * (1 - skills[SK_CONSTRUCTION] * 0.04));
case 6:return (int)(100 * (1 - skills[SK_CONSTRUCTION] * 0.04));
case 7:return (int)(100 * (1 - skills[SK_CONSTRUCTION] * 0.04));
case 8:return (int)(100 * (1 - skills[SK_CONSTRUCTION] * 0.04));
case 9:return (int)(70 * (1 - skills[SK_CONSTRUCTION] * 0.04));
case 10:return (int)(120 * (1 - skills[SK_CONSTRUCTION] * 0.04));
case 11:return (int)(100 * (1 - skills[SK_CONSTRUCTION] * 0.04));
default:return 0;} }
static int monster_Life(int type,int param1) {switch(type){
case 0:return 3 + param1 * 2;
case 1:return 1 + param1 * 1;
case 2:return 15 + param1 * 6;
case 3:return 100 + param1 * 30;
case 4:return 3 + param1 * 1.8;
case 5:return 3 + param1 * 2;
case 6:return 3 + param1 * 2;
case 7:return 3 + param1 * 2;
case 8:return 250 + param1 * 90;
case 9:return 5 + param1 * 1;
default:return 0;} }
static int monster_Money(int type,int param1) {switch(type){
case 0:return 5 + param1 * 0.75;
case 1:return 1 + param1 * 0.25;
case 2:return 10 + param1 * 1.5;
case 3:return 50 + param1 * 5;
case 4:return 5 + param1 * 1.1;
case 5:return 10 + param1 * 1.5;
case 6:return 5 + param1 * 0.75;
case 7:return 5 + param1 * 0.75;
case 8:return 100 + param1 * 20;
case 9:return 1 + param1 * 0.25;
default:return 0;} }
static const uint8_t monsterSpeed[]={20,40,15,10,20,40,20,20,2,35};
static const uint8_t monsterHeight[]={16,13,14,14,14,13,16,14,14,13};
#endif