#ifndef SCOUT_COMBAT_H
#define SCOUT_COMBAT_H
static int isqrt(int value){unsigned n=value,r=0,bit=1u<<22;while(bit>n)bit>>=2;while(bit){if(n>=r+bit){n-=r+bit;r=(r>>1)+bit;}else r>>=1;bit>>=2;}return r;}
static void freezeEnemy(Enemy*e,int time){if(!e->freeze)e->freeze=(e->type==3||e->type==8)?time/2:time;}
static void createBullet(Tower*t,Enemy*target) {
    for(int i=0;i<MAXBULLET;i++)if(!bullets[i].active) {
        Bullet*b=&bullets[i];memset(b,0,sizeof *b);b->active=1;if(i>=bulletTop)bulletTop=i+1;b->type=t->type;
        b->target=target?target-enemies:-1;b->x=(t->cell%mapWidth*16+8)*FP;b->y=(t->cell/mapWidth*16+8)*FP;
        b->damage=t->damage*t->buff/100;b->power=t->second;b->remaining=t->range*FP;
        if(t->type==ROLL){b->vx=t->facing*60*FP;b->remaining=t->second*16*FP/HZ;b->airSkip=5;}
        else if(t->type==CRUSHER){b->vx=(rand()%21-10)*FP;b->vy=0;b->remaining=0x7fffff;b->airSkip=5;}
        else if(t->type==SLUSHEE){b->vx=(rand()%11-5)*FP;b->vy=150*FP;b->remaining=0x7fffff;b->y+=12*FP;b->x+=(rand()%16-8)*FP;}
        else if(target){int speed=t->type==SLING?200:t->type==ICE?180:160;int dx=ex(target)-b->x_pixel,dy=ey(target)-b->y_pixel,len=isqrt(dx*dx+dy*dy);if(!len)len=1;
            b->vx=(int32_t)dx*speed*FP/len;b->vy=(int32_t)dy*speed*FP/len;
            if(t->type==SLING||t->type==ICE)b->remaining=0x7fffff;
            if(t->type==ROCK&&skills[SK_SHOCK_ROCK])for(int j=0;j<MAXTOWER;j++){Tower*n=&towers[j];if(n->active&&n->type==SHOCK&&squareDistance(t->cell%mapWidth*16+8,t->cell/mapWidth*16+8,n->cell%mapWidth*16+8,n->cell/mapWidth*16+8)<361){int power=n->damage*n->buff/100;if(power>b->shockPower)b->shockPower=power;}}
            b->shockPower=b->shockPower*skills[SK_SHOCK_ROCK]*7/100;
        }
        return;
    }
}
static void projectileHit(Bullet*b,Enemy*e){int damage=b->damage;
    if((b->type==ROCK||b->type==SLING)&&(e->freeze||e->slow))damage=damage*(100+skills[SK_SHATTER]*5)/100;
    if((b->type==ROLL||b->type==CRUSHER)&&(e->freeze||e->slow))damage=damage*(100+skills[SK_BRITTLE_BONES]*5)/100;
    if(b->type==SNOW){slowEnemy(e,b->power,b->damage,random100()<skills[SK_BRAINFREEZE]*8);return;}
    if(b->type==SLUSHEE){if(!e->slow&&skills[SK_BLUERAZZ])freezeEnemy(e,skills[SK_BLUERAZZ]*HZ/10);slowEnemy(e,b->power,b->damage,false);return;}
    if(b->type==ICE&&e->shock)damage=damage*(100+skills[SK_CONDUCTANCE]*5)/100;
    damageEnemy(e,damage,true);if(!e->active)return;
    if(b->type==ROCK){if(skills[SK_GATHEREDMOSS]){e->poison=201;e->poisonTick=0;}if(b->shockPower)shockEnemy(e,skills[SK_SHOCKER]*2*HZ,b->shockPower);}
    if(b->type==SLING&&e->type!=8&&random100()<skills[SK_CONFUSION]*2)e->facing=-e->facing;
    if(b->type==ICE)freezeEnemy(e,b->power);
    if(b->type==ROLL&&e->type!=8&&random100()<skills[SK_ROLLBACK]*10&&((b->vx<0?-1:1)!=e->facing)){e->fling=10;e->vx=(b->vx<0?-70:70)*FP;if(e->type==3)e->vx/=2;e->vy=-25*FP;e->action=1;e->ground=0;}
    if(b->type==CRUSHER&&e->type!=8)e->flat=skills[SK_FLATTEN]*HZ/5/(e->type==3?2:1);
}
static bool bulletOverlap(const Bullet*b,const Enemy*e) {
    int width=b->type==ROLL||b->type==CRUSHER?12:b->type==ICE?13:b->type==SLING?8:b->type==SLUSHEE?9:5;
    int height=b->type==ROLL||b->type==CRUSHER?12:b->type==ICE||b->type==SLING?8:5;
    return abs(b->x_pixel-ex(e))*2<width+5&&b->y_pixel-height/2<e->y_pixel&&b->y_pixel+height/2>e->y_pixel-monsterHeight[e->type];
}
static void stepBullets(void) {
    for(int i=0;i<bulletTop;i++) {
        Bullet*b=&bullets[i];if(!b->active)continue;
        if(b->pop){if(++b->pop>(b->type==ROLL||b->type==CRUSHER?7:4))b->active=0;continue;}
        b->age++;if(b->airSkip)b->airSkip--;
        if((b->type==ROLL||b->type==CRUSHER)&&skills[SK_FREE_PEBBLES])for(int j=0;j<MAXTOWER;j++) {
            Tower*t=&towers[j];
            if(t->active&&t->type==SLING&&t->cooldown&&!t->instaLock&&squareDistance(b->x_pixel,b->y_pixel,t->cell%mapWidth*16+8,t->cell/mapWidth*16+8)<64){t->cooldown=0;t->instaLock=(10-skills[SK_FREE_PEBBLES])*HZ;}
        }
        for(int sub=0;sub<3&&b->active&&!b->pop;sub++) {
            if(b->type==SLING||b->type==ICE) {
                if(b->target<0||!enemies[b->target].active||enemies[b->target].immune){b->pop=1;break;}
                Enemy*e=&enemies[b->target];int dx=ex(e)-b->x_pixel,dy=ey(e)-b->y_pixel,len=isqrt(dx*dx+dy*dy);if(!len)len=1;int speed=b->type==ICE?180:200;
                b->vx=(int32_t)dx*speed*FP/len;b->vy=(int32_t)dy*speed*FP/len;
            }
            int oldx=b->x,oldy=b->y,oldVelocity=b->vy;b->x+=b->vx/60;
            if(b->type==ROLL)b->vy+=200*FP/60;else if(b->type==CRUSHER){b->vy+=350*FP/60;if(b->vy>250*FP)b->vy=250*FP;}
            b->y+=(oldVelocity+b->vy)/120;
            b->remaining-=abs(b->x-oldx)+abs(b->y-oldy);
            if(b->type==ROLL) {
                int x=b->x_pixel,y=b->y_pixel,surf=surface(x,y+6);
                if(surf<=y+6&&surf>oldy/FP-10){b->y=(surf-6)*FP;b->vy=0;}
                if(!b->airSkip&&tileAt(1,x/16,y/16)&&!slope(tileAt(1,x/16,y/16)))b->pop=1;
            }else if(b->type==CRUSHER) {
                if(!b->airSkip){int tile=tileAt(1,b->x_pixel/16,b->y_pixel/16);if(b->inAir&&tile){b->vy=-30*FP;b->vx=(rand()%21-10)*FP;b->inAir=0;b->airSkip=5;}else if(!b->inAir&&!tile){b->inAir=1;b->airSkip=5;}}
            }
            if(b->type==ROLL||b->type==CRUSHER||b->type==SLUSHEE) {
                for(int j=0;j<enemyTop;j++){Enemy*e=&enemies[j];if(!e->active||e->immune||(b->victims[j/8]&(1<<(j%8))))continue;if(bulletOverlap(b,e)){projectileHit(b,e);if(b->type!=SLUSHEE)b->victims[j/8]|=1<<(j%8);}}
            }else if(b->target>=0) {
                Enemy*e=&enemies[b->target];if(!e->active){b->pop=1;break;}
                if(bulletOverlap(b,e)){if(!e->immune||b->type==SNOW)projectileHit(b,e);b->pop=1;}
            }
            if(b->remaining<0){b->pop=1;}
            if(b->y_pixel>mapHeight*16+16||b->y_pixel< -16||b->x_pixel< -16||b->x_pixel>mapWidth*16+16)b->active=0;
        }
    }
}
/* FindTarget parameters differ by tower in the original. Focus has priority
 * only for a valid target; FindBelow towers intentionally ignore focus. */
static bool targetAllowed(const Tower*t,const Enemy*e,int x,int y,bool allowShocked){
    if(!e->active||e->born||e->hp<=0)return false;
    if(e->immune&&t->type!=SNOW&&t->type!=CRIPPLER)return false;
    if((t->type==ICE||t->type==SNOW)&&e->freeze)return false;
    if(t->type==SNOW&&e->slow)return false;
    if(t->type==SHOCK&&e->shock&&!allowShocked)return false;
    if(t->type==CRIPPLER&&e->crippled)return false;
    if(t->type==CRUSHER||t->type==SLUSHEE)return ey(e)>y&&abs(ex(e)+e->vx/FP*(ey(e)-y)/(t->type==CRUSHER?200:150)-x)<10;
    if(t->type==LIGHTNING)return ey(e)<y&&abs(ex(e)-x)<13;
    return squareDistance(x,y,ex(e),ey(e))<=t->range*t->range&&(t->type==SLING||t->type==CRIPPLER||lineClear(x,y,ex(e),ey(e)));
}
static Enemy* findTarget(const Tower*t,int x,int y,bool allowShocked){
    if(t->type!=CRUSHER&&t->type!=SLUSHEE&&t->type!=LIGHTNING&&focusEnemy>=0&&focusEnemy<MAXEN&&targetAllowed(t,&enemies[focusEnemy],x,y,allowShocked))return &enemies[focusEnemy];
    Enemy*target=NULL;
    for(int j=0;j<enemyTop;j++){Enemy*e=&enemies[j];if(!targetAllowed(t,e,x,y,allowShocked))continue;if(t->type==CRUSHER||t->type==SLUSHEE||t->type==LIGHTNING)return e;if(!target||(e->escaping&&!target->escaping)||e->traveled>target->traveled)target=e;}
    if(!target&&t->type==SHOCK&&!allowShocked)return findTarget(t,x,y,true);
    return target;
}
static int focusAt(int x,int y){int best=-1,dist=24*24;for(int i=0;i<enemyTop;i++){Enemy*e=&enemies[i];if(e->active&&e->hp>0){int d=squareDistance(x,y,ex(e),ey(e));if(d<dist){best=i;dist=d;}}}focusEnemy=best;return best;}
static void stepTowers(void){for(int i=0;i<MAXTOWER;i++){Tower*t=&towers[i];if(!t->active)continue;if(t->buildTime)t->buildTime--;if(t->born){t->born--;continue;}if(t->animation)t->animation--;if(t->buffTime)t->buffTime--;else t->buff=100;if(t->instaLock)t->instaLock--;int x=t->cell%map->width*16+8,y=t->cell/map->width*16+8;
    if(skills[SK_SHOCKTRAP]&&tick%20==0){for(int j=0;j<enemyTop;j++){Enemy*e=&enemies[j];if(e->active&&squareDistance(x,y,ex(e),ey(e))<64)damageEnemy(e,skills[SK_SHOCKTRAP]*100,true);}}
    if(t->noFire){t->noFire--;continue;}
    if(t->cooldown)t->cooldown--;if(t->cooldown)continue;
    if(t->type==SOAPBOX){for(int j=0;j<MAXTOWER;j++){Tower*n=&towers[j];if(n->active&&n!=t&&squareDistance(x,y,n->cell%map->width*16+8,n->cell/map->width*16+8)<=t->range*t->range){n->buff=100+t->damage/100;n->buffTime=14;}}t->cooldown=t->reloadTime;continue;}
    if(t->type==QUAKE){for(int j=0;j<enemyTop;j++){Enemy*e=&enemies[j];if(e->active&&!e->immune&&abs(ey(e)-y)<32&&squareDistance(x,y,ex(e),ey(e))<t->range*t->range){int damage=t->damage*t->buff/100;if(e->freeze||e->slow)damage=damage*(100+skills[SK_BRITTLE_BONES]*5)/100;if(random100()<skills[SK_QUAKEUP]*3)damage*=2;damageEnemy(e,damage,true);}}if(skills[SK_ROLLING_THUNDER])for(int j=0;j<MAXTOWER;j++){Tower*n=&towers[j];if(n->active&&n->type==LIGHTNING&&n->cooldown&&squareDistance(x,y,n->cell%map->width*16+8,n->cell/map->width*16+8)<t->range*t->range){int reduction=skills[SK_ROLLING_THUNDER];n->cooldown=n->cooldown>reduction?n->cooldown-reduction:0;}}t->cooldown=t->reloadTime;t->animation=8;continue;}
    Enemy*target=findTarget(t,x,y,false);
    if(!target)continue;t->facing=ex(target)<x?-1:1;t->animation=10;
    if(t->type==SHOCK){shockEnemy(target,60+skills[SK_SHOCKER]*10,t->damage*t->buff/400);damageEnemy(target,t->damage*t->buff/100,true);chain(target,x,y);}
    else if(t->type==CRIPPLER){target->crippled=target->disabled=10;if(tick%40==0)chain(target,x,y);}
    else if(t->type==LIGHTNING){for(int j=0;j<enemyTop;j++){Enemy*e=&enemies[j];if(e->active&&!e->immune&&ey(e)<y&&abs(ex(e)-x)<13){if(random100()<skills[SK_HEARTSTOPPER]*2)e->hp=1;damageEnemy(e,t->damage*t->buff/100,true);}}chain(target,x,y);}
    else createBullet(t,target);
    t->cooldown=t->type==CRIPPLER?8:t->reloadTime;
    if(t->type==SLUSHEE){/* Original spray continues throughout seven firing frames. */t->animation=14;}
}}
static void stepSprays(void){for(int i=0;i<MAXTOWER;i++){Tower*t=&towers[i];if(t->active&&t->type==SLUSHEE&&t->animation)createBullet(t,NULL);}}
static void sendWave(void){if(wave<waveCounts[level])sendFast=true;}
static void startLevel(void){focusEnemy=-1;speedThirds=previousSpeedThirds=3;map=maps[level];mapWidth=map->width;mapHeight=map->height;campTileX=map->camp%mapWidth;campTileY=map->camp/mapWidth;for(int y=0;y<mapHeight;y++)rowOffsets[y]=y*mapWidth;const uint8_t*p=art_map_data()+map->rleOffset;int n=map->width*map->height;for(int l=0;l<4;l++){int k=0;while(k<n){int count=*p++,v=*p++;while(count--)layers[l][k++]=v;}}int theme=level==16?2:level>11?3:level>7?2:level>3?1:0;art_cache_level(layers[0],layers[1],layers[2],n,ART_TILES0+theme);memset(enemies,0,sizeof enemies);enemyTop=0;memset(towers,0,sizeof towers);memset(bullets,0,sizeof bullets);bulletTop=0;memset(spawners,0,sizeof spawners);for(int i=0;i<24;i++)waveDue[i]=waveTimes[level]*HZ*(i+1);money=(120+level*20)*(100+skills[SK_BIGBUCKS]*10)/100;wave=escaped=0;explosionRead=explosionWrite=0;paused=sendFast=false;cx=map->routes[0].cells[0]%map->width+4;cy=map->routes[0].cells[0]/map->width;if(cx>map->width-2)cx=map->width-2;if(cx<1)cx=1;if(cy>map->height-2)cy=map->height-2;if(cy<1)cy=1;selection=0;mode=1;tick=0;int camp=map->camp;for(int i=0;i<5;i++)foods[i]=(Food){.x=(camp%map->width*16-16+i*8+8)*FP,.y=(camp/map->width*16+16)*FP,.vy=0,.holder=-1,.active=1};say("1-4 tower  2nd build  GRAPH wave");}
static void stepWaves(void){for(int i=0;i<waveCounts[level];i++){if(waveDue[i]>0){waveDue[i]-=sendFast?HZ:1;if(waveDue[i]<=0){spawners[i].active=1;spawners[i].count=waveSets[level][i].groups[0];wave++;if(sendFast){money+=(wave+1)*skills[SK_ON_A_ROLL]*2;sendFast=false;}}}Spawner*s=&spawners[i];if(!s->active)continue;if(s->timer){s->timer--;continue;}const Wave*w=&waveSets[level][i];const uint16_t*g=w->groups+s->group*3;int portal=map->routes[rand()%map->routeCount].cells[0];/* Original active-wave level reduces to stage*3 + waveIndex+1. */int lv=level*3+i+1-(level<4?level:0);if(spawnEnemy(g[1],lv,portal)){s->timer=g[2];if(--s->count==0){s->group++;if(s->group>=w->count)s->active=0;else s->count=w->groups[s->group*3];}}}}
#ifdef QA_PERF
/* Cumulative 32 kHz timer ticks per update() subsystem (perf builds only). */
volatile uint32_t scout_sim_ticks[8];static uint32_t simStamp;
#define SIM_MARK(i) do{uint32_t n_=timer_GetSafe(1,TIMER_UP);scout_sim_ticks[i]+=n_-simStamp;simStamp=n_;}while(0)
#define SIM_BEGIN() (simStamp=timer_GetSafe(1,TIMER_UP))
/* Splits slot 1 (enemies) into physics and specials; reads the same running stamp. */
volatile uint32_t scout_phys_ticks[2];
#define PHYS_MARK(i) do{uint32_t n_=timer_GetSafe(1,TIMER_UP);scout_phys_ticks[i]+=n_-simStamp;simStamp=n_;}while(0)
#else
#define SIM_MARK(i) ((void)0)
#define SIM_BEGIN() ((void)0)
#define PHYS_MARK(i) ((void)0)
#endif
static void update(void){if(paused)return;SIM_BEGIN();tick++;if(statusTicks)statusTicks--;stepWaves();SIM_MARK(0);for(int i=0;i<enemyTop;i++)if(enemies[i].active){for(int sub=0;sub<3;sub++)if(enemies[i].active)physicsEnemy(&enemies[i],sub);PHYS_MARK(0);if(enemies[i].active)stepSpecials(&enemies[i]);PHYS_MARK(1);}SIM_MARK(1);stepFood();SIM_MARK(2);stepTowers();SIM_MARK(3);stepSprays();SIM_MARK(4);stepBullets();SIM_MARK(5);resolveExplosions();SIM_MARK(6);if(foodLeft()==0){mode=3;save();return;}bool spawning=false;for(int i=0;i<waveCounts[level];i++)spawning|=spawners[i].active;while(enemyTop&&!enemies[enemyTop-1].active)enemyTop--;while(bulletTop&&!bullets[bulletTop-1].active)bulletTop--;SIM_MARK(7);if(wave==waveCounts[level]&&!spawning&&!alive()){mode=4;stageWon[level]=1;if(level+2>unlocked&&level<16)unlocked=level+2;save();}}
#endif
