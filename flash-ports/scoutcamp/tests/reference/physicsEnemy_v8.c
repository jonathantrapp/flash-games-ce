/* Frozen production v8 physics, including its coordinate caches and slope fixes. */
static void physicsEnemy(Enemy*e,int substep){
    if(e->born){if(!substep)e->born--;return;}
    if(!substep)stepStatus(e);if(!e->active)return;
    if(e->freeze){if(!substep)e->freeze--;return;}if(e->flat){if(!substep)e->flat--;return;}
    int h=monsterHeight[e->type],px=ex(e),feet=e->y_pixel,py=feet-h/2;
    int tilex=px/16,tiley=py/16;
    if(tilex==campTileX&&tiley==campTileY)e->advancing=0;
    if(tilex==e->homeX&&tiley==e->homeY){e->advancing=1;if(e->escaping){if(e->carry>=0){foods[e->carry].active=0;escaped++;}e->active=0;if(e-enemies==focusEnemy)focusEnemy=-1;return;}}
    int speed=e->speed;
    if(e->action==1)speed=35*FP;else if(e->boost&&e->type!=1&&e->type!=5)speed=40*FP;
    if(e->slow)speed=speed*e->slowRate/100;
    if(e->escaping)speed=speed*(100-skills[SK_REFRIGERATION]*5)/100;
    if(!e->fling)e->vx=e->facing*speed;
    if(e->ground){
        int front=(px+e->facing*4)/16,checky=py/16;
        if(slope(tileAt(1,tilex,checky)))checky--;
        int wall=tileAt(1,front,checky);
        if(wall&&!slope(wall)){e->facing=-e->facing;e->vx=-e->vx;}
        int marker=tileAt(3,tilex,tiley);
        bool up=(e->advancing?campTileY:e->homeY)*16<py;
        if(up&&marker>=3&&marker<=11){int direction=(marker-3)%3,power=(marker-3)/3+1;bool dirOK=direction==2||(direction==0&&e->facing<0)||(direction==1&&e->facing>0);if(dirOK&&((e->facing<0&&px<=tilex*16+8)||(e->facing>0&&px>=tilex*16+8))){e->x=(tilex*16+8)*FP;e->vy=-(90+30*(power-1))*FP;e->vx=e->facing*35*FP;e->action=1;e->ground=0;}}
    }
    int oldx=e->x,oldy=e->y;e->x+=e->vx/60;e->traveled+=abs(e->x-oldx);
    int nx=ex(e),mid=(e->y_pixel-h/2)/16,wall=tileAt(1,(nx+e->facing*2)/16,mid);
    if(wall&&!slope(wall)){e->x=oldx;e->facing=-e->facing;e->vx=-e->vx;}
    if(e->x<3*FP){e->x=3*FP;e->facing=1;}if(e->x>(map->width*16-3)*FP){e->x=(map->width*16-3)*FP;e->facing=-1;}
    int oldVelocity=e->vy;e->vy+=200*FP/60;e->y+=(oldVelocity+e->vy)/120;e->ground=0;
    int oldFeet=oldy/FP,newFeet=e->y_pixel,x=ex(e);
    /* FlxTilemapExt floor slopes accept feet through the inclusive bottom
     * edge, including upward motion. Looking only in feet/16 misses that
     * edge and lets a walker enter beneath the slope. */
    int slopeRow=(newFeet-1)/16,slopeTile=tileAt(1,x/16,slopeRow);
    int slopeSurface=slope(slopeTile)?surface(x,slopeRow*16):32767;
    if(newFeet>=slopeSurface&&newFeet<=slopeRow*16+16){
        e->y=slopeSurface*FP;e->vy=0;e->ground=1;e->action=0;
    }
    else if(e->vy>=0){for(int yy=oldFeet/16;yy<=newFeet/16+1;yy++){int surf=surface(x,yy*16);if(surf!=32767&&surf>=oldFeet-4&&surf<=newFeet+1){e->y=surf*FP;e->vy=0;e->ground=1;e->action=0;break;}}}
    else {
        /* Original tiles14/18 carry FLOOR and a side flag, never CEILING. */
        int ceiling=tileAt(1,x/16,(newFeet-h)/16);
        if(ceiling&&!slope(ceiling)){e->y=(((newFeet-h)/16+1)*16+h)*FP;e->vy=0;}
    }
    e->immune=e->type==4&&e->ground&&!e->disabled;
}
