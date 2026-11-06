#include "game.h"
#include "dialogue_data.h"
void story_start(int event,int enemy){if(event<0||event>=12||(g.story_done&(1<<event)))return;g.story_event=event;g.story_page=0;g.story_enemy=enemy;g.story_done|=1<<event;g.mode=DIALOGUE;}
static void end_conversation(void){
 int ev=g.story_event;Enemy *e=g.story_enemy>=0&&g.story_enemy<g.enemies?&g.enemy[g.story_enemy]:NULL;
 if(ev==5&&e){Enemy *boss=spawn_enemy(39,e->x/16+7,e->y/16,e->tag);if(boss){boss->x=e->x+120*16;boss->y=e->y;boss->vy=-106;boss->vx=-42;boss->face=-1;boss->state=1;}e->active=0;for(int y=18;y<=24&&y<(int)g.h;y++){if(g.w>116){g.solid[y*g.w+97]=56;g.solid[y*g.w+116]=56;}}}
 if((ev==8||ev==9||ev==10)&&e)e->active=0;
 g.story_event=-1;g.mode=PLAY;
}
void story_update(void){if(g.tap&(HITKEY|FURYKEY|ACCEPT)){g.story_page++;if(g.story_page>=dialogue_lengths[g.story_event])end_conversation();}}
void story_draw(void){
 gfx_SetColor(cPanel);gfx_FillRectangle(14,37,292,117);gfx_SetColor(cWhite);gfx_Rectangle(14,37,292,117);gfx_SetTextFGColor(cWhite);wrap_text(23,47,274,dialogue_pages[g.story_event][g.story_page],11);gfx_SetTextFGColor(cYellow);center_text(163,"Alpha / Del / ENTER: continue");gfx_SetTextFGColor(cWhite);
}
void story_triggers(void){
 if(g.level==3&&g.px>37*16*16&&g.ground)story_start(3,-1);
 if(g.level==0){const char *tip=NULL;int x=g.px/16;if(x<300)tip="Arrows move. Up or 2nd jumps.";else if(x<700)tip="Alpha attacks. Alpha in the air kicks.";else if(x<1200)tip="Collect Ancient Techniques, then use STAT.";else if(x<1600)tip="Collect all the lost mail to finish.";else tip="MODE pauses. STAT opens your skills.";if(!g.notice_timer)notice(tip);}
 for(int i=0;i<g.enemies;i++){Enemy *e=&g.enemy[i];if(!e->active)continue;int distance=absi(e->x-g.px)+absi(e->y-g.py);
  if(g.level==1&&e->type==17&&distance<100*16&&e->tag)story_start(2,i);
  if(g.level==9&&e->type==17&&e->tag==2){if(!(g.story_done&(1<<6)))story_start(6,i);else if(g.py<=e->y+e->bh*16&&g.ground)story_start(7,i);}
 }
}
