#include "../src/game.h"
static int parity_rand(void){return 99;}
#define rand parity_rand
#include "../src/enemies.c"
Game g; Progress progress;
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
void move_body(int*x,int*y,int*v,int dx,int bw,int bh,int*floor){(void)bw;(void)bh;*x+=dx;*y+=*v;*floor=1;*v=0;}
void collect_power(int w){(void)w;}
static void tent_launch(Prop *p) {
 Enemy *e=spawn_enemy(2,p->x/16,p->y/16,p->tag);
 if(e){e->x+=(p->face>0?15:-4)*16;e->face=g.px<e->x?-1:1;e->reload=0;}
 if(g.level==0&&p->face>0&&!((g.story_done>>0)&1)){
  story_start(0,e?e-g.enemy:-1);
  for(int j=0;j<g.props;j++){Prop*q=&g.prop[j];if(q!=p&&q->active&&(q->type==13||q->type==14)&&q->state==0){q->state=2;tent_launch(q);}}
 }
}
void prop_update(void){
 for(int i=0;i<g.props;i++){Prop *p=&g.prop[i];if(!p->active)continue;int dist=absi(p->x-g.px/16)+absi(p->y-g.py/16);
  if(p->type==48){p->timer++;if(p->timer>15&&dist<24){collect_power(p->state);p->active=0;}continue;}
  if(p->type==13||p->type==14||p->type==44){
   if(!p->state&&dist<50){
    if(g.level==2||p->type==44){
     bool all=g.level==2||g.level==7;
     for(int j=0;j<g.props;j++){Prop*q=&g.prop[j];if(q->active&&!q->state&&(q==p||(all&&((p->type==44&&q->type==44)||(p->type!=44&&(q->type==13||q->type==14)))))){q->state=1;q->timer=0;q->count=0;}}
    }else{p->state=2;tent_launch(p);p->tag=0;}
   }
   if(p->state==1&&--p->timer<=0){tent_launch(p);p->count++;p->timer=(p->type==44?2:4)*FPS;if(p->count>=(p->type==44?6:4)){p->state=2;p->tag=0;}}
   continue;
  }
  if(p->type==43){if(absi(p->x+3-g.px/16-4)<10&&g.py/16+15>p->y-16&&g.py/16<p->y+16){int dir=g.px/16+4>p->x+3?1:-1;g.px=(p->x+(dir>0?12:-8))*16;player_hurt(100,dir,100,-100);}continue;}
 }
 int tx=(g.px/16+4)/16,ty=(g.py/16+8)/16;
 for(int y=ty-1;y<=ty+1;y++)for(int x=tx-1;x<=tx+1;x++)if(x>=0&&x<(int)g.w&&y>=0&&y<(int)g.h&&absi(x*16+8-g.px/16-4)+absi(y*16+8-g.py/16-8)<20){int i=y*g.w+x,t=g.good[i],which=-1;if(t==12)which=5;else if(t==6)which=0;else if(t>=7&&t<=9)which=t-6;else if(t==36)which=4;else if(t==37)which=6;if(which>=0){g.good[i]=0;collect_power(which);}}
}
static unsigned char line_guard[4096],buffer_guard[4096];
static int text_oob,text_calls,text_width=3;
unsigned int gfx_GetStringWidth(const char*s){return (unsigned int)strlen(s)*text_width;}
void gfx_PrintStringXY(const char*s,int x,int y){text_calls++;if(x<0||y<0||x+(int)gfx_GetStringWidth(s)>320||y+8>240)text_oob++;}
void print_fit(const char *s, int x, int y) {
    if (!s || y < 0 || y > 232 || x > 315) return;
    if (x < 0) x = 0;
    if (x + (int)gfx_GetStringWidth(s) <= 316) { gfx_PrintStringXY(s, x, y); return; }
    char *buffer=(char *)buffer_guard+128;memset(buffer,0,96); int n = 0;
    while (s[n] && n < 90) { buffer[n] = s[n]; buffer[n + 1] = 0; if (x + (int)gfx_GetStringWidth(buffer) > 316) { buffer[n] = 0; break; } n++; }
    gfx_PrintStringXY(buffer, x, y);
}
void center_text(int y, const char *s) { int w = gfx_GetStringWidth(s); print_fit(s, w >= 316 ? 2 : (320 - w) / 2, y); }
void wrap_text(int x, int y, int width, const char *s, int step) {
    char *line=(char *)line_guard+128; int n = 0;
    if (!s || width <= 0 || step <= 0) return;
    while (*s && y <= 232) {
        if (*s == '\n') { line[n] = 0; print_fit(line, x, y); n = 0; y += step; s++; continue; }
        if (*s == ' ') { if (n && n < 90) line[n++] = ' '; s++; continue; }
        int len = 0; while (s[len] && s[len] != ' ' && s[len] != '\n') len++;
        if (len > 40) len = 40;
        /* Check capacity before copying: a narrow-font line can contain many
         * characters even when it still fits the requested pixel width. */
        if (n + len >= (int)96) {
            line[n] = 0; print_fit(line, x, y); y += step; n = 0;
            if (y > 232) break;
        }
        memcpy(line + n, s, len); line[n + len] = 0;
        if (n && (int)gfx_GetStringWidth(line) > width) {
            while (n && line[n - 1] == ' ') n--;
            line[n] = 0; print_fit(line, x, y); y += step; memcpy(line, s, len); n = len; line[n] = 0;
        } else n += len;
        s += len;
    }
    line[n] = 0; if (n) print_fit(line, x, y);
}
static void reset(void){memset(&g,0,sizeof g);memset(&progress,0,sizeof progress);g.mode=PLAY;g.w=120;g.h=40;g.n=4800;g.back=g.mapdata;g.solid=g.mapdata+4800;g.decor=g.mapdata+9600;g.good=g.mapdata+14400;g.face=1;g.carry=-1;g.hp=500;g.px=200*16;g.py=200*16;story_calls=drop_calls=0;story_event=-1;}
static void result(const char*name,int actual,int expected){printf("R %s %d %d\n",name,actual,expected);}
static int corrupted(const unsigned char*a){int n=0;for(int i=0;i<4096;i++)if((i<128||i>=224)&&a[i]!=0xa5)n++;return n;}
int main(void){
 result("Yak_Life",original_life(2),500);
result("Yak_Money",original_xp(2),10);
result("Yak_Armor_Life",original_life(16),2000);
result("Yak_Armor_Money",original_xp(16),50);
result("Yak_Archer_Life",original_life(17),500);
result("Yak_Archer_Money",original_xp(17),10);
result("FireMan_Life",original_life(29),500);
result("FireMan_Money",original_xp(29),10);
result("Yak_Ninja_Life",original_life(35),2000);
result("Yak_Ninja_Money",original_xp(35),50);
result("Yak_Bruiser_Life",original_life(38),2000);
result("Yak_Bruiser_Money",original_xp(38),20);
result("Yak_Big_Life",original_life(39),20000);
result("Yak_Big_Money",original_xp(39),150);
result("Yak_Master_Life",original_life(40),15000);
result("Yak_Master_Money",original_xp(40),500);
result("Yak_Archer_Elite_Life",original_life(41),2000);
result("Yak_Archer_Elite_Money",original_xp(41),70);
result("Barrier_Orb_Life",original_life(42),2000);
result("Barrier_Orb_Money",original_xp(42),5);
result("Yakolyte_Life",original_life(45),3000);
result("Yakolyte_Money",original_xp(45),30);
result("Robot_Life",original_life(46),10000);
result("Robot_Money",original_xp(46),200);
result("Iron_Priest_Life",original_life(47),3000);
result("Iron_Priest_Money",original_xp(47),80);
 reset();g.level=8;Enemy*m=spawn_enemy(40,12,12,1);m->x=g.px;m->y=g.py;for(int f=0;f<120&&g.mode==PLAY;f++)enemy_update();result("nonfinal_master_starts_dialogue",story_calls,1);result("nonfinal_master_event",story_event,5);
 reset();g.level=2;g.props=1;g.prop[0]=(Prop){0};g.prop[0].type=43;g.prop[0].tag=1;g.prop[0].active=1;Enemy*o1=spawn_enemy(42,1,1,1);Enemy*o2=spawn_enemy(42,2,2,1);enemy_hit(o1,99999,0,0);result("barrier_survives_first_of_two_orbs",g.prop[0].active,1);enemy_hit(o2,99999,0,0);result("barrier_drops_after_last_orb",g.prop[0].active,0);
 reset();g.props=1;g.prop[0]=(Prop){0};g.prop[0].type=13;g.prop[0].tag=1;g.prop[0].active=1;g.solid[0]=56;Enemy*y=spawn_enemy(2,1,1,1);enemy_hit(y,99999,0,0);result("tag_gate_waits_for_tagged_tent",g.solid[0],56);
 reset();progress.skills[COMBOBOMBO]=5;for(int i=0;i<MAX_ENEMIES;i++){Enemy*e=spawn_enemy(2,10,10,0);e->hp=1;}maxdepth=depth=0;enemy_hit(&g.enemy[0],1000,0,0);int active=0;for(int i=0;i<MAX_ENEMIES;i++)active+=g.enemy[i].active;result("combo_chain_all_dead",active,0);result("combo_chain_each_killed_once",g.kills,MAX_ENEMIES);printf("O combo_recursion_depth %d\n",maxdepth);
 reset();g.level=2;g.props=1;g.prop[0]=(Prop){200,200,0,13,2,0,0,1,1};prop_update();g.px=2000*16;for(int i=0;i<450;i++)prop_update();result("regular_tent_finishes_four_spawns_after_player_leaves",g.enemies,4);result("regular_tent_clears_tag_after_four_spawns",g.prop[0].tag,0);
 reset();g.level=7;g.props=1;g.prop[0]=(Prop){200,200,0,44,3,0,0,1,1};prop_update();g.px=2000*16;for(int i=0;i<450;i++)prop_update();result("grass_tent_finishes_six_spawns_after_player_leaves",g.enemies,6);result("grass_tent_clears_tag_after_six_spawns",g.prop[0].tag,0);
 reset();g.level=2;g.props=2;g.prop[0]=(Prop){200,200,0,13,2,0,0,1,1};g.prop[1]=(Prop){1800,200,0,14,2,0,0,1,-1};prop_update();result("stage_two_tents_awaken_together",g.enemies,2);
 memset(line_guard,0xa5,sizeof line_guard);memset(buffer_guard,0xa5,sizeof buffer_guard);char stress[500];for(int i=0;i<490;i++)stress[i]=i%11==10?' ':'i';stress[490]=0;text_oob=text_calls=0;wrap_text(8,20,304,stress,11);result("wrap_text_96byte_buffer_overwrite",corrupted(line_guard),0);result("print_fit_96byte_buffer_overwrite",corrupted(buffer_guard),0);
 memset(line_guard,0xa5,sizeof line_guard);memset(buffer_guard,0xa5,sizeof buffer_guard);text_oob=0;print_fit("longestword",-100,10);result("negative_text_origin_rejected",text_oob,0);
 return 0;
}
