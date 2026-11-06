#ifndef SCOUT_COMBAT_H
#define SCOUT_COMBAT_H
static int isqrt(int value){unsigned n=value,r=0,bit=1u<<22;while(bit>n)bit>>=2;while(bit){if(n>=r+bit){n-=r+bit;r=(r>>1)+bit;}else r>>=1;bit>>=2;}return r;}
static void freezeEnemy(Enemy*e,int time){if(!e->freeze)e->freeze=(e->type==3||e->type==8)?time/2:time;}
static void createBullet(Tower*t,Enemy*target){for(int i=0;i<MAXBULLET;i++)if(!bullets[i].active){Bullet*b=&bullets[i];memset(b,0,sizeof *b);b->active=1;b->type=t->type;b->target=target?target-enemies:-1;b->x=(t->cell%map->width*16+8)*FP;b->y=(t->cell/map->width*16+8)*FP;b->damage=t->damage*t->buff/100;b->power=t->second;b->remaining=t->range+80;
    if(t->type==ROLL){b->vx=t->facing*60*FP;b->remaining=t->second*16/HZ;}
    else if(t->type==CRUSHER){b->vx=0;b->vy=30*FP;b->remaining=map->height*16;}
    else if(t->type==SLUSHEE){b->vx=0;b->vy=150*FP;b->remaining=map->height*16;}
    else if(target){int dx=ex(target)-b->x/FP,dy=ey(target)-b->y/FP,len=isqrt(dx*dx+dy*dy);if(!len)len=1;b->vx=(int32_t)dx*160*FP/len;b->vy=(int32_t)dy*160*FP/len;}
    return;
}}
static void projectileHit(Bullet*b,Enemy*e){int damage=b->damage;
    if((b->type==ROCK||b->type==SLING)&&(e->freeze||e->slow))damage=damage*(100+skills[SK_SHATTER]*5)/100;
    if((b->type==ROLL||b->type==CRUSHER)&&(e->freeze||e->slow))damage=damage*(100+skills[SK_BRITTLE_BONES]*5)/100;
    if(b->type==SNOW){slowEnemy(e,b->power,b->damage,random100()<skills[SK_BRAINFREEZE]*8);return;}
    if(b->type==SLUSHEE){if(!e->slow&&skills[SK_BLUERAZZ])freezeEnemy(e,skills[SK_BLUERAZZ]*HZ/10);slowEnemy(e,b->power,b->damage,false);return;}
    if(b->type==ICE&&e->shock)damage=damage*(100+skills[SK_CONDUCTANCE]*5)/100;
    damageEnemy(e,damage,true);if(!e->active)return;
    if(b->type==ROCK){if(skills[SK_GATHEREDMOSS])e->poison=201;if(skills[SK_SHOCK_ROCK]){int shock=0;for(int j=0;j<MAXTOWER;j++){Tower*t=&towers[j];if(t->active&&(t->type==SHOCK||t->type==CRIPPLER||t->type==LIGHTNING)&&squareDistance(b->x/FP,b->y/FP,t->cell%map->width*16+8,t->cell/map->width*16+8)<1600)shock+=t->damage;}if(shock){e->shock=skills[SK_SHOCKER]*40;e->shockDamage=shock*skills[SK_SHOCK_ROCK]*7/100;}}}
    if(b->type==SLING&&e->type!=8&&random100()<skills[SK_CONFUSION]*2)e->facing=-e->facing;
    if(b->type==ICE)freezeEnemy(e,b->power);
    if(b->type==ROLL&&e->type!=8&&random100()<skills[SK_ROLLBACK]*10&&((b->vx<0?-1:1)!=e->facing)){e->fling=10;e->vx=(b->vx<0?-70:70)*FP;if(e->type==3)e->vx/=2;e->vy=-25*FP;e->action=1;e->ground=0;}
    if(b->type==CRUSHER&&e->type!=8)e->flat=skills[SK_FLATTEN]*HZ/5/(e->type==3?2:1);
}
static void stepBullets(void){for(int i=0;i<MAXBULLET;i++){Bullet*b=&bullets[i];if(!b->active)continue;if(b->pop){if(++b->pop>5)b->active=0;continue;}b->age++;
    if(b->type==SLING||b->type==ICE){if(b->target>=0&&enemies[b->target].active){Enemy*e=&enemies[b->target];int dx=ex(e)-b->x/FP,dy=ey(e)-b->y/FP,len=isqrt(dx*dx+dy*dy);if(!len)len=1;int speed=b->type==ICE?180:200;b->vx=(int32_t)dx*speed*FP/len;b->vy=(int32_t)dy*speed*FP/len;}else{b->pop=1;continue;}}
    if((b->type==ROLL||b->type==CRUSHER)&&skills[SK_FREE_PEBBLES])for(int j=0;j<MAXTOWER;j++) {
        Tower*t=&towers[j];
        if(t->active&&t->type==SLING&&t->cooldown&&!t->instaLock&&squareDistance(b->x/FP,b->y/FP,t->cell%map->width*16+8,t->cell/map->width*16+8)<64) {
            t->cooldown=0;t->instaLock=(10-skills[SK_FREE_PEBBLES])*HZ;
        }
    }
    int oldx=b->x,oldy=b->y;b->x+=b->vx/HZ;b->y+=b->vy/HZ;b->remaining-=isqrt(((b->x-oldx)/FP)*((b->x-oldx)/FP)+((b->y-oldy)/FP)*((b->y-oldy)/FP));
    if(b->type==ROLL||b->type==CRUSHER){b->vy+=200*FP/HZ;int x=b->x/FP,y=b->y/FP;int surf=surface(x,y+6);if(surf<=y+6&&surf>oldy/FP-10){if(b->type==ROLL){b->y=(surf-6)*FP;b->vy=0;}else{b->pop=1;}}if(tileAt(1,x/16,y/16)&&!slope(tileAt(1,x/16,y/16)))b->pop=1;}
    if(b->type==ROLL||b->type==CRUSHER||b->type==SLUSHEE){for(int j=0;j<MAXEN;j++){Enemy*e=&enemies[j];if(!e->active||e->immune||(b->victims[j/8]&(1<<(j%8))))continue;if(squareDistance(b->x/FP,b->y/FP,ex(e),ey(e))<(b->type==SLUSHEE?100:144)){projectileHit(b,e);if(b->type!=SLUSHEE)b->victims[j/8]|=1<<(j%8);}}}
    else if(b->target>=0){Enemy*e=&enemies[b->target];if(!e->active){b->pop=1;continue;}if(squareDistance(b->x/FP,b->y/FP,ex(e),ey(e))<100){if(!e->immune||b->type==SNOW)projectileHit(b,e);b->pop=1;}}
    if(b->remaining<0||b->y/FP>map->height*16||b->x/FP<0||b->x/FP>map->width*16)b->active=0;
}}
static void stepTowers(void){for(int i=0;i<MAXTOWER;i++){Tower*t=&towers[i];if(!t->active)continue;if(t->buildTime)t->buildTime--;if(t->born){t->born--;continue;}if(t->animation)t->animation--;if(t->buffTime)t->buffTime--;else t->buff=100;if(t->instaLock)t->instaLock--;int x=t->cell%map->width*16+8,y=t->cell/map->width*16+8;
    if(skills[SK_SHOCKTRAP]&&tick%20==0){for(int j=0;j<MAXEN;j++){Enemy*e=&enemies[j];if(e->active&&squareDistance(x,y,ex(e),ey(e))<64)damageEnemy(e,skills[SK_SHOCKTRAP]*100,true);}}
    if(t->noFire){t->noFire--;continue;}
    if(t->cooldown)t->cooldown--;if(t->cooldown)continue;
    if(t->type==SOAPBOX){for(int j=0;j<MAXTOWER;j++){Tower*n=&towers[j];if(n->active&&n!=t&&squareDistance(x,y,n->cell%map->width*16+8,n->cell/map->width*16+8)<=t->range*t->range){n->buff=100+t->damage/100;n->buffTime=14;}}t->cooldown=t->reloadTime;continue;}
    if(t->type==QUAKE){for(int j=0;j<MAXEN;j++){Enemy*e=&enemies[j];if(e->active&&!e->immune&&abs(ey(e)-y)<32&&squareDistance(x,y,ex(e),ey(e))<t->range*t->range){int damage=t->damage*t->buff/100;if(e->freeze||e->slow)damage=damage*(100+skills[SK_BRITTLE_BONES]*5)/100;if(random100()<skills[SK_QUAKEUP]*3)damage*=2;damageEnemy(e,damage,true);}}if(skills[SK_ROLLING_THUNDER])for(int j=0;j<MAXTOWER;j++){Tower*n=&towers[j];if(n->active&&n->type==LIGHTNING&&n->cooldown&&squareDistance(x,y,n->cell%map->width*16+8,n->cell/map->width*16+8)<t->range*t->range){int reduction=skills[SK_ROLLING_THUNDER];n->cooldown=n->cooldown>reduction?n->cooldown-reduction:0;}}t->cooldown=t->reloadTime;t->animation=8;continue;}
    Enemy*target=NULL;
    for(int j=0;j<MAXEN;j++){Enemy*e=&enemies[j];if(!e->active||e->born)continue;if(e->immune&&t->type!=SNOW&&t->type!=CRIPPLER)continue;if(t->type==ICE&&e->freeze)continue;if(t->type==SHOCK&&e->shock)continue;if(t->type==CRIPPLER&&e->crippled)continue;int dist=squareDistance(x,y,ex(e),ey(e));bool validTarget=false;
        if(t->type==CRUSHER||t->type==SLUSHEE)validTarget=ey(e)>y&&abs(ex(e)+e->vx/FP*(ey(e)-y)/(t->type==CRUSHER?200:150)-x)<10;
        else if(t->type==LIGHTNING)validTarget=ey(e)<y&&abs(ex(e)-x)<13;
        else validTarget=dist<=t->range*t->range&&(t->type==SLING||t->type==CRIPPLER||lineClear(x,y,ex(e),ey(e)));
        if(validTarget&&(!target||(e->escaping&&!target->escaping)||e->traveled>target->traveled))target=e;
    }
    if(!target)continue;t->facing=ex(target)<x?-1:1;t->animation=10;
    if(t->type==SHOCK){shockEnemy(target,60+skills[SK_SHOCKER]*10,t->damage*t->buff/400);damageEnemy(target,t->damage*t->buff/100,true);chain(target,x,y);}
    else if(t->type==CRIPPLER){target->crippled=target->disabled=10;if(tick%40==0)chain(target,x,y);}
    else if(t->type==LIGHTNING){for(int j=0;j<MAXEN;j++){Enemy*e=&enemies[j];if(e->active&&!e->immune&&ey(e)<y&&abs(ex(e)-x)<13){if(random100()<skills[SK_HEARTSTOPPER]*2)e->hp=1;damageEnemy(e,t->damage*t->buff/100,true);}}chain(target,x,y);}
    else createBullet(t,target);
    t->cooldown=t->type==CRIPPLER?8:t->reloadTime;
    if(t->type==SLUSHEE){/* Original spray continues throughout seven firing frames. */t->animation=14;}
}}
static void stepSprays(void){for(int i=0;i<MAXTOWER;i++){Tower*t=&towers[i];if(t->active&&t->type==SLUSHEE&&t->animation)createBullet(t,NULL);}}
static void sendWave(void){if(wave<waveCounts[level])sendFast=true;}
static void startLevel(void){map=maps[level];const uint8_t*p=art_map_data()+map->rleOffset;int n=map->width*map->height;for(int l=0;l<4;l++){int k=0;while(k<n){int count=*p++,v=*p++;while(count--)layers[l][k++]=v;}}int theme=level==16?2:level>11?3:level>7?2:level>3?1:0;art_cache_level(layers[0],layers[1],layers[2],n,ART_TILES0+theme);memset(enemies,0,sizeof enemies);memset(towers,0,sizeof towers);memset(bullets,0,sizeof bullets);memset(spawners,0,sizeof spawners);for(int i=0;i<24;i++)waveDue[i]=waveTimes[level]*HZ*(i+1);money=(120+level*20)*(100+skills[SK_BIGBUCKS]*10)/100;wave=escaped=0;explosionRead=explosionWrite=0;paused=sendFast=false;cx=map->routes[0].cells[0]%map->width+4;cy=map->routes[0].cells[0]/map->width;selection=0;mode=1;tick=0;int camp=map->camp;for(int i=0;i<5;i++)foods[i]=(Food){(camp%map->width*16-16+i*8+8)*FP,(camp/map->width*16+16)*FP,0,-1,1};say("1-4 tower  2nd build  + next wave");}
static void stepWaves(void){for(int i=0;i<waveCounts[level];i++){if(waveDue[i]>0){waveDue[i]-=sendFast?HZ:1;if(waveDue[i]<=0){spawners[i].active=1;spawners[i].count=waveSets[level][i].groups[0];wave++;if(sendFast){money+=(wave+1)*skills[SK_ON_A_ROLL]*2;sendFast=false;}}}Spawner*s=&spawners[i];if(!s->active)continue;if(s->timer){s->timer--;continue;}const Wave*w=&waveSets[level][i];const uint16_t*g=w->groups+s->group*3;int portal=map->routes[rand()%map->routeCount].cells[0];/* Original active-wave level reduces to stage*3 + waveIndex+1. */int lv=level*3+i+1-(level<4?level:0);if(spawnEnemy(g[1],lv,portal)){s->timer=g[2];if(--s->count==0){s->group++;if(s->group>=w->count)s->active=0;else s->count=w->groups[s->group*3];}}}}
static void update(void){if(paused)return;tick++;if(statusTicks)statusTicks--;stepWaves();for(int i=0;i<MAXEN;i++)if(enemies[i].active){for(int sub=0;sub<3;sub++)if(enemies[i].active)physicsEnemy(&enemies[i],sub);if(enemies[i].active)stepSpecials(&enemies[i]);}stepFood();stepTowers();stepSprays();stepBullets();resolveExplosions();if(foodLeft()==0){mode=3;save();return;}bool spawning=false;for(int i=0;i<waveCounts[level];i++)spawning|=spawners[i].active;if(wave==waveCounts[level]&&!spawning&&!alive()){mode=4;stageWon[level]=1;if(level+2>unlocked&&level<16)unlocked=level+2;save();}}
#endif
