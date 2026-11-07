static void drawArt(int id, int frame, int x, int y, bool flip) {
    gfx_sprite_t *sprite = art_sprite(id, frame);
    if (!flip) { gfx_TransparentSprite(sprite, x, y); return; }
    gfx_FlipSpriteY(sprite, (gfx_sprite_t *)flipBuffer);
    gfx_TransparentSprite((gfx_sprite_t *)flipBuffer, x, y);
}

static void drawTowerArt(const Tower *t, int x, int y) {
    int id = towerArt[t->type]; const Art *art = &artTable[id];
    if(t->born){
        gfx_sprite_t*src=art_sprite(id,0);gfx_sprite_t*dst=(gfx_sprite_t*)scaleBuffer;
        dst->width=art->width;dst->height=art->height*(HZ-t->born)/HZ+1;
        gfx_ScaleSprite(src,dst);gfx_TransparentSprite(dst,x+8-art->width/2,y+16-dst->height);
        drawArt(ART_BUILD,(tick*3/4)%4,x-8+(tick%3)*4,y-7,false);return;
    }
    int frame = 0;
    if (t->animation && art->frames > 2) frame = 2 + (tick / 2) % (art->frames - 2);
    drawArt(id, frame, x + 8 - art->width / 2, y + 16 - art->height, t->facing < 0);
    if(t->buildTime)drawArt(ART_BUILD,(tick*3/4)%4,x-8+(tick%3)*4,y-7,false);
    for (int l = 0; l <= t->level && l < 6; l++) art_draw(ART_UPGRADE, 0, x + (l % 3) * 5, y - 5 - (l / 3) * 5);
}

static void renderGame(void) {
    camx = cx * 16 + 8 - 160; camy = cy * 16 + 8 - 110;
    if (camx > map->width * 16 - 320) camx = map->width * 16 - 320;
    if (camy > map->height * 16 - 240) camy = map->height * 16 - 240;
    if (camx < 0) camx = 0;
    if (camy < 0) camy = 0;
#ifdef QA_PERF
    renderStamp=timer_GetSafe(1,TIMER_UP);
#endif
    art_background(skyFor(level));
    input_poll();
#ifdef QA_PERF
    renderMark(0);
#endif
    int theme=level==16?2:level>11?3:level>7?2:level>3?1:0;
    for (int layer = 0; layer < 3; layer++)
        for (int y = camy / 16; y < map->height && y * 16 - camy < 240; y++) {
            for (int x = camx / 16; x < map->width && x * 16 - camx < 320; x++) {
                int tile = layers[layer][y * map->width + x];
                if (tile && tile < 128) art_draw(ART_TILES0+theme, tile, x * 16 - camx, y * 16 - camy);
            }
            input_poll();
        }
#ifdef QA_PERF
    renderMark(1);
#endif
    int fx = map->camp % map->width * 16 - camx, fy = map->camp / map->width * 16 - camy;
    art_draw(ART_TENT, 0, fx - 20, fy + 6); art_draw(ART_TENT, 0, fx + 20, fy + 6); art_draw(ART_FIRE, tick / 2, fx, fy - 3);
    for (int i = 0; i < 5; i++) {
        const Food *f = &foods[i];
        if (f->active) art_draw(ART_FOOD, i, f->x_pixel - 8 - camx, f->y_pixel - 16 - camy);
    }
    for (int i = 0; i < MAXTOWER; i++) {
        if(!(i&7))input_poll();
        const Tower *t = &towers[i];
        if (t->active) drawTowerArt(t, t->cell % map->width * 16 - camx, t->cell / map->width * 16 - camy);
    }
    for (int i = 0; i < enemyTop; i++) {
        if(!(i&7))input_poll();
        const Enemy *e = &enemies[i]; if (!e->active) continue;
        int id = monsterArt[e->type]; const Art *art = &artTable[id];
        static const uint8_t offsetY[10]={0,0,6,8,0,0,0,0,31,3};
        int x=e->x_pixel-art->width/2-camx-((e->type==1||e->type==5)?2:0);
        int y=e->y_pixel-monsterHeight[e->type]-offsetY[e->type]-camy;
        if (x > 320 || x + art->width < 0 || y > 240 || y + art->height < 0) continue;
        int frame=monsterFrame(e,i)%art->frames;
        if(e->type==8||e->born||e->flat) {
            gfx_sprite_t*src=art_sprite(id,frame);gfx_sprite_t*dst=(gfx_sprite_t*)scaleBuffer;
            int w=art->width,h=art->height;
            if(e->type==8){w=(uint32_t)w*e->scale/10000;h=(uint32_t)h*e->scale/10000;w=w*e->wobble/1000;h=h*(1500-e->wobble/2)/1000;}
            if(e->born){int total=e->birthLength?e->birthLength:HZ,progress=total-e->born;if(progress<1)progress=1;if(e->type!=9)w=w*progress/total;h=h*progress/total;}
            if(e->flat)h=art->height/10+1;
            if(w<1)w=1;if(h<1)h=1;if(w>64)w=64;if(h>56)h=56;
            dst->width=w;dst->height=h;gfx_ScaleSprite(src,dst);
            if(e->facing<0){gfx_FlipSpriteY(dst,(gfx_sprite_t*)flipBuffer);dst=(gfx_sprite_t*)flipBuffer;}
            gfx_TransparentSprite(dst,x+(art->width-w)/2,y+art->height-h);
        }else drawArt(id,frame,x,y,e->facing<0);
        if (e->hp < e->maxhp) {
            gfx_SetColor(cBlack); gfx_FillRectangle(x, y - 3, art->width, 2);
            gfx_SetColor(cGreen); gfx_FillRectangle(x, y - 3, (uint32_t)art->width * e->hp / e->maxhp + 1, 2);
        }
        int pip = x;
        if (e->freeze) { gfx_SetColor(cCyan); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->slow) { gfx_SetColor(cWhite); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->shock) { gfx_SetColor(cYellow); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->poison) { gfx_SetColor(cGreen); gfx_FillRectangle(pip, y - 6, 3, 2); pip += 4; }
        if (e->crippled || e->disabled) { gfx_SetColor(cRed); gfx_FillRectangle(pip, y - 6, 3, 2); }
        if (e->immune) { gfx_SetColor(cWhite); gfx_Rectangle(x - 1, y - 1, art->width + 2, art->height + 2); }
    }
    if(focusEnemy>=0&&enemies[focusEnemy].active){const Enemy *e=&enemies[focusEnemy];art_draw(ART_BOX,4,ex(e)-12-camx,e->y_pixel-monsterHeight[e->type]-24-camy);}
#ifdef QA_PERF
    renderMark(2);
#endif
    for (int i = 0; i < bulletTop; i++) {
        if(!(i&7))input_poll();
        const Bullet *b = &bullets[i]; if (!b->active) continue;
        int bx = b->x_pixel - camx, by = b->y_pixel - camy;
        int id=bulletArt[b->type];const Art*art=&artTable[id];
        static const uint8_t slushFrames[6]={0,1,2,3,2,1};
        int frame=b->pop?b->pop:b->type==SLUSHEE?slushFrames[b->age%6]:0;
        art_draw(id,frame,bx-art->width/2,by-art->height/2);
    }
    for (int i = 0; i < MAXTOWER; i++) {
        if(!(i&7))input_poll();
        const Tower *t = &towers[i];
        if (!t->active || t->born) continue;
        int x = t->cell % map->width * 16 + 8 - camx, y = t->cell / map->width * 16 + 8 - camy;
        if (t->animation && (t->type == SHOCK || t->type == CRIPPLER || t->type == LIGHTNING)) {
            gfx_SetColor(t->type == CRIPPLER ? cRed : cYellow);
            if (t->type == LIGHTNING) gfx_VertLine(x, 0, y); else gfx_Circle(x, y, t->range / 2);
        }
    }
#ifdef QA_PERF
    renderMark(3);
#endif
    int x = cx * 16 - camx, y = cy * 16 - camy;
    int ti = towerAt(cy * map->width + cx);
    if (ti >= 0 && towers[ti].range) { gfx_SetColor(cWhite); gfx_Circle(x + 8, y + 8, towers[ti].range); }
    art_draw(ART_BOX, valid(cx, cy) || ti >= 0 ? 1 : 0, x - 4, y - 4);
    art_draw(ART_CURSOR, (valid(cx, cy) || ti >= 0) ? 1 : 0, x, y);
    art_draw(ART_HUD, 0, 195, 0);
    snprintf(textbuf, sizeof textbuf, "$%d", money); label(textbuf, 267, 23, cWhite);
    art_draw(ART_SPEED_SLIDER,0,210+speedThirds*5,2);
    snprintf(textbuf, sizeof textbuf, "W%u/%u", wave, waveCounts[level]); label(textbuf, 3, 25, cWhite);
    if (wave < waveCounts[level] && waveDue[wave] > 0) { snprintf(textbuf, sizeof textbuf, "%ds", (waveDue[wave] + HZ - 1) / (sendFast ? HZ * HZ : HZ)); label(textbuf, 64, 25, cYellow); }
    snprintf(textbuf, sizeof textbuf, "FOOD %d", foodLeft()); shadowLabel(textbuf, 3, 3, foodLeft() < 3 ? cRed : cWhite);
    snprintf(textbuf, sizeof textbuf, "LV %d", playerLevel); shadowLabel(textbuf, 3, 13, cWhite); xpBar(33, 14, 50);
    gfx_SetColor(cPanel); gfx_FillRectangle(0, 217, 320, 23);
    if (statusTicks) shadowLabel(status, 3, 219, cYellow);
    else if (ti >= 0) {
        const Tower *t = &towers[ti];
        snprintf(textbuf, sizeof textbuf, "%s L%d  upgrade $%d  sell $%d", towerNames[t->type], t->level + 1, t->level >= 5 ? 0 : upgradeCost((Tower *)t), t->spent / 2);
        label(textbuf, 3, 219, cWhite);
    } else {
        snprintf(textbuf, sizeof textbuf, "%d %s $%d   2nd = build", selection + 1, towerNames[baseTypes[selection]], (int)rule_BasePrice(baseTypes[selection], 0));
        label(textbuf, 3, 219, cWhite);
    }
    if (ti >= 0 && towers[ti].type <= SHOCK) {
        snprintf(textbuf, sizeof textbuf, "MATH %s  APPS %s", towerNames[branchTypes[towers[ti].type][0]], towerNames[branchTypes[towers[ti].type][1]]);
        label(textbuf, 3, 229, cCyan);
    } else label("GRAPH wave  +/- speed  STAT focus", 3, 229, cCyan);
    if(!speedThirds&&!paused&&!showTip){panel(81,84,158,26);centered("TIME FROZEN",90,cYellow);}
#ifdef QA_PERF
    renderMark(4);
#endif
    if (paused && !showTip) { panel(70, 90, 180, 40); centered("PAUSED", 98, cYellow); centered("ALPHA resumes", 112, cWhite); }
    if (showTip) {
        panel(2, 4, 316, 232); snprintf(textbuf, sizeof textbuf, "- %s -", stageTitles[level]); centered(textbuf, 11, cYellow);
        wrapText(stageTips[level], 12, 26, 296, 9, cWhite);
        label("Arrows move, 2nd builds, ENTER upgrades", 12, 208, cCyan);
        label("ENTER: DEFEND!", 112, 221, cYellow);
    }
    if (mode == MODE_WON || mode == MODE_LOST) {
        panel(30, 70, 260, 96);
        centered(mode == MODE_WON ? "CAMP SAVED!" : "THE FOOD IS GONE", 78, mode == MODE_WON ? cGreen : cRed);
        snprintf(textbuf, sizeof textbuf, "Level %d   Skill points %d", playerLevel, skillPoints); centered(textbuf, 98, cWhite);
        xpBar(110, 112, 100);
        centered(mode == MODE_WON ? "ENTER next stage" : "ENTER try again", 128, cWhite);
        centered("STAT skills   MODE stage menu", 142, cCyan);
    }
}
