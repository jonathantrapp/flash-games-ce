"""Host regressions for actual native enemy code and instrumented text buffers.

File/graphics hardware is stubbed. Enemy code is included unchanged. Text function
bodies are extracted unchanged except replacing each96-byte stack array with a
guarded backing buffer, so writes outside the original extent can be observed.
"""
from pathlib import Path
import json, os, re, subprocess, hashlib

HERE=Path(__file__).resolve().parent
GAME=HERE.parent
ROOT=GAME.parents[1]
stub=HERE/'stubs';stub.mkdir(exist_ok=True)
for name in ['tice.h','graphx.h','keypadc.h','fileioc.h']:
    if not (stub/name).exists():(stub/name).write_text('/* Host-only parity test hardware stub. */\n')

render=(GAME/'src/render.c').read_text()
def function(name):
    m=re.search(r'void '+name+r'\([^)]*\)\s*\{',render);start=m.start();end=m.end();depth=1
    while depth:depth+=(render[end]=='{')-(render[end]=='}');end+=1
    return render[start:end]
text_code='\n'.join(function(n) for n in ['print_fit','center_text','wrap_text'])
text_code=text_code.replace('char buffer[96] = {0};','char *buffer=(char *)buffer_guard+128;memset(buffer,0,96);').replace('char buffer[96];','char *buffer=(char *)buffer_guard+128;').replace('char line[96];','char *line=(char *)line_guard+128;')
text_code=text_code.replace('sizeof line','96').replace('sizeof buffer','96')
world=(GAME/'src/world.c').read_text()
m=re.search(r'void prop_update\(void\)\s*\{',world);start=m.start();end=m.end();depth=1
while depth:depth+=(world[end]=='{')-(world[end]=='}');end+=1
prop_code=world[start:end]
if 'static void tent_launch(' in world:
 m=re.search(r'static void tent_launch\([^)]*\)\s*\{',world);start=m.start();end=m.end();depth=1
 while depth:depth+=(world[end]=='{')-(world[end]=='}');end+=1
 prop_code=world[start:end]+'\n'+prop_code
stat_checks=[]
for cls,type_id in [('Yak',2),('Yak_Armor',16),('Yak_Archer',17),('FireMan',29),('Yak_Ninja',35),('Yak_Bruiser',38),('Yak_Big',39),('Yak_Master',40),('Yak_Archer_Elite',41),('Barrier_Orb',42),('Yakolyte',45),('Robot',46),('Iron_Priest',47)]:
    original=(GAME/('original/scripts/xplor/Monster/'+cls+'.as')).read_text()
    for field,native,scale in [('Life','original_life',100),('Money','original_xp',1)]:
        expr=re.search(r'function '+field+r'\([^)]*\)\s*:\s*int\s*\{\s*return ([^;]+);',original)[1]
        expr=re.sub(r'\blvl\b','0',expr)
        assert re.fullmatch(r'[\d+*/()\s.-]+',expr)
        expected=int(eval(expr,{'__builtins__':{}},{}))*scale
        stat_checks.append(f'result("{cls}_{field}",{native}({type_id}),{expected});')
source='''#include "../src/game.h"
static int parity_rand(void){return 99;}
#define rand parity_rand
#include "../src/enemies.c"
Game g; Progress progress;
static uint8_t fixture_map[19200];
static int story_calls,story_event,drop_calls,maxdepth,depth;
void __cyg_profile_func_enter(void *fn,void *caller) __attribute__((no_instrument_function));
void __cyg_profile_func_exit(void *fn,void *caller) __attribute__((no_instrument_function));
void __cyg_profile_func_enter(void *fn,void *caller){(void)caller;if(fn==(void *)&enemy_hit){depth++;if(depth>maxdepth)maxdepth=depth;}}
void __cyg_profile_func_exit(void *fn,void *caller){(void)caller;if(fn==(void *)&enemy_hit)depth--;}
int absi(int v){return v<0?-v:v;}
int clampi(int v,int lo,int hi){return v<lo?lo:v>hi?hi:v;}
int approach(int v,int target,int amount){return v<target?clampi(v+amount,v,target):clampi(v-amount,target,v);}
int tile_at(int x,int y){return x<0||y<0||x>=(int)g.w*16?1:y>=(int)g.h*16?0:g.solid[y/16*g.w+x/16];}
bool blocked(int x,int y){return tile_at(x,y)!=0;}
void profile_xp(int n){(void)n;}void add_fury(int n){(void)n;}int maxlife(void){return 500;}
int skill_damage(int t){(void)t;return 100;}
void drop_power(int a,int b,int c){(void)a;(void)b;(void)c;drop_calls++;}
void player_hurt(int a,int b,int c,int d){(void)a;(void)b;(void)c;(void)d;}
void story_start(int a,int b){(void)b;story_calls++;story_event=a;g.mode=DIALOGUE;}
void fire_shot(int a,int b,int c,int d,int e,int f,int h){(void)a;(void)b;(void)c;(void)d;(void)e;(void)f;(void)h;}
/* Aiming/projectile effects are outside this fixture's safety assertions;
 * check_combat.py links their real implementations instead. */
void combat_vector(int dx,int dy,int speed,int*vx,int*vy){(void)dx;(void)dy;(void)speed;*vx=*vy=0;}
void combat_angle(int angle,int speed,int*vx,int*vy){(void)angle;(void)speed;*vx=*vy=0;}
void fire_straight_arrow(int x,int y,int vx,int vy,int damage){(void)x;(void)y;(void)vx;(void)vy;(void)damage;}
void projectile_reset_stomp(void){}
void move_body(int*x,int*y,int*v,int dx,int bw,int bh,int*floor){(void)bw;(void)bh;*x+=dx;*y+=*v;*floor=1;*v=0;}
void collect_power(int w){(void)w;}
PROP_CODE
static unsigned char line_guard[4096],buffer_guard[4096];
static int text_oob,text_calls,text_width=3;
unsigned int gfx_GetStringWidth(const char*s){return (unsigned int)strlen(s)*text_width;}
void gfx_PrintStringXY(const char*s,int x,int y){text_calls++;if(x<0||y<0||x+(int)gfx_GetStringWidth(s)>320||y+8>240)text_oob++;}
TEXT_CODE
static void reset(void){memset(&g,0,sizeof g);memset(&progress,0,sizeof progress);memset(fixture_map,0,sizeof fixture_map);g.mode=PLAY;g.w=120;g.h=40;g.n=4800;g.back=fixture_map;g.solid=fixture_map+4800;g.decor=fixture_map+9600;g.good=fixture_map+14400;g.face=1;g.carry=-1;g.hp=500;g.px=200*16;g.py=200*16;story_calls=drop_calls=0;story_event=-1;}
static void result(const char*name,int actual,int expected){printf("R %s %d %d\\n",name,actual,expected);}
static int corrupted(const unsigned char*a){int n=0;for(int i=0;i<4096;i++)if((i<128||i>=224)&&a[i]!=0xa5)n++;return n;}
int main(void){
 STAT_CHECKS
 reset();g.level=8;Enemy*m=spawn_enemy(40,12,12,1);m->x=g.px;m->y=g.py;for(int f=0;f<120&&g.mode==PLAY;f++)enemy_update();result("nonfinal_master_starts_dialogue",story_calls,1);result("nonfinal_master_event",story_event,5);
 reset();g.level=2;g.props=1;g.prop[0]=(Prop){0};g.prop[0].type=43;g.prop[0].tag=1;g.prop[0].active=1;Enemy*o1=spawn_enemy(42,1,1,1);Enemy*o2=spawn_enemy(42,2,2,1);enemy_hit(o1,99999,0,0);result("barrier_survives_first_of_two_orbs",g.prop[0].active,1);enemy_hit(o2,99999,0,0);result("barrier_drops_after_last_orb",g.prop[0].active,0);
 reset();g.props=1;g.prop[0]=(Prop){0};g.prop[0].type=13;g.prop[0].tag=1;g.prop[0].active=1;g.solid[0]=56;Enemy*y=spawn_enemy(2,1,1,1);enemy_hit(y,99999,0,0);result("tag_gate_waits_for_tagged_tent",g.solid[0],56);
 reset();progress.skills[COMBOBOMBO]=5;for(int i=0;i<MAX_ENEMIES;i++){Enemy*e=spawn_enemy(2,10,10,0);e->hp=1;}maxdepth=depth=0;enemy_hit(&g.enemy[0],1000,0,0);int active=0;for(int i=0;i<MAX_ENEMIES;i++)active+=g.enemy[i].active;result("combo_chain_all_dead",active,0);result("combo_chain_each_killed_once",g.kills,MAX_ENEMIES);printf("O combo_recursion_depth %d\\n",maxdepth);
 reset();g.level=2;g.props=1;g.prop[0]=(Prop){200,200,0,13,2,0,0,1,1};prop_update();g.px=2000*16;for(int i=0;i<450;i++)prop_update();result("regular_tent_finishes_four_spawns_after_player_leaves",g.enemies,4);result("regular_tent_clears_tag_after_four_spawns",g.prop[0].tag,0);
 reset();g.level=7;g.props=1;g.prop[0]=(Prop){200,200,0,44,3,0,0,1,1};prop_update();g.px=2000*16;for(int i=0;i<450;i++)prop_update();result("grass_tent_finishes_six_spawns_after_player_leaves",g.enemies,6);result("grass_tent_clears_tag_after_six_spawns",g.prop[0].tag,0);
 reset();g.level=2;g.props=2;g.prop[0]=(Prop){200,200,0,13,2,0,0,1,1};g.prop[1]=(Prop){1800,200,0,14,2,0,0,1,-1};prop_update();result("stage_two_tents_awaken_together",g.enemies,2);
 memset(line_guard,0xa5,sizeof line_guard);memset(buffer_guard,0xa5,sizeof buffer_guard);char stress[500];for(int i=0;i<490;i++)stress[i]=i%11==10?' ':'i';stress[490]=0;text_oob=text_calls=0;wrap_text(8,20,304,stress,11);result("wrap_text_96byte_buffer_overwrite",corrupted(line_guard),0);result("print_fit_96byte_buffer_overwrite",corrupted(buffer_guard),0);
 memset(line_guard,0xa5,sizeof line_guard);memset(buffer_guard,0xa5,sizeof buffer_guard);text_oob=0;print_fit("longestword",-100,10);result("negative_text_origin_rejected",text_oob,0);
 return 0;
}
'''.replace('TEXT_CODE',text_code).replace('PROP_CODE',prop_code).replace('STAT_CHECKS','\n'.join(stat_checks))
(HERE/'runtime_safety_dump.c').write_text(source)
cache=HERE/'compiler-cache';cache.mkdir(exist_ok=True)
env=dict(os.environ,ZIG_LOCAL_CACHE_DIR=str(cache/'local'),ZIG_GLOBAL_CACHE_DIR=str(cache/'global'),TMP=str(cache),TEMP=str(cache))
subprocess.run([str(ROOT/'local-tools/ziglang/zig.exe'),'cc','-O1','-finstrument-functions','-I'+str(stub),str(HERE/'runtime_safety_dump.c'),'-o',str(HERE/'runtime_safety_dump.exe')],check=True,env=env)
run=subprocess.run([str(HERE/'runtime_safety_dump.exe')],capture_output=True,text=True,timeout=30)
tests=[];observations=[]
for line in run.stdout.splitlines():
 row=line.split()
 if row[0]=='R':tests.append(dict(name=row[1],actual=int(row[2]),expected=int(row[3]),passed=row[2]==row[3]))
 elif row[0]=='O':observations.append(dict(name=row[1],value=int(row[2])))
result=dict(tests=tests,observations=observations,returncode=run.returncode,stderr=run.stderr,
            source_sha256={name:hashlib.sha256((GAME/'src'/name).read_bytes()).hexdigest() for name in ['enemies.c','render.c','world.c','game.h']},
            limitations='Host32-bit int is wider than ez80int24. Enemy code unchanged with hardware stubs. Text96-byte arrays replaced by guarded larger backing buffers only; synthetic narrow-glyph input establishes potential memory overwrite, not proof of user crash trigger.')
(HERE/'runtime-safety-results.json').write_text(json.dumps(result,indent=2))
print(run.stdout);print(run.stderr);print(sum(t['passed'] for t in tests),'/',len(tests),'passed')
raise SystemExit(run.returncode or any(not t['passed'] for t in tests))
